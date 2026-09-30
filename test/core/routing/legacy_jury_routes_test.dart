import 'package:campusvote_flutter/core/routing/legacy_jury_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('legacyJuryRedirect', () {
    test('manda la raíz antigua al dashboard', () {
      expect(legacyJuryRedirect('/juries'), '/jury');
      expect(legacyJuryRedirect('/juries/fairs'), '/jury');
    });

    test('traduce la lista de proyectos', () {
      expect(
        legacyJuryRedirect('/juries/fairs/fair-1/projects'),
        '/jury/fair/fair-1',
      );
    });

    test('traduce la rúbrica conservando el id del proyecto', () {
      expect(
        legacyJuryRedirect('/juries/fairs/fair-1/projects/proj-9/rubric'),
        '/jury/fair/fair-1/project/proj-9/rubric',
      );
    });

    test('traduce el paso de votación y su recibo a la misma pantalla', () {
      expect(
        legacyJuryRedirect('/juries/fairs/fair-1/voting'),
        '/jury/fair/fair-1/vote',
      );
      // El recibo ya se muestra dentro de `VotingPage`.
      expect(
        legacyJuryRedirect('/juries/fairs/fair-1/voting/success'),
        '/jury/fair/fair-1/vote',
      );
    });

    test('cubre los ids de uuid sin romperse', () {
      expect(
        legacyJuryRedirect(
          '/juries/fairs/02927ba0-887d-4973-a8d8-0d5d4e2a0d7f/projects/'
          'aa11bb22-cc33-dd44-ee55-ff6677889900/rubric',
        ),
        '/jury/fair/02927ba0-887d-4973-a8d8-0d5d4e2a0d7f/project/'
        'aa11bb22-cc33-dd44-ee55-ff6677889900/rubric',
      );
    });

    test('una subruta desconocida cae en la pantalla de la feria', () {
      expect(
        legacyJuryRedirect('/juries/fairs/fair-1/ranking'),
        '/jury/fair/fair-1',
      );
    });

    test('ignora rutas que no son del panel legado', () {
      expect(legacyJuryRedirect('/splash'), isNull);
      expect(legacyJuryRedirect('/jury/fair/fair-1'), isNull);
      expect(legacyJuryRedirect('/teaching'), isNull);
      expect(legacyJuryRedirect('/auth/jury/login'), isNull);
      expect(legacyJuryRedirect('/juriesx'), isNull);
      expect(legacyJuryRedirect(''), isNull);
    });
  });

  group('isJuryPanelPath', () {
    test('reconoce el panel canónico y no confunde prefijos', () {
      expect(isJuryPanelPath('/jury'), isTrue);
      expect(isJuryPanelPath('/jury/fair/fair-1/vote'), isTrue);
      expect(isJuryPanelPath('/juries'), isFalse);
      expect(isJuryPanelPath('/teaching'), isFalse);
      expect(isJuryPanelPath('/auth/jury/login'), isFalse);
      expect(isJuryPanelPath('/'), isFalse);
    });
  });
}
