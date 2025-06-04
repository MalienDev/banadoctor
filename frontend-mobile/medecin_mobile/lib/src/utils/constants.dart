import 'package:flutter/material.dart';

// App Colors
const Color kPrimaryColor = Color(0xFF2E7D32); // Green 800
const Color kPrimaryLightColor = Color(0xFF60AD5E); // Green 600
const Color kPrimaryDarkColor = Color(0xFF005005); // Green 900
const Color kSecondaryColor = Color(0xFFFFC107); // Amber
const Color kAccentColor = Color(0xFF03A9F4); // Light Blue 500
const Color kErrorColor = Color(0xFFE53935); // Red 600
const Color kSuccessColor = Color(0xFF43A047); // Green 600
const Color kWarningColor = Color(0xFFFFA000); // Amber 700
const Color kInfoColor = Color(0xFF1976D2); // Blue 700

// Text Colors
const Color kTextPrimaryColor = Color(0xFF212121); // Grey 900
const Color kTextSecondaryColor = Color(0xFF757575); // Grey 600
const Color kTextHintColor = Color(0xFF9E9E9E); // Grey 500
const Color kTextDisabledColor = Color(0xFFBDBDBD); // Grey 400
const Color kTextLightColor = Color(0xFFFFFFFF); // White

// Background Colors
const Color kBackgroundColor = Color(0xFFF5F5F5); // Grey 100
const Color kCardColor = Color(0xFFFFFFFF); // White
const Color kScaffoldBackgroundColor = Color(0xFFFAFAFA); // Grey 50

// Border Colors
const Color kBorderColor = Color(0xFFE0E0E0); // Grey 300
const Color kDividerColor = Color(0xFFEEEEEE); // Grey 200

// Status Colors
const Color kStatusPendingColor = Color(0xFFFFA000); // Amber 700
const Color kStatusConfirmedColor = Color(0xFF43A047); // Green 600
const Color kStatusCancelledColor = Color(0xFFE53935); // Red 600
const Color kStatusCompletedColor = Color(0xFF1976D2); // Blue 700
const Color kStatusNoShowColor = Color(0xFF7B1FA2); // Purple 700

// Gradient Colors
const LinearGradient kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, kPrimaryLightColor],
);

// Spacing
const double kDefaultPadding = 16.0;
const double kDefaultMargin = 16.0;
const double kDefaultBorderRadius = 8.0;
const double kDefaultButtonHeight = 48.0;
const double kDefaultAppBarHeight = 56.0;
const double kDefaultIconSize = 24.0;

// Animation Durations
const Duration kDefaultAnimationDuration = Duration(milliseconds: 300);
const Duration kDefaultSplashAnimationDuration = Duration(milliseconds: 100);
const Duration kDefaultPageTransitionDuration = Duration(milliseconds: 250);

// API Constants
const String kApiBaseUrl = 'https://api.medecinafrica.com/v1';
const Duration kApiTimeout = Duration(seconds: 30);

// Local Storage Keys
const String kAuthTokenKey = 'auth_token';
const String kRefreshTokenKey = 'refresh_token';
const String kUserDataKey = 'user_data';
const String kFcmTokenKey = 'fcm_token';
const String kLanguageKey = 'language';
const String kThemeModeKey = 'theme_mode';

// Date & Time Formats
const String kDateFormat = 'dd/MM/yyyy';
const String kTimeFormat = 'HH:mm';
const String kDateTimeFormat = 'dd/MM/yyyy HH:mm';
const String kApiDateFormat = 'yyyy-MM-dd';
const String kApiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

// Assets
class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String logoTransparent = 'assets/images/logo_transparent.png';
  static const String doctorPlaceholder = 'assets/images/doctor_placeholder.png';
  static const String patientPlaceholder = 'assets/images/patient_placeholder.png';
  static const String avatarPlaceholder = 'assets/images/avatar_placeholder.png';
  static const String consultationIllustration = 'assets/images/consultation_illustration.png';
  static const String doctorIllustration = 'assets/images/doctor_illustration.png';
  static const String patientIllustration = 'assets/images/patient_illustration.png';
  static const String appointmentIllustration = 'assets/images/appointment_illustration.png';
  
  // Icons
  static const String icAppointment = 'assets/icons/ic_appointment.svg';
  static const String icDoctor = 'assets/icons/ic_doctor.svg';
  static const String icPatient = 'assets/icons/ic_patient.svg';
  static const String icHospital = 'assets/icons/ic_hospital.svg';
  static const String icMedication = 'assets/icons/ic_medication.svg';
  static const String icPrescription = 'assets/icons/ic_prescription.svg';
  static const String icLabTest = 'assets/icons/ic_lab_test.svg';
  static const String icAmbulance = 'assets/icons/ic_ambulance.svg';
  static const String icEmergency = 'assets/icons/ic_emergency.svg';
  static const String icVideoCall = 'assets/icons/ic_video_call.svg';
  static const String icChat = 'assets/icons/ic_chat.svg';
  static const String icPhone = 'assets/icons/ic_phone.svg';
  static const String icLocation = 'assets/icons/ic_location.svg';
  static const String icCalendar = 'assets/icons/ic_calendar.svg';
  static const String icClock = 'assets/icons/ic_clock.svg';
  static const String icStar = 'assets/icons/ic_star.svg';
  static const String icStarFilled = 'assets/icons/ic_star_filled.svg';
  static const String icVerified = 'assets/icons/ic_verified.svg';
  static const String icPayment = 'assets/icons/ic_payment.svg';
  static const String icNotification = 'assets/icons/ic_notification.svg';
  static const String icSettings = 'assets/icons/ic_settings.svg';
  static const String icHelp = 'assets/icons/ic_help.svg';
  static const String icLogout = 'assets/icons/ic_logout.svg';
}

// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Médecin Africa';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Plateforme de prise de rendez-vous médicaux en Afrique';
  
  // Contact Info
  static const String supportEmail = 'support@medecinafrica.com';
  static const String supportPhone = '+221 33 123 45 67';
  static const String companyAddress = 'Dakar, Sénégal';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/medecinafrica';
  static const String twitterUrl = 'https://twitter.com/medecinafrica';
  static const String instagramUrl = 'https://instagram.com/medecinafrica';
  static const String linkedinUrl = 'https://linkedin.com/company/medecinafrica';
  static const String youtubeUrl = 'https://youtube.com/medecinafrica';
  
  // App Store Links
  static const String appStoreUrl = 'https://apps.apple.com/app/medecin-africa/id123456789';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.medecinafrica.app';
  
  // Other Constants
  static const int maxFailedLoginAttempts = 5;
  static const int otpExpiryMinutes = 10;
  static const int maxImageSizeMB = 5;
  static const int maxFileSizeMB = 10;
  static const int paginationLimit = 10;
  static const int maxAppointmentDaysInAdvance = 90;
  static const int appointmentReminderHours = 24;
  static const int appointmentCancellationHours = 2;
}

// Helper Functions
double getResponsiveFontSize(double fontSize) {
  // This would be replaced with a more sophisticated calculation
  // based on the device screen size and orientation
  return fontSize;
}

EdgeInsets getResponsivePadding() {
  // This would be replaced with a more sophisticated calculation
  // based on the device screen size and orientation
  return const EdgeInsets.all(kDefaultPadding);
}

// Text Styles
TextStyle getHeadline1Style(BuildContext context) {
  return Theme.of(context).textTheme.headline1?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: kTextPrimaryColor,
      ) ??
      const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: kTextPrimaryColor,
      );
}

TextStyle getHeadline2Style(BuildContext context) {
  return Theme.of(context).textTheme.headline2?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: kTextPrimaryColor,
      ) ??
      const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: kTextPrimaryColor,
      );
}

TextStyle getHeadline3Style(BuildContext context) {
  return Theme.of(context).textTheme.headline3?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: kTextPrimaryColor,
      ) ??
      const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: kTextPrimaryColor,
      );
}

TextStyle getHeadline4Style(BuildContext context) {
  return Theme.of(context).textTheme.headline4?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kTextPrimaryColor,
      ) ??
      const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kTextPrimaryColor,
      );
}

TextStyle getSubtitle1Style(BuildContext context) {
  return Theme.of(context).textTheme.subtitle1?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: kTextPrimaryColor,
      ) ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: kTextPrimaryColor,
      );
}

TextStyle getSubtitle2Style(BuildContext context) {
  return Theme.of(context).textTheme.subtitle2?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kTextSecondaryColor,
      ) ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kTextSecondaryColor,
      );
}

TextStyle getBodyText1Style(BuildContext context) {
  return Theme.of(context).textTheme.bodyText1?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: kTextPrimaryColor,
      ) ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: kTextPrimaryColor,
      );
}

TextStyle getBodyText2Style(BuildContext context) {
  return Theme.of(context).textTheme.bodyText2?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: kTextSecondaryColor,
      ) ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: kTextSecondaryColor,
      );
}

TextStyle getCaptionStyle(BuildContext context) {
  return Theme.of(context).textTheme.caption?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: kTextHintColor,
      ) ??
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: kTextHintColor,
      );
}

TextStyle getButtonTextStyle(BuildContext context) {
  return Theme.of(context).textTheme.button?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ) ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}

// Helper Extensions
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DateTimeExtension on DateTime {
  String format(String format) {
    return DateFormat(format).format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

// Validators
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse email';
    }
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    // Add more password validation rules as needed
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    // Basic phone number validation (adjust based on your requirements)
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer $fieldName';
    }
    return null;
  }
}
