import 'package:submission_approval_app/app/app.dart';
import 'package:submission_approval_app/app/config/app_config.dart';
import 'package:submission_approval_app/bootstrap.dart';

Future<void> main() async {
  // There's no separate staging backend; this points at the same Railway
  // deployment as production. Override with --dart-define=API_BASE_URL=...
  // once a dedicated staging backend exists.
  const config = AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue:
          'https://submission-approval-workflow-production.up.railway.app',
    ),
  );
  await bootstrap(() => const App(config: config));
}
