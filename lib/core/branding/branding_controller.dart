import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/core_providers.dart';
import '../storage/local_storage.dart';
import 'organization_branding.dart';

/// Marca institucional activa.
///
/// Antes de identificar la organización la app usa el fallback neutral
/// `CampusVote`; apenas el backend resuelve el correo, `apply` pinta la
/// identidad real (logo + colores). La última marca se recuerda en disco para
/// que, al reabrir con sesión, el panel no arranque en teal y luego "salte" a
/// los colores de la organización cuando responde la API.
final brandingControllerProvider =
    StateNotifierProvider<BrandingController, OrganizationBranding>((ref) {
  LocalStorage? storage;
  try {
    storage = ref.watch(localStorageProvider);
  } catch (_) {
    // Tests y vistas aisladas no inicializan SharedPreferences: sin caché.
  }
  return BrandingController(storage: storage);
});

class BrandingController extends StateNotifier<OrganizationBranding> {
  BrandingController({LocalStorage? storage})
      : _storage = storage,
        super(OrganizationBranding.campusVoteFallback());

  static const _cacheKey = 'branding.organization';

  final LocalStorage? _storage;

  /// Aplica una marca institucional ya resuelta y la recuerda.
  void apply(OrganizationBranding branding) {
    if (branding.id == 'campusvote') return;
    state = branding;
    _storage?.setString(_cacheKey, jsonEncode(branding.toJson()));
  }

  /// Pinta la última marca conocida de [organizationId], si está guardada.
  ///
  /// Solo se usa al restaurar una sesión: la marca de otra organización
  /// nunca se aplica aunque siga en caché.
  void restoreCached(String? organizationId) {
    if (organizationId == null || organizationId.isEmpty) return;
    final raw = _storage?.getString(_cacheKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return;
      final cached =
          OrganizationBranding.fromOrganizationJson(Map.from(json).cast());
      if (cached.id == organizationId) state = cached;
    } catch (_) {
      _storage?.remove(_cacheKey);
    }
  }

  void reset() {
    state = OrganizationBranding.campusVoteFallback();
    _storage?.remove(_cacheKey);
  }
}
