import AVFoundation
import CoreSpotlight
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureAudioSession()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DaloySearchIndex") {
      SearchIndexPlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DaloyAlert") {
      AlertPlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DaloyPresentDisplay") {
      PresentDisplay.shared.register(with: registrar)
    }
  }

  /// External screens (HDMI, AirPlay) get Present's output scene; the app's
  /// own window gets Info.plist's "flutter" scene. Answered here because
  /// Flutter's app delegate otherwise answers for every role, and the
  /// external display would only ever mirror. Never call super: Flutter's
  /// delegate doesn't implement this, so it throws (unrecognized selector)
  /// whenever iOS creates a fresh scene session, e.g. launching after the
  /// app was swiped away.
  override func application(
    _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    if PresentDisplay.isExternal(connectingSceneSession.role) {
      let config = UISceneConfiguration(name: "External Display", sessionRole: connectingSceneSession.role)
      config.delegateClass = ExternalDisplaySceneDelegate.self
      return config
    }
    return UISceneConfiguration(name: "flutter", sessionRole: connectingSceneSession.role)
  }

  /// SoLoud leaves the audio session to the app, and iOS's default
  /// (soloAmbient) is muted by the silent switch. The metronome is the point
  /// of the app, so play through it — mixed, so a backing track in another
  /// app keeps going.
  private func configureAudioSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try session.setActive(true)
    } catch {
      NSLog("Daloy: audio session setup failed: \(error)")
    }
  }
}

/// Songs and line-ups in Spotlight (`lib/features/search/data/os_search_index.dart`).
/// Each item's identifier is the in-app path it opens, so a tapped result
/// comes back as a path: handed over at launch (`takeLaunchPath`) or pushed
/// to Dart (`open`) when the app is already running. Home-screen widget taps
/// (`daloy://open<path>`, DaloyWidget) arrive the same way.
final class SearchIndexPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private static let domain = "pro.daloy.app"
  private let channel: FlutterMethodChannel
  private var launchPath: String?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pro.daloy.app/search_index", binaryMessenger: registrar.messenger())
    let instance = SearchIndexPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
    registrar.addSceneDelegate(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "replaceAll":
      let maps = (call.arguments as? [String: Any])?["items"] as? [[String: Any]] ?? []
      let items = maps.compactMap(Self.searchableItem)
      let index = CSSearchableIndex.default()
      index.deleteSearchableItems(withDomainIdentifiers: [Self.domain]) { _ in
        guard !items.isEmpty else { return DispatchQueue.main.async { result(nil) } }
        index.indexSearchableItems(items) { error in
          DispatchQueue.main.async {
            if let error {
              result(FlutterError(code: "index", message: error.localizedDescription, details: nil))
            } else {
              result(nil)
            }
          }
        }
      }
    case "clear":
      CSSearchableIndex.default().deleteAllSearchableItems { _ in DispatchQueue.main.async { result(nil) } }
    case "takeLaunchPath":
      result(launchPath)
      launchPath = nil
    case "setShortcuts":
      // Android only.
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func searchableItem(_ map: [String: Any]) -> CSSearchableItem? {
    guard let path = map["path"] as? String, let title = map["title"] as? String else { return nil }
    let attributes = CSSearchableItemAttributeSet(contentType: .content)
    attributes.title = title
    let subtitle = map["subtitle"] as? String
    let description = map["description"] as? String
    attributes.contentDescription = [subtitle, description].compactMap { $0 }.joined(separator: "\n")
    attributes.keywords = map["keywords"] as? [String]
    return CSSearchableItem(uniqueIdentifier: path, domainIdentifier: domain, attributeSet: attributes)
  }

  /// What an activity asks the app to open: the in-app path behind a
  /// Spotlight tap, or a Universal Link on our site (invite, join and reset
  /// links; Dart decides which of those it knows).
  private static func path(from activity: NSUserActivity) -> String? {
    if activity.activityType == CSSearchableItemActionType {
      return activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
    }
    if activity.activityType == NSUserActivityTypeBrowsingWeb, let url = activity.webpageURL,
      let host = url.host, host == "daloy.pro" || host == "www.daloy.pro"
    {
      return url.absoluteString
    }
    return nil
  }

  /// The in-app path behind a home-screen widget tap: `daloy://open/line-ups/12`
  /// → `/line-ups/12` (query kept, for `/line-ups?new=1`).
  private static func path(from url: URL) -> String? {
    guard url.scheme == "daloy", url.host == "open" else { return nil }
    let path = String(url.absoluteString.dropFirst("daloy://open".count))
    return path.hasPrefix("/") ? path : nil
  }

  private func deliver(_ activity: NSUserActivity) -> Bool {
    guard let path = Self.path(from: activity) else { return false }
    return deliver(path: path)
  }

  private func deliver(path: String) -> Bool {
    // Dart takes it with `takeLaunchPath` if it isn't listening yet.
    launchPath = path
    channel.invokeMethod("open", arguments: path) { [weak self] reply in
      if !(reply is FlutterError) && (reply as? NSObject) != FlutterMethodNotImplemented {
        self?.launchPath = nil
      }
    }
    return true
  }

  // Cold start: the activity arrives with the scene.
  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    if let url = connectionOptions?.urlContexts.lazy.compactMap({ Self.path(from: $0.url) }).first {
      launchPath = url
      return true
    }
    guard let activity = connectionOptions?.userActivities.first(where: { Self.path(from: $0) != nil }) else {
      return false
    }
    launchPath = Self.path(from: activity)
    return true
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let path = URLContexts.lazy.compactMap({ Self.path(from: $0.url) }).first else { return false }
    return deliver(path: path)
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
    deliver(userActivity)
  }

  func application(
    _ application: UIApplication, continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]) -> Void
  ) -> Bool {
    deliver(userActivity)
  }
}

/// Present's projector output (`lib/features/present/data/present_display.dart`).
/// An HDMI adapter or AirPlay to an Apple TV hands the app its own scene for
/// the external screen; while Present is showing slides, a second Flutter
/// engine runs `presentOutputMain` there and draws only the slide. The deck
/// comes from the app's engine as JSON and is relayed as is. Without a
/// window on that scene, the system goes on mirroring the device.
final class PresentDisplay: NSObject {
  static let shared = PresentDisplay()

  private var channel: FlutterMethodChannel?
  private var scene: UIWindowScene?
  private var window: UIWindow?
  private var engine: FlutterEngine?
  private var outputChannel: FlutterMethodChannel?
  private var deck: String?

  static func isExternal(_ role: UISceneSession.Role) -> Bool {
    if #available(iOS 16.0, *), role == .windowExternalDisplayNonInteractive { return true }
    return role.rawValue == "UIWindowSceneSessionRoleExternalDisplay"
  }

  func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pro.daloy.app/present_display", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in self?.handle(call, result: result) }
    self.channel = channel

    // Whichever delegate a screen's scene got, Present can still draw on it.
    let center = NotificationCenter.default
    center.addObserver(forName: UIScene.willConnectNotification, object: nil, queue: .main) { [weak self] note in
      guard let scene = note.object as? UIWindowScene, Self.isExternal(scene.session.role) else { return }
      self?.attach(scene)
    }
    center.addObserver(forName: UIScene.didDisconnectNotification, object: nil, queue: .main) { [weak self] note in
      guard let scene = note.object as? UIWindowScene else { return }
      self?.detach(scene)
    }
    for case let scene as UIWindowScene in UIApplication.shared.connectedScenes where Self.isExternal(scene.session.role) {
      attach(scene)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDisplay":
      result(info())
    case "show":
      deck = call.arguments as? String
      show()
      result(scene != nil)
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

  private func info() -> [String: Any]? {
    guard let scene else { return nil }
    let bounds = scene.screen.bounds
    let airPlay = AVAudioSession.sharedInstance().currentRoute.outputs.first { $0.portType == .airPlay }
    return [
      "name": airPlay?.portName ?? "External display",
      "width": Double(bounds.width),
      "height": Double(bounds.height),
    ]
  }

  func attach(_ scene: UIWindowScene) {
    guard scene != self.scene else { return }
    NSLog("Daloy: external display connected (\(scene.session.role.rawValue))")
    self.scene = scene
    channel?.invokeMethod("displayChanged", arguments: info())
  }

  func detach(_ scene: UIWindowScene) {
    guard scene == self.scene else { return }
    hide()
    self.scene = nil
    channel?.invokeMethod("displayChanged", arguments: nil)
  }

  private func show() {
    guard let scene, window == nil else { return }
    let engine = FlutterEngine(name: "present-output", project: nil, allowHeadlessExecution: false)
    engine.run(withEntrypoint: "presentOutputMain")
    let output = FlutterMethodChannel(name: "pro.daloy.app/present_output", binaryMessenger: engine.binaryMessenger)
    output.setMethodCallHandler { [weak self] call, result in
      call.method == "ready" ? result(self?.deck) : result(FlutterMethodNotImplemented)
    }
    let window = UIWindow(windowScene: scene)
    window.rootViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    window.backgroundColor = .black
    window.isHidden = false
    self.engine = engine
    self.outputChannel = output
    self.window = window
  }

  private func hide() {
    window?.isHidden = true
    window?.rootViewController = nil
    window = nil
    outputChannel = nil
    engine?.destroyContext()
    engine = nil
  }
}

/// The external screen's scene (Info.plist: the external display roles).
final class ExternalDisplaySceneDelegate: UIResponder, UIWindowSceneDelegate {
  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = scene as? UIWindowScene else { return }
    PresentDisplay.shared.attach(scene)
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    guard let scene = scene as? UIWindowScene else { return }
    PresentDisplay.shared.detach(scene)
  }
}
