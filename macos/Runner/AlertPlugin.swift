import Cocoa
import FlutterMacOS

/// Native alerts and destructive confirmations (`lib/shared/widgets/daloy_alert.dart`),
/// as an `NSAlert` sheet on the app's window.
///
/// `show` takes `{title, message, style: "alert" | "actionSheet", actions:
/// [{title, style: "normal" | "preferred" | "destructive" | "cancel"}]}` and
/// returns the clicked action's index. The Mac has no action sheet, so that
/// style is left to Flutter (not implemented here).
final class AlertPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pro.daloy.app/alert", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(AlertPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "show", let args = call.arguments as? [String: Any],
      (args["style"] as? String) != "actionSheet"
    else { return result(FlutterMethodNotImplemented) }
    guard let specs = args["actions"] as? [[String: Any]], !specs.isEmpty,
      let window = NSApp.keyWindow ?? NSApp.mainWindow
    else {
      return result(FlutterError(code: "alert", message: "Nothing to present from.", details: nil))
    }

    let alert = NSAlert()
    alert.messageText = args["title"] as? String ?? ""
    alert.informativeText = args["message"] as? String ?? ""

    // The first button is the default (Return), and sits rightmost; Cancel
    // goes last and answers Escape.
    let styles = specs.map { $0["style"] as? String }
    let first = styles.firstIndex(of: "preferred") ?? styles.firstIndex { $0 != "cancel" } ?? 0
    var order = [first] + specs.indices.filter { $0 != first && styles[$0] != "cancel" }
    order += specs.indices.filter { $0 != first && styles[$0] == "cancel" }

    for index in order {
      let button = alert.addButton(withTitle: specs[index]["title"] as? String ?? "")
      switch styles[index] {
      case "destructive": button.hasDestructiveAction = true
      case "cancel": button.keyEquivalent = "\u{1b}"
      default: break
      }
    }

    alert.beginSheetModal(for: window) { response in
      let position = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
      result(order.indices.contains(position) ? order[position] : nil)
    }
  }
}
