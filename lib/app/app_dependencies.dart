import 'package:submission_approval_app/api/api_client.dart';
import 'package:submission_approval_app/api/repositories/activity_repository.dart';
import 'package:submission_approval_app/api/repositories/application_repository.dart';
import 'package:submission_approval_app/api/repositories/auth_repository.dart';
import 'package:submission_approval_app/api/repositories/notification_repository.dart';
import 'package:submission_approval_app/api/repositories/user_repository.dart';
import 'package:submission_approval_app/api/token_storage.dart';
import 'package:submission_approval_app/app/config/app_config.dart';

/// Wires the API layer once per app run and hands out the repositories each
/// feature's cubit depends on. Provided down the widget tree as a single
/// value via `RepositoryProvider.value` in `App` rather than one provider
/// per repository, since every repository here shares the same
/// [ApiClient]/[TokenStorage] pair anyway.
class AppDependencies {
  AppDependencies(this.config) : tokenStorage = TokenStorage() {
    apiClient = ApiClient(
      baseUrl: config.apiBaseUrl,
      tokenStorage: tokenStorage,
    );
    authRepository = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
    applicationRepository = ApplicationRepository(apiClient: apiClient);
    notificationRepository = NotificationRepository(apiClient: apiClient);
    activityRepository = ActivityRepository(apiClient: apiClient);
    userRepository = UserRepository(apiClient: apiClient);
  }

  final AppConfig config;
  final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final ApplicationRepository applicationRepository;
  late final NotificationRepository notificationRepository;
  late final ActivityRepository activityRepository;
  late final UserRepository userRepository;
}
