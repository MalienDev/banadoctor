import 'package:flutter/material.dart';

/// Base class for all route arguments
abstract class RouteArguments {
  const RouteArguments();
  
  /// Convert the arguments to a map
  Map<String, dynamic> toMap();
  
  /// Create route arguments from a map
  static T fromMap<T extends RouteArguments>(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap must be implemented by subclasses');
  }
}

/// Arguments for the login screen
class LoginArguments extends RouteArguments {
  final String? returnUrl;
  final Object? returnArgs;
  final String? email;
  final String? message;
  final bool showBackButton;
  
  const LoginArguments({
    this.returnUrl,
    this.returnArgs,
    this.email,
    this.message,
    this.showBackButton = true,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'returnUrl': returnUrl,
      'returnArgs': returnArgs,
      'email': email,
      'message': message,
      'showBackButton': showBackButton,
    };
  }
  
  factory LoginArguments.fromMap(Map<String, dynamic> map) {
    return LoginArguments(
      returnUrl: map['returnUrl'],
      returnArgs: map['returnArgs'],
      email: map['email'],
      message: map['message'],
      showBackButton: map['showBackButton'] ?? true,
    );
  }
  
  static LoginArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return LoginArguments.fromMap(args);
    } else if (args is LoginArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the registration screen
class RegisterArguments extends RouteArguments {
  final String? email;
  final String? phoneNumber;
  final String? userType;
  final String? referralCode;
  
  const RegisterArguments({
    this.email,
    this.phoneNumber,
    this.userType,
    this.referralCode,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'referralCode': referralCode,
    };
  }
  
  factory RegisterArguments.fromMap(Map<String, dynamic> map) {
    return RegisterArguments(
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      userType: map['userType'],
      referralCode: map['referralCode'],
    );
  }
  
  static RegisterArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return RegisterArguments.fromMap(args);
    } else if (args is RegisterArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the forgot password screen
class ForgotPasswordArguments extends RouteArguments {
  final String? email;
  final String? phoneNumber;
  
  const ForgotPasswordArguments({
    this.email,
    this.phoneNumber,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
  
  factory ForgotPasswordArguments.fromMap(Map<String, dynamic> map) {
    return ForgotPasswordArguments(
      email: map['email'],
      phoneNumber: map['phoneNumber'],
    );
  }
  
  static ForgotPasswordArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return ForgotPasswordArguments.fromMap(args);
    } else if (args is ForgotPasswordArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the OTP verification screen
class OtpVerificationArguments extends RouteArguments {
  final String verificationId;
  final String phoneNumber;
  final String? email;
  final String? userId;
  final String? userType;
  final bool isPasswordReset;
  final String? newPassword;
  final String? returnRoute;
  final Object? returnArgs;
  
  const OtpVerificationArguments({
    required this.verificationId,
    required this.phoneNumber,
    this.email,
    this.userId,
    this.userType,
    this.isPasswordReset = false,
    this.newPassword,
    this.returnRoute,
    this.returnArgs,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'verificationId': verificationId,
      'phoneNumber': phoneNumber,
      'email': email,
      'userId': userId,
      'userType': userType,
      'isPasswordReset': isPasswordReset,
      'newPassword': newPassword,
      'returnRoute': returnRoute,
      'returnArgs': returnArgs,
    };
  }
  
  factory OtpVerificationArguments.fromMap(Map<String, dynamic> map) {
    return OtpVerificationArguments(
      verificationId: map['verificationId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      userId: map['userId'],
      userType: map['userType'],
      isPasswordReset: map['isPasswordReset'] ?? false,
      newPassword: map['newPassword'],
      returnRoute: map['returnRoute'],
      returnArgs: map['returnArgs'],
    );
  }
  
  static OtpVerificationArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return OtpVerificationArguments.fromMap(args);
    } else if (args is OtpVerificationArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the doctor profile screen
class DoctorProfileArguments extends RouteArguments {
  final String doctorId;
  final String? doctorName;
  final bool showAppointmentButton;
  
  const DoctorProfileArguments({
    required this.doctorId,
    this.doctorName,
    this.showAppointmentButton = true,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'showAppointmentButton': showAppointmentButton,
    };
  }
  
  factory DoctorProfileArguments.fromMap(Map<String, dynamic> map) {
    return DoctorProfileArguments(
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'],
      showAppointmentButton: map['showAppointmentButton'] ?? true,
    );
  }
  
  static DoctorProfileArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return DoctorProfileArguments.fromMap(args);
    } else if (args is DoctorProfileArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the patient profile screen
class PatientProfileArguments extends RouteArguments {
  final String patientId;
  final String? patientName;
  
  const PatientProfileArguments({
    required this.patientId,
    this.patientName,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
    };
  }
  
  factory PatientProfileArguments.fromMap(Map<String, dynamic> map) {
    return PatientProfileArguments(
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'],
    );
  }
  
  static PatientProfileArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return PatientProfileArguments.fromMap(args);
    } else if (args is PatientProfileArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the appointment booking screen
class BookAppointmentArguments extends RouteArguments {
  final String? doctorId;
  final String? doctorName;
  final String? specialty;
  final DateTime? preferredDate;
  final String? reason;
  final bool isFollowUp;
  final String? previousAppointmentId;
  
  const BookAppointmentArguments({
    this.doctorId,
    this.doctorName,
    this.specialty,
    this.preferredDate,
    this.reason,
    this.isFollowUp = false,
    this.previousAppointmentId,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'preferredDate': preferredDate?.millisecondsSinceEpoch,
      'reason': reason,
      'isFollowUp': isFollowUp,
      'previousAppointmentId': previousAppointmentId,
    };
  }
  
  factory BookAppointmentArguments.fromMap(Map<String, dynamic> map) {
    return BookAppointmentArguments(
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      specialty: map['specialty'],
      preferredDate: map['preferredDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['preferredDate'])
          : null,
      reason: map['reason'],
      isFollowUp: map['isFollowUp'] ?? false,
      previousAppointmentId: map['previousAppointmentId'],
    );
  }
  
  static BookAppointmentArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return BookAppointmentArguments.fromMap(args);
    } else if (args is BookAppointmentArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the appointment details screen
class AppointmentDetailsArguments extends RouteArguments {
  final String appointmentId;
  final bool showActionButtons;
  final bool showHeader;
  final String? returnRoute;
  final Object? returnArgs;
  
  const AppointmentDetailsArguments({
    required this.appointmentId,
    this.showActionButtons = true,
    this.showHeader = true,
    this.returnRoute,
    this.returnArgs,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'showActionButtons': showActionButtons,
      'showHeader': showHeader,
      'returnRoute': returnRoute,
      'returnArgs': returnArgs,
    };
  }
  
  factory AppointmentDetailsArguments.fromMap(Map<String, dynamic> map) {
    return AppointmentDetailsArguments(
      appointmentId: map['appointmentId'] ?? '',
      showActionButtons: map['showActionButtons'] ?? true,
      showHeader: map['showHeader'] ?? true,
      returnRoute: map['returnRoute'],
      returnArgs: map['returnArgs'],
    );
  }
  
  static AppointmentDetailsArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return AppointmentDetailsArguments.fromMap(args);
    } else if (args is AppointmentDetailsArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the video call screen
class VideoCallArguments extends RouteArguments {
  final String callId;
  final String channelName;
  final String token;
  final String callType; // 'audio' or 'video'
  final bool isIncoming;
  final String callerName;
  final String? callerImageUrl;
  final String? appointmentId;
  
  const VideoCallArguments({
    required this.callId,
    required this.channelName,
    required this.token,
    this.callType = 'video',
    this.isIncoming = false,
    required this.callerName,
    this.callerImageUrl,
    this.appointmentId,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'channelName': channelName,
      'token': token,
      'callType': callType,
      'isIncoming': isIncoming,
      'callerName': callerName,
      'callerImageUrl': callerImageUrl,
      'appointmentId': appointmentId,
    };
  }
  
  factory VideoCallArguments.fromMap(Map<String, dynamic> map) {
    return VideoCallArguments(
      callId: map['callId'] ?? '',
      channelName: map['channelName'] ?? '',
      token: map['token'] ?? '',
      callType: map['callType'] ?? 'video',
      isIncoming: map['isIncoming'] ?? false,
      callerName: map['callerName'] ?? '',
      callerImageUrl: map['callerImageUrl'],
      appointmentId: map['appointmentId'],
    );
  }
  
  static VideoCallArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return VideoCallArguments.fromMap(args);
    } else if (args is VideoCallArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the payment screen
class PaymentArguments extends RouteArguments {
  final String paymentId;
  final double amount;
  final String currency;
  final String description;
  final String? returnUrl;
  final Map<String, dynamic>? metadata;
  
  const PaymentArguments({
    required this.paymentId,
    required this.amount,
    this.currency = 'XOF',
    required this.description,
    this.returnUrl,
    this.metadata,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'returnUrl': returnUrl,
      'metadata': metadata,
    };
  }
  
  factory PaymentArguments.fromMap(Map<String, dynamic> map) {
    return PaymentArguments(
      paymentId: map['paymentId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'XOF',
      description: map['description'] ?? '',
      returnUrl: map['returnUrl'],
      metadata: map['metadata'],
    );
  }
  
  static PaymentArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return PaymentArguments.fromMap(args);
    } else if (args is PaymentArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the web view screen
class WebViewArguments extends RouteArguments {
  final String url;
  final String title;
  final bool showAppBar;
  final bool enableJavaScript;
  final Map<String, String>? headers;
  
  const WebViewArguments({
    required this.url,
    this.title = '',
    this.showAppBar = true,
    this.enableJavaScript = true,
    this.headers,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'showAppBar': showAppBar,
      'enableJavaScript': enableJavaScript,
      'headers': headers,
    };
  }
  
  factory WebViewArguments.fromMap(Map<String, dynamic> map) {
    return WebViewArguments(
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      showAppBar: map['showAppBar'] ?? true,
      enableJavaScript: map['enableJavaScript'] ?? true,
      headers: Map<String, String>.from(map['headers'] ?? {}),
    );
  }
  
  static WebViewArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return WebViewArguments.fromMap(args);
    } else if (args is WebViewArguments) {
      return args;
    }
    return null;
  }
}

/// Arguments for the image viewer screen
class ImageViewerArguments extends RouteArguments {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;
  
  const ImageViewerArguments({
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'imageUrls': imageUrls,
      'initialIndex': initialIndex,
      'heroTag': heroTag,
    };
  }
  
  factory ImageViewerArguments.fromMap(Map<String, dynamic> map) {
    return ImageViewerArguments(
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      initialIndex: map['initialIndex'] ?? 0,
      heroTag: map['heroTag'],
    );
  }
  
  static ImageViewerArguments? fromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return ImageViewerArguments.fromMap(args);
    } else if (args is ImageViewerArguments) {
      return args;
    }
    return null;
  }
}
