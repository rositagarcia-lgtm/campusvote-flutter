import 'common.dart';

/// `GET /fairs/:fairId/voting/status`.
class VotingStatusModel {
  const VotingStatusModel({
    required this.fairId,
    required this.fairStatus,
    required this.hasVoted,
    this.votedAt,
  });

  final String fairId;
  final FairStatus fairStatus;
  final bool hasVoted;
  final DateTime? votedAt;

  /// El voto solo se emite con la feria OPEN y sin haber votado.
  bool get isOpen => fairStatus == FairStatus.open;
  bool get canVote => isOpen && !hasVoted;

  factory VotingStatusModel.fromJson(Map<String, dynamic> json) =>
      VotingStatusModel(
        fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
        fairStatus:
            parseFairStatus(parseText(json['fair_status'] ?? json['fairStatus'])),
        hasVoted: (json['has_voted'] ?? json['hasVoted'] ?? false) == true,
        votedAt: parseDate(json['voted_at'] ?? json['votedAt']),
      );
}

/// Recibo anónimo de `POST /fairs/:fairId/votes`.
class VoteReceiptModel {
  const VoteReceiptModel({required this.status, required this.receiptCode});

  final String status;
  final String receiptCode;

  factory VoteReceiptModel.fromJson(Map<String, dynamic> json) =>
      VoteReceiptModel(
        status: parseText(json['status']) ?? 'CAST',
        receiptCode: parseText(json['receipt_code'] ?? json['receiptCode']) ?? '',
      );
}

/// Declaración derii neutro del jurado.
class JuryDeclarationModel {
  const JuryDeclarationModel({
    required this.id,
    required this.fairId,
    required this.statement,
    this.signedAt,
  });

  final String id;
  final String fairId;
  final String statement;
  final DateTime? signedAt;

  factory JuryDeclarationModel.fromJson(Map<String, dynamic> json) =>
      JuryDeclarationModel(
        id: parseText(json['id']) ?? '',
        fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
        statement: json['statement']?.toString() ?? '',
        signedAt: parseDate(json['signed_at'] ?? json['signedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fair_id': fairId,
        'statement': statement,
        'signed_at': signedAt?.toIso8601String(),
      };
}

/// `GET /fairs/:fairId/jury/declaration`.
class JuryDeclarationStatusModel {
  const JuryDeclarationStatusModel({
    required this.fairId,
    required this.signed,
    this.declaration,
  });

  final String fairId;
  final bool signed;
  final JuryDeclarationModel? declaration;

  factory JuryDeclarationStatusModel.fromJson(Map<String, dynamic> json) {
    final d = json['declaration'];
    return JuryDeclarationStatusModel(
      fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
      signed: (json['signed'] ?? false) == true,
      declaration: d is Map ? JuryDeclarationModel.fromJson(asMap(d)) : null,
    );
  }
}

/// `GET /fairs/my-progress/:fairId`.
class JuryProgressModel {
  const JuryProgressModel({
    required this.fairId,
    required this.totalProjects,
    required this.completedProjects,
    required this.pendingProjects,
    required this.progressPercentage,
    required this.hasVoted,
    this.fairName,
    this.fairStatus = FairStatus.unknown,
    this.declaration,
  });

  final String fairId;
  final String? fairName;
  final FairStatus fairStatus;
  final int totalProjects;
  final int completedProjects;
  final int pendingProjects;

  /// 0 – 100, redondeado por el backend.
  final int progressPercentage;
  final bool hasVoted;
  final JuryDeclarationModel? declaration;

  bool get isComplete =>
      totalProjects > 0 && completedProjects >= totalProjects;

  /// `JuryProgressBar`:evaluatedProjects / totalProjects.
  double get ratio =>
      totalProjects == 0 ? 0 : completedProjects / totalProjects;

  factory JuryProgressModel.fromJson(Map<String, dynamic> json) {
    final d = json['declaration'];
    return JuryProgressModel(
      fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
      fairName: parseText(json['fair_name'] ?? json['fairName']),
      fairStatus:
          parseFairStatus(parseText(json['fair_status'] ?? json['fairStatus'])),
      totalProjects: (json['total_projects'] ?? 0) as int,
      completedProjects: (json['completed_projects'] ?? 0) as int,
      pendingProjects: (json['pending_projects'] ?? 0) as int,
      progressPercentage: (json['progress_percentage'] ?? 0) as int,
      hasVoted: (json['has_voted'] ?? false) == true,
      declaration: d is Map ? JuryDeclarationModel.fromJson(asMap(d)) : null,
    );
  }
}
