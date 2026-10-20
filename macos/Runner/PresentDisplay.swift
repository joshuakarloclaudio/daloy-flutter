import Cocoa
import FlutterMacOS

/// Present's projector output (`lib/features/present/data/present_display.dart`).
/// Every screen but the one the app's window is on can take the slides; the
/// person picks one (`select`), else the first. While Present is showing
/// slides, a borderless window covers that whole screen, menu bar and Dock
/// included, and a second Flutter engine runs `presentOutputMain` in it to
/// draw only the slide. The deck comes from the app's engine as JSON and is
/// relayed as is.
final class PresentDisplay: NSObject {
  static let shared = PresentDisplay()

  /// The app's own window: its screen is the presenter's, never the output.
  weak var mainWindow: NSWindow?

  private var channel: FlutterMethodChannel?
  private var chosen: CGDirectDisplayID?
  private var window: NSWindow?
  private var engine: FlutterEngine?
  private var outputChannel: FlutterMethodChannel?
  private var deck: String?

  func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pro.daloy.app/present_display", binaryMessenger: registrar.messenger)
    channel.setMethodCallHandler { [weak self] call, result in self?.handle(call, result: result) }
    self.channel = channel

    // Plugging a screen in or out, a resolution change, or the app's window
    // moving to another screen all change which screens can take the slides.
    let center = NotificationCenter.default
    center.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
    ) { [weak self] _ in self?.screensChanged() }
    center.addObserver(forName: NSWindow.didChangeScreenNotification, object: mainWindow, queue: .main) {
      [weak self] _ in self?.screensChanged()
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDisplay":
      result(target.map(Self.info))
    case "getDisplays":
      let target = self.target
      result(candidates.map { screen in
        var info = Self.info(screen)
        info["selected"] = screen == target
        return info
      })
    case "select":
      if let id = (call.arguments as? NSNumber)?.uint32Value { chosen = id }
      screensChanged()
      result(nil)
    case "show":
      deck = call.arguments as? String
      show()
      result(window != nil)
    case "update":
      deck = call.arguments as? String
      outputChannel?.invokeMethod("deck", arguments: deck)
      result(nil)
    case "hide":
      hide()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Screens

  private var candidates: [NSScreen] {
    let home = mainWindow?.screen ?? NSScreen.main
    return NSScreen.screens.filter { $0 != home }
  }

  /// The chosen screen while it's still there, else the first one.
  private var target: NSScreen? {
    let candidates = self.candidates
    return candidates.first { Self.id(of: $0) == chosen } ?? candidates.first
  }

  private static func id(of screen: NSScreen) -> CGDirectDisplayID? {
    (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
  }

  private static func info(_ screen: NSScreen) -> [String: Any] {
    [
      "id": Int(id(of: screen) ?? 0),
      "name": screen.localizedName,
      "width": Double(screen.frame.width),
      "height": Double(screen.frame.height),
    ]
  }

  private func screensChanged() {
    let target = self.target
    if let window {
      if let target {
        window.setFrame(target.frame, display: true)
      } else {
        hide()
      }
    }
    channel?.invokeMethod("displayChanged", arguments: target.map(Self.info))
  }

  // MARK: Output window

  private func show() {
    guard let screen = target, window == nil else { return }
    let engine = FlutterEngine(name: "present-output", project: nil, allowHeadlessExecution: false)
    let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    controller.backgroundColor = .black
    engine.run(withEntrypoint: "presentOutputMain")
    let output = FlutterMethodChannel(name: "pro.daloy.app/present_output", binaryMessenger: engine.binaryMessenger)
    output.setMethodCallHandler { [weak self] call, result in
      call.method == "ready" ? result(self?.deck) : result(FlutterMethodNotImplemented)
    }

    let window = NSWindow(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentViewController = controller
    window.setFrame(screen.frame, display: true)
    window.backgroundColor = .black
    window.hasShadow = false
    window.isReleasedWhenClosed = false
    // Over the projector's menu bar and Dock, and on every Space, so a
    // full-screen app on the presenter's screen doesn't take the slides away.
    window.level = NSWindow.Level(rawValue: NSWindow.Level.mainMenu.rawValue + 1)
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    window.orderFrontRegardless()

    self.engine = engine
    self.outputChannel = output
    self.window = window
  }

  private func hide() {
    window?.orderOut(nil)
    window?.contentViewController = nil
    window = nil
    outputChannel = nil
    engine?.shutDownEngine()
    engine = nil
  }
}
