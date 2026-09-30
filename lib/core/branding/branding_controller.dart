import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../branding/organization_branding.dart';

/// Marca institucional activa durante el pre-login.
///
/// Antes de identificar la organización la app usa el fallback neutral
/// `CampusVote`; apenas el backend resuelve el correo, `applyFromAuth` pinta
/// la identidad real (logo + colores) en el splash, el OTP y el login.
final brandingControllerProvider =
    StateNotifierProvider<BrandingController, OrganizationBranding>((ref) {
  return BrandingController();
});

class BrandingController extends StateNotifier<OrganizationBranding> {
  BrandingController() : super(OrganizationBranding.campusVoteFallback());

  /// Aplica una marca institucional ya resuelta (login sin contraseña).
  void apply(OrganizationBranding branding) {
    if (branding.id == 'campusvote') return;
    state = branding;
  }

  void reset() => state = OrganizationBranding.campusVoteFallback();
}