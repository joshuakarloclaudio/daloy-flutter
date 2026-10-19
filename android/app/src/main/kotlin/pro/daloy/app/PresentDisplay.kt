package pro.daloy.app

import android.app.Activity
import android.app.Presentation
import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import android.view.Display
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Present's projector output (`lib/features/present/data/present_display.dart`).
 * A second screen on USB-C/HDMI or Miracast shows up as a presentation
 * display; while Present is showing slides, a second Flutter engine runs
 * `presentOutputMain` in a [Presentation] on it and draws only the slide.
 * The deck comes from the app's engine as JSON and is relayed as is.
 */
class PresentDisplay(private val activity: Activity, messenger: BinaryMessenger) : DisplayManager.DisplayListener {
    private val displays = activity.getSystemService(DisplayManager::class.java)
    private val channel = MethodChannel(messenger, CHANNEL)
    private var engine: FlutterEngine? = null
    private var outputChannel: MethodChannel? = null
    private var presentation: OutputPresentation? = null
    private var deck: String? = null

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getDisplay" -> result.success(info())
                "show" -> {
                    deck = call.arguments as? String
                    result.success(show())
                }
                "update" -> {
                    deck = call.arguments as? String
                    outputChannel?.invokeMethod("deck", deck)
                    result.success(null)
                }
                "hide" -> {
                    hide()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        displays?.registerDisplayListener(this, Handler(Looper.getMainLooper()))
    }

    fun dispose() {
        hide()
        displays?.unregisterDisplayListener(this)
        channel.setMethodCallHandler(null)
    }

    private fun display(): Display? =
        displays?.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION)?.firstOrNull()

    @Suppress("DEPRECATION")
    private fun info(): Map<String, Any>? {
        val display = display() ?: return null
        val metrics = DisplayMetrics()
        display.getRealMetrics(metrics)
        return mapOf(
            "name" to display.name,
            "width" to metrics.widthPixels / metrics.density.toDouble(),
            "height" to metrics.heightPixels / metrics.density.toDouble(),
        )
    }

    private fun show(): Boolean {
        if (presentation != null) return true
        val display = display() ?: return false
        val engine = FlutterEngine(activity.applicationContext)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(FlutterInjector.instance().flutterLoader().findAppBundlePath(), "presentOutputMain"),
        )
        outputChannel = MethodChannel(engine.dartExecutor.binaryMessenger, OUTPUT_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "ready") result.success(deck) else result.notImplemented()
            }
        }
        this.engine = engine
        presentation = OutputPresentation(activity, display, engine).also { it.show() }
        engine.lifecycleChannel.appIsResumed()
        return true
    }

    private fun hide() {
        presentation?.dismiss()
        presentation = null
        outputChannel = null
        engine?.destroy()
        engine = null
    }

    override fun onDisplayAdded(displayId: Int) = changed()

    override fun onDisplayChanged(displayId: Int) = changed()

    override fun onDisplayRemoved(displayId: Int) {
        if (presentation?.display?.displayId == displayId) hide()
        changed()
    }

    private fun changed() {
        channel.invokeMethod("displayChanged", info())
    }

    companion object {
        private const val CHANNEL = "pro.daloy.app/present_display"
        private const val OUTPUT_CHANNEL = "pro.daloy.app/present_output"
    }
}

/** The slide on the external display: a Flutter view on the output engine. */
private class OutputPresentation(
    context: Context,
    display: Display,
    private val engine: FlutterEngine,
) : Presentation(context, display) {
    private var view: FlutterView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val view = FlutterView(context)
        view.attachToFlutterEngine(engine)
        setContentView(view)
        this.view = view
    }

    override fun onStop() {
        view?.detachFromFlutterEngine()
        view = null
        super.onStop()
    }
}
