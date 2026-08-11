import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

///
/// Raccourci d'accès aux traductions : `context.l10n.mail` plutôt que
/// `AppLocalizations.of(context).mail`.
///
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
