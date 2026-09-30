import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/network/api_interceptor.dart';
import '../../data/datasources/auth_user_persister.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

final authUserPersisterProvider = Provider<AuthUserPersister>((ref) {
  final storage = ref.watch(localStorageProvider);
  return SharedPrefsAuthUserPersister(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // `AuthRepositoryImpl` implementa tanto `AuthRepository` como `AuthRefresher`,
  // por lo que el cast es seguro. El override real de `authRefresherProvider`
  // se hace en `app_bootstrap.dart` después de inicializar el repo.
  final baseRepo = AuthRepositoryImpl(
    client: ref.watch(apiClientProvider),
    persister: ref.watch(authUserPersisterProvider),
  );
  // Mantiene compatibilidad con el código previo (era un `.notifier` que
  // ya no existe; el `.read` simplemente fuerza la lectura del provider).
  ref.read(authRefresherProvider);
  return baseRepo;
});

/// Provider "override" del refresher para que el `AuthInterceptor`
/// pueda llamar `tryRefresh()` durante un 401.
final authRefresherOverrideProvider = Provider<AuthRefresher>((ref) {
  final repo = ref.watch(authRepositoryProvider) as AuthRepositoryImpl;
  return repo;
});

final loginUseCaseProvider =
    Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));

final verifyLoginTotpUseCaseProvider =
    Provider((ref) => VerifyLoginTotpUseCase(ref.watch(authRepositoryProvider)));

final requestEmailLoginUseCaseProvider =
    Provider((ref) => RequestEmailLoginUseCase(ref.watch(authRepositoryProvider)));

final verifyEmailLoginUseCaseProvider =
    Provider((ref) => VerifyEmailLoginUseCase(ref.watch(authRepositoryProvider)));

final refreshTokenUseCaseProvider =
    Provider((ref) => RefreshTokenUseCase(ref.watch(authRepositoryProvider)));

final getProfileUseCaseProvider =
    Provider((ref) => GetProfileUseCase(ref.watch(authRepositoryProvider)));

final logoutUseCaseProvider =
    Provider((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));

final changePasswordUseCaseProvider =
    Provider((ref) => ChangePasswordUseCase(ref.watch(authRepositoryProvider)));

final getTwoFactorStatusUseCaseProvider = Provider(
  (ref) => GetTwoFactorStatusUseCase(ref.watch(authRepositoryProvider)),
);
final setupTotpUseCaseProvider =
    Provider((ref) => SetupTotpUseCase(ref.watch(authRepositoryProvider)));
final verifyAndEnableTotpUseCaseProvider = Provider(
  (ref) => VerifyAndEnableTotpUseCase(ref.watch(authRepositoryProvider)),
);
final disableTotpUseCaseProvider =
    Provider((ref) => DisableTotpUseCase(ref.watch(authRepositoryProvider)));

final updateAvatarUseCaseProvider =
    Provider((ref) => UpdateAvatarUseCase(ref.watch(authRepositoryProvider)));

final updateProfileUseCaseProvider =
    Provider((ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)));