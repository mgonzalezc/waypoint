// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get askHeadline => 'Pregúntale al mapa lo que sea.';

  @override
  String get askFieldLabel => 'Tu Top 10';

  @override
  String get askHint => 'bares de tapas en Sevilla...';

  @override
  String get askSubmit => 'Generar ranking';

  @override
  String get rankingTitle => 'Los diez';

  @override
  String get rankingDegradedNote => 'menos de 10 buenos candidatos esta vez';

  @override
  String get errorNoConnection =>
      'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get errorServiceUnavailable =>
      'El servicio no está disponible temporalmente. Inténtalo en unos minutos.';

  @override
  String get errorUnexpected => 'Algo ha salido mal. Inténtalo de nuevo.';

  @override
  String get verifyingPhrase1 => 'Buscando por el mundo...';

  @override
  String get verifyingPhrase2 => 'Probando restaurantes...';

  @override
  String get verifyingPhrase3 => 'Leyendo miles de reseñas...';

  @override
  String get verifyingPhrase4 => 'Consultando a los locales...';
}
