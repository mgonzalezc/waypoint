// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get askHeadline => 'Ask the map anything.';

  @override
  String get askFieldLabel => 'Your Top 10';

  @override
  String get askHint => 'tapas bars in Seville...';

  @override
  String get askSubmit => 'Generate ranking';

  @override
  String get rankingTitle => 'The ten';

  @override
  String get rankingDegradedNote => 'fewer than 10 good candidates this time';

  @override
  String get detailSourcesLabel => 'Sources';

  @override
  String get detailSourceLaunchFailed => 'Couldn\'t open that link.';

  @override
  String get errorNoConnection =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Try again in a moment.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get verifyingPhrase1 => 'Scouring the globe...';

  @override
  String get verifyingPhrase2 => 'Taste-testing restaurants...';

  @override
  String get verifyingPhrase3 => 'Reading a thousand reviews...';

  @override
  String get verifyingPhrase4 => 'Consulting the locals...';
}
