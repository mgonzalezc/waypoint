// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get askTitle => 'Ask';

  @override
  String get askHint => 'top 10 tapas bars in Seville...';

  @override
  String get askSubmit => 'Generate ranking';

  @override
  String get rankingTitle => 'Ranking';

  @override
  String get rankingDegradedBadge => 'Fewer than 10 good candidates';

  @override
  String get errorNoConnection =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Try again in a moment.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';
}
