import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'rendez_vous.g.dart';

enum AppointmentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('paid')
  paid,
}

@JsonSerializable()
class RendezVous {
  final String id;
  final User patient;
  final User doctor;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final String? notes;
  final AppointmentStatus status;
  final double? amount;
  final String? paymentReference;
  final DateTime? paymentDate;
  final String? meetingUrl; // For video consultations
  final DateTime createdAt;
  final DateTime updatedAt;

  RendezVous({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.notes,
    required this.status,
    this.amount,
    this.paymentReference,
    this.paymentDate,
    this.meetingUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) =>
      _$RendezVousFromJson(json);

  Map<String, dynamic> toJson() => _$RendezVousToJson(this);

  // Helper methods
  bool get isUpcoming =>
      status == AppointmentStatus.confirmed && startTime.isAfter(DateTime.now());

  bool get isPast =>
      status == AppointmentStatus.completed || startTime.isBefore(DateTime.now());

  bool get requiresPayment =>
      status == AppointmentStatus.pending && amount != null && amount! > 0;

  // Copy with method for immutability
  RendezVous copyWith({
    String? id,
    User? patient,
    User? doctor,
    DateTime? startTime,
    DateTime? endTime,
    String? reason,
    String? notes,
    AppointmentStatus? status,
    double? amount,
    String? paymentReference,
    DateTime? paymentDate,
    String? meetingUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RendezVous(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      doctor: doctor ?? this.doctor,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentDate: paymentDate ?? this.paymentDate,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
