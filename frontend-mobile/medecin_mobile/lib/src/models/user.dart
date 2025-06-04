class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String userType; // 'doctor' or 'patient'
  final String? profileImageUrl;
  final String? speciality; // Only for doctors
  final double? rating; // Only for doctors
  final int? yearsOfExperience; // Only for doctors
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.speciality,
    this.rating,
    this.yearsOfExperience,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      userType: json['user_type'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      speciality: json['speciality'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      yearsOfExperience: json['years_of_experience'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'profile_image_url': profileImageUrl,
      'speciality': speciality,
      'rating': rating,
      'years_of_experience': yearsOfExperience,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
