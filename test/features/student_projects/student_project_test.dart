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

  test('las reseñas del jurado se ven durante la feria y 7 días después', () {
    expect(StudentProject.fromJson(_json()).hasFeedback, isTrue);
    expect(StudentProject.fromJson(_json(fair: 'DRAFT')).hasFeedback, isFalse);
    final closed = _json(fair: 'CLOSED');
    (closed['fair'] as Map)['ends_at'] =
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
    expect(StudentProject.fromJson(closed).hasFeedback, isTrue);
    (closed['fair'] as Map)['ends_at'] =
        DateTime.now().subtract(const Duration(days: 8)).toIso8601String();
    expect(StudentProject.fromJson(closed).hasFeedback, isFalse);
    expect(StudentProject.fromJson(_json(status: 'SUBMITTED')).hasFeedback,
        isFalse);
  });

  test('sin resultados publicados no llega el conteo de votos', () {
    final f = ProjectFeedback.fromJson({'votes': null, 'reviews': []});
    expect(f.votes, isNull);
    final note = ProjectReview.juryComment({'comment': ' Mejoren la demo '});
    expect(note?.comment, 'Mejoren la demo');
    expect(ProjectReview.juryComment({'comment': '  '}), isNull);
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
