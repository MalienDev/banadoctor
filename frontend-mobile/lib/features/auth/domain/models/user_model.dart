import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImageUrl,
    @Default('patient') String role,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  const User._();

  String get fullName => '$firstName $lastName';
}

enum UserRole {
  patient('patient'),
  doctor('doctor'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient,
    );
  }

  bool get isPatient => this == UserRole.patient;
  bool get isDoctor => this == UserRole.doctor;
  bool get isAdmin => this == UserRole.admin;
}
