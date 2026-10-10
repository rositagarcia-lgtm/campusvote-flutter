import 'package:campusvote_flutter/features/student_projects/domain/student_project.dart';
import 'package:campusvote_flutter/features/student_projects/presentation/widgets/project_visuals.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({String status = 'APPROVED', String fair = 'OPEN'}) => {
      'id': 'p-1',
      'name': 'Robot reciclador',
      'status': status,
      'my_role': 'EXPOSITOR',
      'stand': 'A-12',
      'category': 'Tecnología',
      'fair': {'id': 'f-1', 'name': 'Feria 2026', 'status': fair},
      'members': [
        {'name': 'Ana Ruiz', 'role': 'EXPOSITOR', 'is_me': true},
        {'name': 'Luis Paz', 'role': 'COLLABORATOR', 'is_me': false},
      ],
    };

void main() {
  test('lee el contrato de GET /projects/mine', () {
    final p = StudentProject.fromJson(_json());
    expect(p.name, 'Robot reciclador');
    expect(p.fair?.isOpen, isTrue);
    expect(p.members.first.isMe, isTrue);
    expect(p.members.first.initials, 'AR');
  });

  test('el recorrido refleja estado del proyecto y de la feria', () {
    expect(StudentProject.fromJson(_json(status: 'DRAFT')).stage,
        ProjectStage.registered);
    expect(StudentProject.fromJson(_json(status: 'SUBMITTED')).stage,
        ProjectStage.review);
    expect(StudentProject.fromJson(_json(status: 'REJECTED')).stage,
        ProjectStage.review);
    expect(StudentProject.fromJson(_json(fair: 'DRAFT')).stage,
        ProjectStage.approved);
    expect(StudentProject.fromJson(_json()).stage, ProjectStage.live);
    expect(StudentProject.fromJson(_json(fair: 'CLOSED')).stage,
        ProjectStage.finished);
  });

  test('solo hay valoración del jurado con proyecto aprobado en feria activa',
      () {
    expect(StudentProject.fromJson(_json()).hasFeedback, isTrue);
    expect(StudentProject.fromJson(_json(status: 'SUBMITTED')).hasFeedback,
        isFalse);
    expect(StudentProject.fromJson(_json(fair: 'DRAFT')).hasFeedback, isFalse);
  });

  test('feedback ignora comentarios vacíos', () {
    final f = ProjectFeedback.fromJson({
      'likes_count': 4,
      'comments': [
        {'comment': 'Muy buen prototipo', 'created_at': '2026-10-01T10:00:00Z'},
        {'comment': '  '},
      ],
    });
    expect(f.likes, 4);
    expect(f.comments, hasLength(1));
  });
}
