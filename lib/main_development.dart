import 'package:submission_approval_app/app/app.dart';
import 'package:submission_approval_app/app/config/app_config.dart';
import 'package:submission_approval_app/bootstrap.dart';

Future<void> main() async {
  const config = AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );
  await bootstrap(() => const App(config: config));
}
