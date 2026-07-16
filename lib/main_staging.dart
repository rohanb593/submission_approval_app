import 'package:submission_approval_app/app/app.dart';
import 'package:submission_approval_app/app/config/app_config.dart';
import 'package:submission_approval_app/bootstrap.dart';

Future<void> main() async {
  // No staging backend is deployed yet; override with
  // --dart-define=API_BASE_URL=https://staging.example.com once one exists.
  const config = AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );
  await bootstrap(() => const App(config: config));
}
