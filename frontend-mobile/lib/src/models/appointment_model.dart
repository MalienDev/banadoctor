import 'package:medecin_mobile/src/models/user_model.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow,
  paymentPending,
}

class Appointment {
  final int id;
  final User patient;
  final User doctor;
  final DateTime appointmentDate;
  final String timeSlot;
  final String? reason;
  final String? notes;
  final AppointmentStatus status;
  final String? prescription;
  final double? amount;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paymentDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.appointmentDate,
    required this.timeSlot,
    this.reason,
    this.notes,
    required this.status,
    this.prescription,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patient: User.fromJson(json['patient']),
      doctor: User.fromJson(json['doctor']),
      appointmentDate: DateTime.parse(json['appointment_date']),
      timeSlot: json['time_slot'],
      reason: json['reason'],
      notes: json['notes'],
      status: _parseStatus(json['status']),
      prescription: json['prescription'],
      amount: json['amount']?.toDouble(),
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  static AppointmentStatus _parseStatus(String status) {
    switch (status) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'payment_pending':
        return AppointmentStatus.paymentPending;
      case 'pending':
      default:
        return AppointmentStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.completed:
        return 'Terminé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.noShow:
        return 'Non présenté';
      case AppointmentStatus.paymentPending:
        return 'En attente de paiement';
      case AppointmentStatus.pending:
      default:
        return 'En attente';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patient.toJson(),
      'doctor': doctor.toJson(),
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot,
      'reason': reason,
      'notes': notes,
      'status': status.toString().split('.').last,
      'prescription': prescription,
      'amount': amount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
