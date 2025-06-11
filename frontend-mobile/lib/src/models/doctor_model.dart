class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double distance;
  final String? imageUrl;
  final String? location;
  final String? description;
  final List<String>? languages;
  final int experienceYears;
  final double consultationFee;
  final bool isAvailable;
  final bool isFavorite;
  final List<String>? education;
  final List<String>? specialties;
  final List<Map<String, dynamic>>? availability;
  final List<Map<String, dynamic>>? reviews;
  final Map<String, dynamic>? contactInfo;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distance = 0.0,
    this.imageUrl,
    this.location,
    this.description,
    this.languages,
    this.experienceYears = 0,
    this.consultationFee = 0.0,
    this.isAvailable = true,
    this.isFavorite = false,
    this.education,
    this.specialties,
    this.availability,
    this.reviews,
    this.contactInfo,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? 'Médecin généraliste',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      distance: (json['distance'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      location: json['location'],
      description: json['description'],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages']) 
          : null,
      experienceYears: json['experience_years'] ?? 0,
      consultationFee: (json['consultation_fee'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      isFavorite: json['is_favorite'] ?? false,
      education: json['education'] != null 
          ? List<String>.from(json['education']) 
          : null,
      specialties: json['specialties'] != null 
          ? List<String>.from(json['specialties']) 
          : null,
      availability: json['availability'] != null 
          ? List<Map<String, dynamic>>.from(json['availability'])
          : null,
      reviews: json['reviews'] != null 
          ? List<Map<String, dynamic>>.from(json['reviews'])
          : null,
      contactInfo: json['contact_info'] != null 
          ? Map<String, dynamic>.from(json['contact_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'review_count': reviewCount,
      'distance': distance,
      'image_url': imageUrl,
      'location': location,
      'description': description,
      'languages': languages,
      'experience_years': experienceYears,
      'consultation_fee': consultationFee,
      'is_available': isAvailable,
      'is_favorite': isFavorite,
      'education': education,
      'specialties': specialties,
      'availability': availability,
      'reviews': reviews,
      'contact_info': contactInfo,
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    double? rating,
    int? reviewCount,
    double? distance,
    String? imageUrl,
    String? location,
    String? description,
    List<String>? languages,
    int? experienceYears,
    double? consultationFee,
    bool? isAvailable,
    bool? isFavorite,
    List<String>? education,
    List<String>? specialties,
    List<Map<String, dynamic>>? availability,
    List<Map<String, dynamic>>? reviews,
    Map<String, dynamic>? contactInfo,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      description: description ?? this.description,
      languages: languages ?? this.languages,
      experienceYears: experienceYears ?? this.experienceYears,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      education: education ?? this.education,
      specialties: specialties ?? this.specialties,
      availability: availability ?? this.availability,
      reviews: reviews ?? this.reviews,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  String get formattedRating => rating.toStringAsFixed(1);
  
  String get formattedDistance => '${distance.toStringAsFixed(1)} km';
  
  String get formattedExperience => 
      experienceYears > 0 
          ? '$experienceYears+ ans d\'expérience' 
          : 'Nouveau';
          
  String get formattedFee => '${consultationFee.toStringAsFixed(0)} FCFA';
  
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'D';
}
