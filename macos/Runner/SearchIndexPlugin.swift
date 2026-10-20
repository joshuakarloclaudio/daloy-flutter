import CoreSpotlight
import FlutterMacOS
import UniformTypeIdentifiers

/// Songs and line-ups in Spotlight (`lib/features/search/data/os_search_index.dart`).
/// Each item's identifier is the in-app path it opens, so a clicked result
/// comes back as a path: handed over at launch (`takeLaunchPath`) or pushed
/// to Dart (`open`) when the app is already running. `daloy://open<path>`
/// links arrive the same way. The Mac has no scenes, so activities come
/// through `AppDelegate` (`continueActivity`) and URLs through Flutter's
/// app delegate.
final class SearchIndexPlugin: NSObject, FlutterPlugin, FlutterAppLifecycleDelegate {
  private(set) static weak var shared: SearchIndexPlugin?

  private static let domain = "pro.daloy.app"
  private let channel: FlutterMethodChannel
  private var launchPath: String?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pro.daloy.app/search_index", binaryMessenger: registrar.messenger)
    let instance = SearchIndexPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
    shared = instance
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
  /// Spotlight click, or a Universal Link on our site (invite, join and reset
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

  /// `daloy://open/line-ups/12` → `/line-ups/12` (query kept, for `/line-ups?new=1`).
  private static func path(from url: URL) -> String? {
    guard url.scheme == "daloy", url.host == "open" else { return nil }
    let path = String(url.absoluteString.dropFirst("daloy://open".count))
    return path.hasPrefix("/") ? path : nil
  }

  func continueActivity(_ activity: NSUserActivity) -> Bool {
    guard let path = Self.path(from: activity) else { return false }
    return deliver(path: path)
  }

  func handleOpen(_ urls: [URL]) -> Bool {
    guard let path = urls.lazy.compactMap(Self.path(from:)).first else { return false }
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
}
