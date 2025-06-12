import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'profile_picture') String? profileImageUrl,
    @JsonKey(name: 'user_type') @Default(UserRole.patient) UserRole userType,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
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
