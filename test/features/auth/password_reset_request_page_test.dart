import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:campusvote_flutter/features/auth/presentation/pages/password_reset_request_page.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecoveryRepo implements AuthRepository {
  String? requestedEmail;

  @override
  Future<Result<void>> requestPasswordReset({required String email}) async {
    requestedEmail = email;
    return const Success(null);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('recuperación valida el correo y confirma solo tras la respuesta',
      (tester) async {
    final repo = _RecoveryRepo();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        requestPasswordResetUseCaseProvider.overrideWithValue(
          RequestPasswordResetUseCase(repo),
        ),
      ],
      child: const MaterialApp(home: PasswordResetRequestPage()),
    ));

    await tester.tap(find.text('Enviar enlace de recuperación'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(repo.requestedEmail, isNull);

    await tester.enterText(find.byType(TextFormField), '  Jurado@Uni.edu ');
    await tester.tap(find.text('Enviar enlace de recuperación'));
    await tester.pumpAndSettle();
    expect(repo.requestedEmail, 'jurado@uni.edu');
    expect(find.textContaining('Solicitud recibida'), findsOneWidget);
  });
}
