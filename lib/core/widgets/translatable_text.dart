import 'package:dio/dio.dart';
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

bool _useful(String? value, String source) {
  if (value == null) return false;
  final text = value.trim();
  if (text.isEmpty || text.toUpperCase().startsWith('MYMEMORY WARNING')) {
    return false;
  }
  return text.toLowerCase() != source.trim().toLowerCase();
}

String? _pickMyMemory(Map body, String source) {
  final data = body['responseData'];
  final top = data is Map ? data['translatedText']?.toString() : null;
  if (_useful(top, source)) return top;
  final matches = body['matches'];
  if (matches is! List) return null;
  String? best;
  var bestScore = -1.0;
  for (final item in matches) {
    if (item is! Map) continue;
    final value = item['translation']?.toString();
    if (!_useful(value, source)) continue;
    final score =
        item['match'] is num ? (item['match'] as num).toDouble() : 0.0;
    if (score > bestScore) {
      bestScore = score;
      best = value;
    }
  }
  return best;
}

/// El servidor traduce con la sesión. Si no responde, o devuelve el mismo
/// texto, se consulta el mismo servicio desde el teléfono.
Future<String> _translateOne(dynamic client, String text, String target) async {
  try {
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
    final value = list is List && list.isNotEmpty ? list.first.toString() : null;
    if ((res.statusCode ?? 500) < 400 && _useful(value, text)) return value!;
  } catch (_) {}
  return _translateOnDevice(text, target);
}

Future<String> _translateOnDevice(String text, String target) async {
  final pair = target == 'en' ? 'es|en' : 'en|es';
  try {
    final res = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    ).get<dynamic>(
      'https://api.mymemory.translated.net/get',
      queryParameters: {'q': text, 'langpair': pair},
    );
    final body = res.data;
    if (body is Map) {
      final picked = _pickMyMemory(body, text);
      if (picked != null) return picked;
    }
  } catch (_) {}
  return text;
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
