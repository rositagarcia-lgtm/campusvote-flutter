import 'package:campusvote_flutter/core/branding/organization_branding.dart';
import 'package:campusvote_flutter/features/fair_voting/data/models/fair_assignment_model.dart';
import 'package:campusvote_flutter/features/fair_voting/domain/entities/fair_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrganizationBranding.fromOrganizationJson', () {
    test('lee primary_color / secondary_color del login (snake_case)', () {
      final b = OrganizationBranding.fromOrganizationJson({
        'id': 'org-1',
        'name': 'Universidad Demo',
        'logo': 'https://cdn.test/logo.png',
        'primary_color': '#112233',
        'secondary_color': '#AABBCC',
      });
      expect(b.id, 'org-1');
      expect(b.name, 'Universidad Demo');
      expect(b.logoUrl, 'https://cdn.test/logo.png');
      expect(b.primaryColor.toARGB32(), 0xFF112233);
      expect(b.secondaryColor.toARGB32(), 0xFFAABBCC);
    });

    test('lee primaryColor / secondaryColor de GET /organizations/:id', () {
      // El endpoint devuelve el registro crudo de Prisma (camelCase).
      final b = OrganizationBranding.fromOrganizationJson({
        'id': 'org-2',
        'name': 'Instituto Demo',
        'logo': '/uploads/logo.svg',
        'primaryColor': '#0A0B0C',
        'secondaryColor': '#FFFFFF',
      });
      expect(b.primaryColor.toARGB32(), 0xFF0A0B0C);
      expect(b.secondaryColor.toARGB32(), 0xFFFFFFFF);
      expect(b.logoUrl, '/uploads/logo.svg');
    });

    test('cae al fallback CampusVote con colores ausentes o inválidos', () {
      final b = OrganizationBranding.fromOrganizationJson({'id': 'org-3'});
      expect(b.name, 'CampusVote');
      expect(b.logoUrl, isNull);
      expect(
        b.primaryColor,
        OrganizationBranding.campusVoteFallback().primaryColor,
      );

      final invalid = OrganizationBranding.fromOrganizationJson({
        'id': 'org-4',
        'primaryColor': 'no-es-un-color',
      });
      expect(
        invalid.primaryColor,
        OrganizationBranding.campusVoteFallback().primaryColor,
      );
    });

    test('trata logo vacío como ausente', () {
      final b = OrganizationBranding.fromOrganizationJson({
        'id': 'org-5',
        'logo': '   ',
      });
      expect(b.logoUrl, isNull);
    });
  });

  group('FairAssignmentModel.fromJson — GET /fairs/my-assignments', () {
    test('parsea el sobre { assigned_at, fair: {...} }', () {
      final m = FairAssignmentModel.fromJson({
        'assigned_at': '2026-02-01T10:00:00.000Z',
        'fair': {
          'id': 'fair-1',
          'organization_id': 'org-1',
          'organization_name': 'Universidad Demo',
          'site_name': 'Sede Norte',
          'name': 'Feria de Ingeniería',
          'description': 'Proyectos 2026',
          'status': 'OPEN',
          'starts_at': '2026-03-01T00:00:00.000Z',
          'ends_at': '2026-03-05T00:00:00.000Z',
        },
      });
      expect(m.fairId, 'fair-1');
      expect(m.organizationId, 'org-1');
      expect(m.name, 'Feria de Ingeniería');
      expect(m.status, FairAssignmentStatus.open);
      expect(m.isOpen, isTrue);
      expect(m.organizationName, 'Universidad Demo');
      expect(m.siteName, 'Sede Norte');
      expect(m.assignedAt, DateTime.utc(2026, 2, 1, 10));
    });

    test('omite organization_name / site_name cuando llegan null', () {
      final m = FairAssignmentModel.fromJson({
        'assigned_at': '2026-02-01T10:00:00.000Z',
        'fair': {
          'id': 'fair-2',
          'name': 'Feria sin sede',
          'status': 'CLOSED',
          'organization_name': null,
          'site_name': null,
        },
      });
      expect(m.organizationName, isNull);
      expect(m.siteName, isNull);
      expect(m.status, FairAssignmentStatus.closed);
    });
  });
}
