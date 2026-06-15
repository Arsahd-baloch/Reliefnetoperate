import 'package:reliefnet_app/utils/safe_parser.dart';

class NgoProfileModel {
  final int id;
  final int userId;
  final String orgName;
  final String? description;
  final String status;
  final double walletBalance;
  final String? bankName;
  final String? accountTitle;
  final String? accountNumber;
  final String? verifiedAt;
  final String? createdAt;

  NgoProfileModel({
    required this.id,
    required this.userId,
    required this.orgName,
    this.description,
    required this.status,
    required this.walletBalance,
    this.bankName,
    this.accountTitle,
    this.accountNumber,
    this.verifiedAt,
    this.createdAt,
  });

  factory NgoProfileModel.fromJson(Map<String, dynamic> json) {
    return NgoProfileModel(
      id: SafeParser.paramInt(json['id']),
      userId: SafeParser.paramInt(json['user_id']),
      orgName: SafeParser.toStringSafe(json['org_name']),
      description: json['description'] != null ? SafeParser.toStringSafe(json['description']) : null,
      status: SafeParser.toStringSafe(json['status'], defaultValue: 'PENDING'),
      walletBalance: SafeParser.toDouble(json['wallet_balance']),
      bankName: json['bank_name'] != null ? SafeParser.toStringSafe(json['bank_name']) : null,
      accountTitle: json['account_title'] != null ? SafeParser.toStringSafe(json['account_title']) : null,
      accountNumber: json['account_number'] != null ? SafeParser.toStringSafe(json['account_number']) : null,
      verifiedAt: json['verified_at'] != null ? SafeParser.toStringSafe(json['verified_at']) : null,
      createdAt: json['created_at'] != null ? SafeParser.toStringSafe(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_name': orgName,
      'description': description,
      'bank_name': bankName,
      'account_title': accountTitle,
      'account_number': accountNumber,
    };
  }
}
