// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get askHeadline => 'Demandez à la carte tout ce que vous voulez.';

  @override
  String get askFieldLabel => 'Votre Top 10';

  @override
  String get askHint => 'bars à tapas à Séville...';

  @override
  String get askSubmit => 'Générer le classement';

  @override
  String get rankingTitle => 'Les dix';

  @override
  String get rankingDegradedNote => 'moins de 10 bons candidats cette fois';

  @override
  String get errorNoConnection =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get errorServiceUnavailable =>
      'Le service est temporairement indisponible. Réessayez dans un instant.';

  @override
  String get errorUnexpected => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get verifyingPhrase1 => 'Exploration du monde entier...';

  @override
  String get verifyingPhrase2 => 'Dégustation des restaurants...';

  @override
  String get verifyingPhrase3 => 'Lecture de milliers d\'avis...';

  @override
  String get verifyingPhrase4 => 'Consultation des habitants...';
}
