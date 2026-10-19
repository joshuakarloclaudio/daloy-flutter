package pro.daloy.app

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts Flutter, plus the Android side of `os_search_index.dart`: the next
 * line-up and recently opened songs as dynamic shortcuts (long-press the
 * icon, or the launcher's search). A shortcut opens `daloy://open<path>`,
 * handed to Dart at launch (`takeLaunchPath`) or pushed (`open`) when running.
 * App Links on daloy.pro (join, invitation and reset-password links) arrive the
 * same way, as the full URL. A FragmentActivity because the biometric prompt
 * (local_auth) needs one.
 */
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var launchPath: String? = null
    private var presentDisplay: PresentDisplay? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        presentDisplay = PresentDisplay(this, flutterEngine.dartExecutor.binaryMessenger)
        launchPath = pathFrom(intent)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeLaunchPath" -> {
                        result.success(launchPath)
                        launchPath = null
                    }
                    "setShortcuts" -> {
                        val items = call.argument<List<Map<String, Any?>>>("items") ?: emptyList()
                        setShortcuts(items)
                        result.success(null)
                    }
                    "clear" -> {
                        if (Build.VERSION.SDK_INT >= 25) {
                            getSystemService(ShortcutManager::class.java)?.removeAllDynamicShortcuts()
                        }
                        result.success(null)
                    }
                    // Spotlight is iOS's; Android indexes through shortcuts only.
                    "replaceAll" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        presentDisplay?.dispose()
        presentDisplay = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val path = pathFrom(intent) ?: return
        channel?.invokeMethod("open", path)
    }

    private fun setShortcuts(items: List<Map<String, Any?>>) {
        if (Build.VERSION.SDK_INT < 25) return
        val manager = getSystemService(ShortcutManager::class.java) ?: return
        val shortcuts = items.take(manager.maxShortcutCountPerActivity).mapNotNull { item ->
            val id = item["id"] as? String ?: return@mapNotNull null
            val title = item["title"] as? String ?: return@mapNotNull null
            val path = item["path"] as? String ?: return@mapNotNull null
            val subtitle = item["subtitle"] as? String
            ShortcutInfo.Builder(this, id)
                .setShortLabel(title.take(24))
                .setLongLabel(if (subtitle.isNullOrBlank()) title else "$title · $subtitle")
                .setIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))
                .setIntent(
                    Intent(Intent.ACTION_VIEW, Uri.parse("$SCHEME$path"), this, MainActivity::class.java)
                        .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
                )
                .build()
        }
        manager.dynamicShortcuts = shortcuts
    }

    /**
     * What the intent asks to open: the in-app path a shortcut carries, e.g.
     * `/songs/12`, or an App Link on our site as the full URL.
     */
    private fun pathFrom(intent: Intent?): String? {
        val uri = intent?.data ?: return null
        val data = uri.toString()
        if (data.startsWith(SCHEME)) return data.removePrefix(SCHEME)
        if (uri.scheme == "https" && (uri.host == "daloy.pro" || uri.host == "www.daloy.pro")) return data
        return null
    }

    companion object {
        private const val CHANNEL = "pro.daloy.app/search_index"
        private const val SCHEME = "daloy://open"
    }
}
