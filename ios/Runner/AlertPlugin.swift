import Flutter
import UIKit

/// Native alerts and destructive confirmations (`lib/shared/widgets/daloy_alert.dart`).
/// `UIAlertController` is Liquid Glass on iOS 26 and the system look before
/// that, so there is nothing to draw ourselves.
///
/// `show` takes `{title, message, style: "alert" | "actionSheet", actions:
/// [{title, style: "normal" | "preferred" | "destructive" | "cancel"}],
/// anchor: [x, y, width, height]?}` and returns the tapped action's index, or
/// nil if the sheet was dismissed without a choice. `anchor` is the trigger's
/// rect in screen points: an action sheet on iPad is a popover from it.
final class AlertPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pro.daloy.app/alert", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(AlertPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "show" else { return result(FlutterMethodNotImplemented) }
    guard let args = call.arguments as? [String: Any], let specs = args["actions"] as? [[String: Any]],
      let presenter = Self.topViewController()
    else {
      return result(FlutterError(code: "alert", message: "Nothing to present from.", details: nil))
    }

    let sheet = (args["style"] as? String) == "actionSheet"
    let alert = UIAlertController(
      title: args["title"] as? String,
      message: args["message"] as? String,
      preferredStyle: sheet ? .actionSheet : .alert
    )
    var answered = false
    func answer(_ value: Int?) {
      guard !answered else { return }
      answered = true
      result(value)
    }

    for (index, spec) in specs.enumerated() {
      let style: UIAlertAction.Style
      switch spec["style"] as? String {
      case "destructive": style = .destructive
      case "cancel": style = .cancel
      default: style = .default
      }
      let action = UIAlertAction(title: spec["title"] as? String ?? "", style: style) { _ in answer(index) }
      alert.addAction(action)
      if (spec["style"] as? String) == "preferred" { alert.preferredAction = action }
    }

    if sheet, let popover = alert.popoverPresentationController {
      popover.sourceView = presenter.view
      if let a = args["anchor"] as? [Double], a.count == 4 {
        popover.sourceRect = CGRect(x: a[0], y: a[1], width: a[2], height: a[3])
      } else {
        popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
      }
    }

    // A popover dismissed by tapping outside never runs an action's handler.
    // Only the popover takes a delegate: UIKit throws if an alert's own
    // presentation controller gets one.
    if sheet, let popover = alert.popoverPresentationController {
      popover.delegate = DismissWatcher.attach(to: alert) { answer(nil) }
    }
    presenter.present(alert, animated: true)
  }

  private static func topViewController() -> UIViewController? {
    let scene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
    var top = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
    while let presented = top?.presentedViewController, !presented.isBeingDismissed { top = presented }
    return top
  }
}

/// Reports a dismissal that didn't come from an action. Kept alive by the
/// alert itself.
private final class DismissWatcher: NSObject, UIPopoverPresentationControllerDelegate {
  private let onDismiss: () -> Void
  private init(_ onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }

  static func attach(to alert: UIAlertController, onDismiss: @escaping () -> Void) -> DismissWatcher {
    let watcher = DismissWatcher(onDismiss)
    objc_setAssociatedObject(alert, &Self.key, watcher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return watcher
  }

  private static var key = 0

  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    onDismiss()
  }
}
