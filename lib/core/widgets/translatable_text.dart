import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/settings_copy.dart';
import '../config/endpoints.dart';
import '../di/core_providers.dart';
import '../settings/app_preferences.dart';
import '../theme/app_icons.dart';

/// Traduce un texto escrito por usuarios con `POST /api/translate`.
/// El backend guarda cada traducción en caché.
final contentTranslationProvider = FutureProvider.autoDispose
    .family<String, ({String text, String target})>((ref, args) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.post(
    ApiEndpoints.translate,
    body: {
      'texts': [args.text],
      'target': args.target,
    },
  );
  final body = res.data;
  final list = body is Map && body['data'] is Map
      ? (body['data'] as Map)['translations']
      : null;
  if ((res.statusCode ?? 500) >= 400 || list is! List || list.isEmpty) {
    throw StateError('translation unavailable');
  }
  return list.first.toString();
});

/// Texto de contenido (descripción, comentario) con opción de traducirlo.
///
/// La interfaz ya está traducida por la app; lo que escribe la gente queda en
/// su idioma original. Con la app en inglés aparece "See translation", y se
/// puede volver al original en cualquier momento.
class TranslatableText extends ConsumerStatefulWidget {
  const TranslatableText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  ConsumerState<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends ConsumerState<TranslatableText> {
  bool _translated = false;

  @override
  Widget build(BuildContext context) {
    final language =
        ref.watch(appPreferencesProvider.select((p) => p.language));
    final copy = SettingsCopy.of(context);
    // El contenido se escribe en español: solo se ofrece traducir a inglés.
    if (language != AppLanguage.english) {
      return Text(widget.text, style: widget.style);
    }

    final theme = Theme.of(context);
    final args = (text: widget.text, target: language.code);
    final translation =
        _translated ? ref.watch(contentTranslationProvider(args)) : null;
    final shown = translation?.valueOrNull ?? widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(shown, key: ValueKey(shown), style: widget.style),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: theme.textTheme.labelMedium,
          ),
          onPressed: translation?.isLoading == true
              ? null
              : () => setState(() => _translated = !_translated),
          icon: translation?.isLoading == true
              ? const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(PhosphorIconsRegular.globe, size: 16),
          label: Text(
            translation?.hasError == true
                ? copy.t('Traducción no disponible')
                : _translated
                    ? copy.t('Ver original')
                    : copy.t('Ver traducción'),
          ),
        ),
      ],
    );
  }
}
