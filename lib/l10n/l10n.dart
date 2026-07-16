import 'package:flutter/widgets.dart';
import 'package:submission_approval_app/l10n/gen/app_localizations.dart';

export 'package:submission_approval_app/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
