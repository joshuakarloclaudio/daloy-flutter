#include "flutter_window.h"

#include <dwmapi.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {

// DWMWA_SYSTEMBACKDROP_TYPE and DWMSBT_TRANSIENTWINDOW (acrylic), Windows 11
// 22H2. Spelled out so older SDK headers still build.
constexpr DWORD kSystemBackdropType = 38;
constexpr int kBackdropAcrylic = 3;

// The compositor blurs what is behind the window, so the app pays nothing per
// frame. Fails before build 22621, where the Dart side keeps its solid fills
// (`hasAcrylic` in lib/core/utils/platform.dart).
void EnableAcrylic(HWND window) {
  int backdrop = kBackdropAcrylic;
  if (FAILED(DwmSetWindowAttribute(window, kSystemBackdropType, &backdrop,
                                   sizeof(backdrop)))) {
    return;
  }
  // Let the backdrop through the whole client area.
  MARGINS margins = {-1, -1, -1, -1};
  DwmExtendFrameIntoClientArea(window, &margins);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  EnableAcrylic(GetHandle());
  window_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "daloy/window",
          &flutter::StandardMethodCodec::GetInstance());
  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        const auto* dark = std::get_if<bool>(call.arguments());
        if (call.method_name() == "setDark" && dark != nullptr) {
          BOOL enable = *dark ? TRUE : FALSE;
          DwmSetWindowAttribute(GetHandle(), DWMWA_USE_IMMERSIVE_DARK_MODE,
                                &enable, sizeof(enable));
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  window_channel_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    // The desktop shell has no phone layout, so the window never gets that
    // narrow (lib/shell/shell_layout.dart), at any display scale.
    case WM_GETMINMAXINFO: {
      const double scale = ::GetDpiForWindow(hwnd) / 96.0;
      auto* info = reinterpret_cast<MINMAXINFO*>(lparam);
      info->ptMinTrackSize.x = static_cast<LONG>(960 * scale);
      info->ptMinTrackSize.y = static_cast<LONG>(600 * scale);
      return 0;
    }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
