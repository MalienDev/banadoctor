class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String userType; // 'patient' or 'doctor'
  final String? profileImage;
  final String? specialization;
  final double? rating;
  final int? reviewCount;
  final String? address;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userType,
    this.profileImage,
    this.specialization,
    this.rating,
    this.reviewCount,
    this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      userType: json['user_type'],
      profileImage: json['profile_image'],
      specialization: json['specialization'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
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
      'profile_image': profileImage,
      'specialization': specialization,
      'rating': rating,
      'review_count': reviewCount,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullName => '$firstName $lastName';
}
