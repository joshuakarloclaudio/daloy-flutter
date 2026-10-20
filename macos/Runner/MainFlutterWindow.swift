import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // The desktop shell has no phone layout, so the window never gets that
    // narrow (`lib/shell/shell_layout.dart`). It opens where it was left.
    self.contentMinSize = NSSize(width: 960, height: 600)
    if !self.setFrameUsingName("MainWindow") {
      self.setContentSize(NSSize(width: 1280, height: 820))
      self.center()
    }
    self.setFrameAutosaveName("MainWindow")

    RegisterGeneratedPlugins(registry: flutterViewController)
    SearchIndexPlugin.register(with: flutterViewController.registrar(forPlugin: "DaloySearchIndex"))
    AlertPlugin.register(with: flutterViewController.registrar(forPlugin: "DaloyAlert"))
    PresentDisplay.shared.mainWindow = self
    PresentDisplay.shared.register(with: flutterViewController.registrar(forPlugin: "DaloyPresentDisplay"))

    super.awakeFromNib()
  }
}
