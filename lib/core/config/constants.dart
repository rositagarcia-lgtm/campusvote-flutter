/// Constantes transversales de la aplicación.
class AppConstants {
  const AppConstants._();

  static const String appName = 'CampusVote';
  static const Duration networkConnectTimeout = Duration(seconds: 15);
  static const Duration networkReceiveTimeout = Duration(seconds: 30);
  static const Duration networkSendTimeout = Duration(seconds: 30);

  // Keys secure storage
  static const String secureAccessToken = 'cv.access_token';
  static const String secureRefreshToken = 'cv.refresh_token';

  // Keys local storage
  static const String prefsUserId = 'cv.user_id';
  static const String prefsOrganizationId = 'cv.organization_id';
  static const String prefsLastElectionId = 'cv.last_election_id';
  static const String prefsOnboardingDone = 'cv.onboarding_done';
}