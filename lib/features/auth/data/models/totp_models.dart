import '../../domain/entities/totp.dart';

class TotpSetupModel extends TotpSetup {
  const TotpSetupModel({
    required super.secret,
    required super.uri,
    required super.qrCodeDataUrl,
  });

  factory TotpSetupModel.fromJson(Map<String, dynamic> json) {
    return TotpSetupModel(
      secret: (json['secret'] ?? '').toString(),
      uri: (json['uri'] ?? '').toString(),
      qrCodeDataUrl:
          (json['qrCode'] ?? json['qr_code'] ?? '').toString(),
    );
  }

  TotpSetup toEntity() => this;
}

class TotpEnableResultModel extends TotpEnableResult {
  const TotpEnableResultModel({
    required super.message,
    required super.backupCodes,
  });

  factory TotpEnableResultModel.fromJson(Map<String, dynamic> json) {
    final codes = (json['backupCodes'] is List)
        ? (json['backupCodes'] as List).map((e) => e.toString()).toList()
        : const <String>[];
    return TotpEnableResultModel(
      message: (json['message'] ?? '').toString(),
      backupCodes: codes,
    );
  }

  TotpEnableResult toEntity() => this;
}

class TotpStatusModel extends TotpStatus {
  const TotpStatusModel({
    required super.enabled,
    required super.backupCodesRemaining,
  });

  factory TotpStatusModel.fromJson(Map<String, dynamic> json) {
    return TotpStatusModel(
      enabled: (json['twoFactorEnabled'] ??
              json['two_factor_enabled'] ??
              false) ==
          true,
      backupCodesRemaining:
          (json['backupCodesRemaining'] ?? json['backup_codes_remaining'] ?? 0)
              as int,
    );
  }

  TotpStatus toEntity() => this;
}