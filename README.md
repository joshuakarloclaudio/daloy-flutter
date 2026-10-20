# Daloy — Flutter app (Android, iOS/iPadOS, macOS, Windows)

The native app, built on the same conventions as the React Router SPA in `/frontend`.

## Run

```sh
flutter pub get
dart run build_runner build          # after changing any @freezed / @riverpod / Drift file
flutter run                          # iOS simulator → Laravel API on http://localhost:8000

# Android emulator → host machine
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
# Physical device → your Mac's LAN IP
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
```

The app talks to the real API only — start it first (`/api`).

### Google sign-in

"Continue with Google" opens the API's `/api/auth/google/redirect?client=mobile` in a system
auth session (ASWebAuthenticationSession / Custom Tab). After Google, the API redirects to
`daloy://auth/google/callback?exchange=…` (`MOBILE_OAUTH_CALLBACK_URL`), and the app trades the
key at `POST /api/auth/google/exchange`. No extra Google Cloud setup: Google still calls back to
the API's own redirect URI.

Google redirects back to the API's `GOOGLE_REDIRECT_URI` (`http://localhost:8000/…` locally), so
the device's browser must reach the API on that same host. That works as-is on the iOS
simulator; on an Android emulator run `adb reverse tcp:8000 tcp:8000` and use
`API_BASE_URL=http://localhost:8000`.

Windows can't take a `daloy://` link back, so there "Continue with Google" opens the default
browser with `?client=desktop`, and the API redirects to a loopback address the app listens on
while signing in (`http://localhost:43823/auth/google/callback`, `DESKTOP_OAUTH_CALLBACK_URL`).

Keep `dart run build_runner watch` running while you develop.

### Desktop (macOS, Windows)

Both get the desktop shell (`lib/shell/desktop_shell.dart`): a sidebar instead of tab bars,
pointer-sized controls, keyboard shortcuts (a menu bar on the Mac, Ctrl+ shortcuts on Windows).

```sh
flutter run -d macos   --dart-define-from-file=env.local.json   # on a Mac
flutter run -d windows --dart-define-from-file=env.local.json   # on Windows
flutter build windows --release --dart-define-from-file=env.local.json
# → build\windows\x64\runner\Release\ (Daloy.exe plus its DLLs and data\ folder; ship the whole folder.
#   The VC++ runtime DLLs are in it, so PCs don't need the Redistributable.)
```

`env.local.json` isn't in git: copy `env.example.json` and fill in the API and Reverb hosts.

Building for Windows needs a Windows machine with Visual Studio 2022 and the "Desktop
development with C++" workload (`flutter doctor` checks it). Windows doesn't have these yet:

- **YouTube in the app.** `webview_flutter` has no Windows side, so YouTube links open in the
  browser (`hasInAppPlayer` in `lib/core/utils/platform.dart`).
- **Present on a second screen, Spotlight-style search, native alerts.** These are Swift on the
  Mac (`macos/Runner`), with no Windows port; Present shows the slides in the app's window.

## Stack

| Concern | Choice | Web equivalent |
|---|---|---|
| State | Riverpod 3 (codegen) | TanStack Query + hooks |
| HTTP | Dio + `ApiClient` | `lib/api-client.ts` |
| Models | freezed + json_serializable (snake_case) | TS interfaces |
| Offline storage | Drift (SQLite) | Dexie (IndexedDB) |
| Credentials | flutter_secure_storage | `db.authSessions` |
| Routing | go_router (`StatefulShellRoute`) | React Router |
| Icons | flutter_tabler_icons | @tabler/icons-react |
| Fonts | Merriweather + DM Sans, bundled variable TTFs | @fontsource-variable |

## Layout

```
lib/
├── main.dart, app.dart
├── core/
│   ├── config/        AppConfig (dart-defines)
│   ├── network/       ApiClient, ApiException, auth headers
│   ├── storage/       AppDatabase (Drift), SessionStore (secure storage)
│   ├── connectivity/  online status
│   ├── router/        routes + GoRouter with auth redirect
│   ├── theme/         DaloyColors, tokens, typography, ThemeData
│   └── utils/         formatters (the twin of lib/utils.ts)
├── features/{feature}/
│   ├── domain/        freezed models (mirror Laravel Data DTOs)
│   ├── data/          Service (API calls) + Repository (API → Drift → streams) + providers
│   ├── application/   controllers (the twin of use-{feature}-page.ts hooks)
│   └── presentation/  screens + widgets: render state, wire taps; no logic
├── shared/widgets/    design-system components (DaloyButton, StatusChip, …)
└── shell/             phone tab bar / tablet rail
```

## Conventions

- **Data flow is offline-first.** Screens read only from Drift `watch` streams. `WorkspaceSync` pulls from the API into Drift on sign-in, workspace switch, reconnect and pull-to-refresh. The live session is the one network-only read.
- **Services** are plain classes over `ApiClient`: no state, and they return typed models matching the flat `data` payload. **Repositories** own the Drift reads and writes.
- **Controllers** (`@riverpod` Notifiers) hold page state and actions. Screens `ref.watch` the state and call controller methods, the same way route files call a page hook on the web.
- **Errors**: `ApiClient` throws `ApiException` (`ApiHttpException`, `ApiValidationException`, `NetworkException`). Catch them in controllers, not in services.
- **Design**: follow `/DESIGN.md`. Use colors through `context.colors` (never hard-code hex), text through `context.text`, and heights through `ControlSize` only. Glass is for floating chrome only. A screen's one primary action goes through `PrimaryActionButton`, passed as its `floatingActionButton`.
- **Shell**: under 768px wide you get the phone tab bar; anything wider gets the tablet rail (`ShellLayout.of`).
- **Tests** fake the network with `FakeApiAdapter` (`test/support/`), which answers in the API's exact JSON shape while the real interceptors run.

## Before release

- Change the bundle id / applicationId (currently `com.example.daloy_flutter`).
- Consider subsetting `Merriweather.ttf` (4.6 MB).
