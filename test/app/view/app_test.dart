import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:submission_approval_app/app/app.dart';
import 'package:submission_approval_app/app/config/app_config.dart';
import 'package:submission_approval_app/auth/auth.dart';

void main() {
  group('App', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    testWidgets('renders LoginPage when there is no persisted session', (
      tester,
    ) async {
      await tester.pumpWidget(
        const App(config: AppConfig(apiBaseUrl: 'http://localhost:8080')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
