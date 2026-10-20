import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  /// Spotlight clicks and Universal Links. Flutter's app delegate doesn't
  /// pass activities on to plugins, so they go to the search index here.
  override func application(
    _ application: NSApplication, continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void
  ) -> Bool {
    SearchIndexPlugin.shared?.continueActivity(userActivity) ?? false
  }
}
