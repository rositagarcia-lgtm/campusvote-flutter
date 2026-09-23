import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/voting_receipt.dart';
import '../../domain/entities/voting_session.dart';
import '../models/receipt_model.dart';
import '../models/voting_session_model.dart';
import 'voting_api_mapper.dart';

/// MǸtodos de sesi��n + emisi��n del voto.
class VotingSessionAndCast {
  VotingSessionAndCast(this._readClient);

  final dynamic Function() _readClient; // () => ApiClient

  Future<Result<VotingSession>> startSession(
    String electionId, {
    String? votingToken,
  }) async {
    final client = _readClient();
    try {
      final res = await client.post(
        ApiEndpoints.votingSession(electionId),
        body: votingToken != null ? {'votingToken': votingToken} : null,
      );
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      return Success(
        VotingSessionModel.fromJson(r.data!).toEntity(),
      );
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<VotingSession>> getSession(String sessionId) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.votingSessionStatus(sessionId));
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      return Success(VotingSessionModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<VotingReceipt>> castVote({
    required String sessionId,
    required String payloadHash,
    required String encryptedPayload,
    required List<Map<String, dynamic>> selections,
  }) async {
    final client = _readClient();
    try {
      final res = await client.post(
        ApiEndpoints.castVote(sessionId),
        body: {
          'encryptedPayload': encryptedPayload,
          'payloadHash': payloadHash,
          'selections': selections,
        },
      );
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      // El backend en /cast solo devuelve { receiptCode, status, message };
      // castAt se conoce localmente como aproximación y se reemplazará al
      // verificar el comprobante.
      final raw = Map<String, dynamic>.from(r.data!);
      raw['castAt'] ??= DateTime.now().toIso8601String();
      final receipt = ReceiptModel.fromJson(raw).toEntity();
      return Success(receipt);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<VotingReceipt>> verifyReceipt(String receiptCode) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.verifyReceipt(receiptCode));
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      final valid = (r.data!['valid'] ?? false) as bool;
      if (!valid) {
        return const FailureResult(NotFoundFailure(
          message: 'El comprobante no corresponde a un voto registrado.',
        ));
      }
      return Success(ReceiptModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }
}