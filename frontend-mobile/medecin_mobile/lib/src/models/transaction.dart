import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

enum TransactionType {
  @JsonValue('appointment')
  appointment,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('refund')
  refund,
}

@JsonSerializable()
class Transaction {
  final String id;
  final String reference;
  final double amount;
  final double? fee;
  final String currency;
  final TransactionStatus status;
  final TransactionType type;
  final String? description;
  final String? metadata; // JSON string for additional data
  final String? paymentMethod; // 'card', 'mobile_money', etc.
  final String? paymentProvider; // 'flutterwave', 'paystack', etc.
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.reference,
    required this.amount,
    this.fee,
    this.currency = 'XOF',
    required this.status,
    required this.type,
    this.description,
    this.metadata,
    this.paymentMethod,
    this.paymentProvider,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  // Helper methods
  bool get isSuccessful => status == TransactionStatus.completed;
  
  String get formattedAmount => '$amount $currency';
  
  String get formattedFee => fee != null ? '${fee!.toStringAsFixed(2)} $currency' : 'N/A';
  
  String get formattedTotal => fee != null 
      ? '${(amount + fee!).toStringAsFixed(2)} $currency' 
      : formattedAmount;

  // Copy with method for immutability
  Transaction copyWith({
    String? id,
    String? reference,
    double? amount,
    double? fee,
    String? currency,
    TransactionStatus? status,
    TransactionType? type,
    String? description,
    String? metadata,
    String? paymentMethod,
    String? paymentProvider,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      type: type ?? this.type,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
