/// Per-flavor configuration, built by each `lib/main_*.dart` entrypoint and
/// threaded down through `App` to the API layer.
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  /// Base URL of the Go backend (`backend/cmd/api`), no trailing slash.
  ///
  /// `localhost` resolves to the device itself, so it only reaches a
  /// `docker-compose up` backend running on your Mac from: the iOS
  /// simulator, macOS, or Chrome/web. It will NOT work from the Android
  /// emulator (use `10.0.2.2` instead) or a physical device (use your
  /// Mac's LAN IP, e.g. `192.168.x.x`) — override via
  /// `--dart-define=API_BASE_URL=...` when running those targets.
  final String apiBaseUrl;
}
