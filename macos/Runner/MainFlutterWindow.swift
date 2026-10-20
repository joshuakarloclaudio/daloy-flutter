import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    SearchIndexPlugin.register(with: flutterViewController.registrar(forPlugin: "DaloySearchIndex"))
    AlertPlugin.register(with: flutterViewController.registrar(forPlugin: "DaloyAlert"))
    PresentDisplay.shared.mainWindow = self
    PresentDisplay.shared.register(with: flutterViewController.registrar(forPlugin: "DaloyPresentDisplay"))

    super.awakeFromNib()
  }
}
