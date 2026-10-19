package pro.daloy.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * The home-screen widget: the next line-up and its songs, or "Plan a
 * line-up" when nothing is coming up. Dart writes the next few line-ups as
 * JSON (`lib/features/home_screen_widget/home_screen_widget.dart`); this
 * picks the first dated today or later, so a passed one drops off at
 * midnight — when an inexact alarm redraws it — without the app running.
 * Taps open `daloy://open<path>`, which MainActivity hands to Dart like a
 * launcher shortcut.
 */
class NextLineUpWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val snapshot = Snapshot.parse(widgetData.getString(DATA_KEY, null))
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, views(context, snapshot, appWidgetManager.getAppWidgetOptions(id)))
        }
        armMidnight(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        val snapshot = Snapshot.parse(HomeWidgetPlugin.getData(context).getString(DATA_KEY, null))
        appWidgetManager.updateAppWidget(appWidgetId, views(context, snapshot, newOptions))
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        context.getSystemService(AlarmManager::class.java)?.cancel(midnightIntent(context))
    }

    /** Small (under ~2 rows tall) shows the date and title; bigger adds the songs. */
    private fun views(context: Context, snapshot: Snapshot, options: Bundle?): RemoteViews {
        val small = render(context, snapshot, R.layout.widget_next_line_up_small)
        val full = render(context, snapshot, R.layout.widget_next_line_up)
        if (Build.VERSION.SDK_INT >= 31) {
            return RemoteViews(mapOf(SizeF(110f, 50f) to small, SizeF(110f, 180f) to full))
        }
        val minHeight = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0
        return if (minHeight in 1 until 180) small else full
    }

    private fun render(context: Context, snapshot: Snapshot, layout: Int): RemoteViews {
        val views = RemoteViews(context.packageName, layout)
        // `YYYY-MM-DD` sorts as it reads.
        val today = isoDate(Calendar.getInstance())
        val next = snapshot.lineUps.firstOrNull { it.date >= today }

        if (next == null) {
            views.setViewVisibility(R.id.line_up, View.GONE)
            views.setViewVisibility(R.id.empty, View.VISIBLE)
            val signedIn = snapshot.workspace != null
            views.setTextViewText(R.id.empty_eyebrow, snapshot.workspace ?: "Daloy")
            views.setTextViewText(
                R.id.empty_title,
                context.getString(if (signedIn) R.string.widget_empty_title else R.string.widget_signed_out),
            )
            views.setViewVisibility(R.id.empty_action, if (signedIn) View.VISIBLE else View.GONE)
            views.setOnClickPendingIntent(R.id.widget_root, openIntent(context, if (signedIn) "/line-ups" else null))
            if (signedIn) views.setOnClickPendingIntent(R.id.empty_action, openIntent(context, snapshot.newLineUpPath))
            return views
        }

        views.setViewVisibility(R.id.line_up, View.VISIBLE)
        views.setViewVisibility(R.id.empty, View.GONE)
        val isToday = next.date == today
        views.setTextViewText(R.id.eyebrow, eyebrow(next.date, today))
        views.setTextColor(
            R.id.eyebrow,
            context.getColor(if (isToday) R.color.widget_today else R.color.widget_primary_ink),
        )
        views.setTextViewText(R.id.title, next.title)
        val count = if (next.songsCount == 1) "1 song" else "${next.songsCount} songs"
        views.setTextViewText(R.id.subtitle, listOfNotNull(next.leader, count).joinToString(" · "))
        views.setOnClickPendingIntent(R.id.widget_root, openIntent(context, next.path))

        if (layout == R.layout.widget_next_line_up) {
            val songs = next.songs.orEmpty()
            for (i in SONG_ROWS.indices) {
                val song = songs.getOrNull(i)
                views.setViewVisibility(SONG_ROWS[i], if (song == null) View.GONE else View.VISIBLE)
                if (song != null) {
                    views.setTextViewText(SONG_TITLES[i], song.title)
                    views.setTextViewText(SONG_KEYS[i], song.key ?: "")
                }
            }
        }
        return views
    }

    private fun eyebrow(date: String, today: String): String {
        if (date == today) return "Today"
        val tomorrow = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, 1) }
        if (date == isoDate(tomorrow)) return "Tomorrow"
        val parsed = try {
            SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(date)
        } catch (e: Exception) {
            null
        } ?: return date
        val sameYear = date.take(4) == today.take(4)
        val format = if (sameYear) SimpleDateFormat("EEE, MMM d", Locale.getDefault()) else DateFormat.getDateInstance(DateFormat.MEDIUM)
        return format.format(parsed)
    }

    private fun isoDate(calendar: Calendar): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(calendar.time)

    /** Opens [path] in the app, or just the app when null. */
    private fun openIntent(context: Context, path: String?): PendingIntent {
        val intent = if (path == null) {
            Intent(context, MainActivity::class.java)
        } else {
            Intent(Intent.ACTION_VIEW, Uri.parse("daloy://open$path"), context, MainActivity::class.java)
        }.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            context,
            (path ?: "").hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** Redraws just after the next midnight, whenever the device is next awake. */
    private fun armMidnight(context: Context) {
        val at = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
        }
        context.getSystemService(AlarmManager::class.java)
            ?.set(AlarmManager.RTC, at.timeInMillis, midnightIntent(context))
    }

    private fun midnightIntent(context: Context): PendingIntent {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, NextLineUpWidget::class.java))
        val intent = Intent(context, NextLineUpWidget::class.java)
            .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
            .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private data class Song(val title: String, val key: String?)

    private data class LineUp(
        val title: String,
        /** `YYYY-MM-DD`. */
        val date: String,
        val leader: String?,
        val songsCount: Int,
        val path: String,
        val songs: List<Song>?,
    )

    private data class Snapshot(val workspace: String?, val lineUps: List<LineUp>, val newLineUpPath: String) {
        companion object {
            fun parse(raw: String?): Snapshot {
                val empty = Snapshot(null, emptyList(), "/line-ups?new=1")
                if (raw.isNullOrEmpty()) return empty
                return try {
                    val json = JSONObject(raw)
                    val list = json.optJSONArray("lineUps")
                    val lineUps = (0 until (list?.length() ?: 0)).mapNotNull { i ->
                        val l = list!!.getJSONObject(i)
                        val songs = l.optJSONArray("songs")?.let { arr ->
                            (0 until arr.length()).map { j ->
                                val s = arr.getJSONObject(j)
                                Song(s.getString("title"), s.optString("key").takeIf { s.has("key") && !s.isNull("key") })
                            }
                        }
                        LineUp(
                            title = l.getString("title"),
                            date = l.getString("date"),
                            leader = if (l.isNull("leader")) null else l.optString("leader"),
                            songsCount = l.optInt("songsCount"),
                            path = l.getString("path"),
                            songs = songs,
                        )
                    }
                    Snapshot(
                        workspace = if (json.isNull("workspace")) null else json.optString("workspace"),
                        lineUps = lineUps,
                        newLineUpPath = json.optString("newLineUpPath", empty.newLineUpPath),
                    )
                } catch (e: Exception) {
                    empty
                }
            }
        }
    }

    companion object {
        private const val DATA_KEY = "next_line_ups"

        private val SONG_ROWS = intArrayOf(
            R.id.song_row_0, R.id.song_row_1, R.id.song_row_2, R.id.song_row_3,
            R.id.song_row_4, R.id.song_row_5, R.id.song_row_6, R.id.song_row_7,
        )
        private val SONG_TITLES = intArrayOf(
            R.id.song_title_0, R.id.song_title_1, R.id.song_title_2, R.id.song_title_3,
            R.id.song_title_4, R.id.song_title_5, R.id.song_title_6, R.id.song_title_7,
        )
        private val SONG_KEYS = intArrayOf(
            R.id.song_key_0, R.id.song_key_1, R.id.song_key_2, R.id.song_key_3,
            R.id.song_key_4, R.id.song_key_5, R.id.song_key_6, R.id.song_key_7,
        )
    }
}
