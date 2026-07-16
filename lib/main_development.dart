import 'package:submission_approval_app/app/app.dart';
import 'package:submission_approval_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
