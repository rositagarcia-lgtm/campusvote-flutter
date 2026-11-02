import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/endpoints.dart';
import '../di/core_providers.dart';
import '../settings/app_preferences.dart';

/// Traduce un texto escrito por usuarios con `POST /api/translate`.
/// El backend guarda cada traducción en caché.
final contentTranslationProvider = FutureProvider.autoDispose
    .family<String, ({String text, String target})>((ref, args) async {
  final client = ref.watch(apiClientProvider);
  return _translateChunked(client, args.text, args.target);
});

Future<String> _translateChunked(dynamic client, String text, String target) async {
  const limit = 2000;
  if (text.length <= limit) return _translateOne(client, text, target);
  final buffer = StringBuffer();
  for (var start = 0; start < text.length; start += limit) {
    final end = start + limit > text.length ? text.length : start + limit;
    buffer.write(await _translateOne(client, text.substring(start, end), target));
  }
  return buffer.toString();
}

Future<String> _translateOne(dynamic client, String text, String target) async {
  final res = await client.post(
    ApiEndpoints.translate,
    body: {
      'texts': [text],
      'target': target,
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
}

/// Texto que cambia en cada feria: descripción, comentario, criterio u observación.
///
/// En español se muestra tal como se escribió. En inglés se traduce solo al
/// elegir el idioma. Los nombres de personas, ferias y proyectos no pasan por aquí.
class TranslatableText extends ConsumerWidget {
  const TranslatableText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(appPreferencesProvider.select((p) => p.language));
    if (language != AppLanguage.english || text.trim().isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }
    final translated = ref.watch(
      contentTranslationProvider((text: text, target: language.code)),
    );
    return Text(
      translated.valueOrNull ?? text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
