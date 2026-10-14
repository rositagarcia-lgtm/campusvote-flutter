import 'package:campusvote_flutter/core/routing/deep_links.dart';
import 'package:campusvote_flutter/core/routing/role_landing.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:campusvote_flutter/features/jury/presentation/pages/jury_invitation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoSessionRepository implements AuthRepository {
  @override
  Future<bool> hasSession() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('El test no usa operaciones de sesión');
}

void main() {
  group('parseStandQr', () {
    test('lee la URL completa del QR impreso', () {
      expect(
        parseStandQr(
            'https://campusvote-front.onrender.com/ferias/f-1/proyectos/p-9'),
        ('f-1', 'p-9'),
      );
    });

    test('rechaza códigos que no son de un stand', () {
      expect(parseStandQr('https://otra.web/algo'), isNull);
      expect(parseStandQr('hola'), isNull);
      expect(parseStandQr('/ferias/f-1/otra/p-9'), isNull);
    });
  });

  group('PendingDeepLink', () {
    test('tras iniciar sesión se retoma el enlace una sola vez', () {
      PendingDeepLink.remember('/ferias/f-1/proyectos/p-9');
      expect(postLoginPath(AuthRole.student), '/ferias/f-1/proyectos/p-9');
      expect(postLoginPath(AuthRole.student), '/teaching');
    });

    test('reconoce los enlaces de la app', () {
      expect(isAppLink('/ferias/f/proyectos/p'), isTrue);
      expect(isAppLink('/j/invitacion'), isTrue);
      expect(isAppLink('/teaching'), isFalse);
    });
  });

  testWidgets('invitación sin sesión: valida la contraseña antes de enviar',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_NoSessionRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: JuryInvitationPage(token: 'a' * 64),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Te invitaron a ser jurado'), findsOneWidget);
    await tester.tap(find.text('Crear mi cuenta y aceptar'));
    await tester.pumpAndSettle();
    expect(find.text('La contraseña debe tener al menos 10 caracteres.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enlace incompleto: lo explica', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_NoSessionRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const JuryInvitationPage(token: ''),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('incompleto'), findsOneWidget);
  });
}
