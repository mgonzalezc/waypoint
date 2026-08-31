// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get askTitle => 'Demander';

  @override
  String get askHint => 'meilleurs bars à tapas à Séville...';

  @override
  String get askSubmit => 'Générer le classement';

  @override
  String get rankingTitle => 'Classement';

  @override
  String get rankingDegradedBadge => 'Moins de 10 bons candidats';

  @override
  String get errorNoConnection =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get errorServiceUnavailable =>
      'Le service est temporairement indisponible. Réessayez dans un instant.';

  @override
  String get errorUnexpected => 'Une erreur est survenue. Veuillez réessayer.';
}
