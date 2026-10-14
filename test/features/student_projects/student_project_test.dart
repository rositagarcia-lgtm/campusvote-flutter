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
      'logo_url': 'https://media.example/logos/file.png',
      'video_url': 'https://media.example/archivos/file.mp4',
      'image_urls': ['https://media.example/ferias/foto.jpg'],
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
    expect(p.logoUrl, 'https://media.example/logos/file.png');
    expect(p.videoUrl, 'https://media.example/archivos/file.mp4');
    expect(p.imageUrls, ['https://media.example/ferias/foto.jpg']);
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

  test('las estrellas y el voto se consultan al cerrar la feria', () {
    expect(StudentProject.fromJson(_json(fair: 'CLOSED')).hasFeedback, isTrue);
    expect(StudentProject.fromJson(_json()).hasFeedback, isFalse);
    expect(
        StudentProject.fromJson(_json(status: 'SUBMITTED', fair: 'CLOSED'))
            .hasFeedback,
        isFalse);
  });

  test('la valoración lee estrellas y votos, sin me gusta', () {
    final f = ProjectFeedback.fromJson({
      'votes': 4,
      'reviews': [
        {
          'rating': 5,
          'comment': 'Muy buen prototipo',
          'created_at': '2026-10-01T10:00:00Z',
        },
        {'rating': 3, 'comment': '  '},
        {'rating': 9, 'comment': 'Fuera de rango'},
      ],
    });
    expect(f.published, isTrue);
    expect(f.votes, 4);
    expect(f.reviews, hasLength(2));
    expect(f.reviews.first.rating, 5);
    expect(f.reviews.last.comment, isNull);
    expect(f.average, 4);
  });
}
