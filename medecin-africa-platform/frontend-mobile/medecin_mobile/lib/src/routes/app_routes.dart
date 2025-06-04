import 'package:flutter/material.dart';

import '../screens/screens.dart';

class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyOtp = '/verify-otp';
  
  // Main app routes
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String patientDashboard = '/patient-dashboard';
  static const String doctorDashboard = '/doctor-dashboard';
  
  // Doctor routes
  static const String doctorProfile = '/doctor/profile';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorPatientDetails = '/doctor/patient-details';
  static const String doctorAppointments = '/doctor/appointments';
  static const String doctorAvailability = '/doctor/availability';
  static const String doctorReviews = '/doctor/reviews';
  static const String doctorEarnings = '/doctor/earnings';
  static const String doctorSettings = '/doctor/settings';
  
  // Patient routes
  static const String patientProfile = '/patient/profile';
  static const String patientAppointments = '/patient/appointments';
  static const String patientDoctors = '/patient/doctors';
  static const String patientDoctorDetails = '/patient/doctor-details';
  static const String patientMedicalRecords = '/patient/medical-records';
  static const String patientPrescriptions = '/patient/prescriptions';
  static const String patientLabResults = '/patient/lab-results';
  static const String patientBilling = '/patient/billing';
  static const String patientSettings = '/patient/settings';
  
  // Appointment routes
  static const String bookAppointment = '/appointment/book';
  static const String appointmentDetails = '/appointment/details';
  static const String appointmentConfirmation = '/appointment/confirmation';
  static const String appointmentPayment = '/appointment/payment';
  static const String appointmentSuccess = '/appointment/success';
  
  // Video consultation routes
  static const String videoConsultation = '/video-consultation';
  static const String videoCall = '/video-call';
  static const String videoCallEnded = '/video-call/ended';
  
  // Settings routes
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit-profile';
  static const String changePassword = '/settings/change-password';
  static const String notificationSettings = '/settings/notifications';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String termsOfService = '/settings/terms-of-service';
  static const String helpCenter = '/settings/help-center';
  static const String contactSupport = '/settings/contact-support';
  static const String aboutApp = '/settings/about';
  
  // Static content routes
  static const String aboutUs = '/about-us';
  static const String ourDoctors = '/our-doctors';
  static const String services = '/services';
  static const String faq = '/faq';
  static const String blog = '/blog';
  static const String blogDetails = '/blog/details';
  static const String testimonials = '/testimonials';
  
  // Error routes
  static const String notFound = '/not-found';
  static const String comingSoon = '/coming-soon';
  static const String maintenance = '/maintenance';
  static const String noInternet = '/no-internet';

  // Generate routes for MaterialApp
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
          settings: settings,
        );
      case verifyOtp:
        return MaterialPageRoute(
          builder: (_) => const VerifyOtpScreen(),
          settings: settings,
        );
      
      // Main app routes
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case patientDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPatient());
      case doctorDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardMedecin());
      
      // Doctor routes
      case doctorProfile:
        return MaterialPageRoute(builder: (_) => const DoctorProfileScreen());
      case doctorSchedule:
        return MaterialPageRoute(builder: (_) => const DoctorScheduleScreen());
      case doctorPatients:
        return MaterialPageRoute(builder: (_) => const DoctorPatientsScreen());
      case doctorPatientDetails:
        return MaterialPageRoute(
          builder: (_) => const DoctorPatientDetailsScreen(),
          settings: settings,
        );
      case doctorAppointments:
        return MaterialPageRoute(builder: (_) => const DoctorAppointmentsScreen());
      case doctorAvailability:
        return MaterialPageRoute(builder: (_) => const DoctorAvailabilityScreen());
      case doctorReviews:
        return MaterialPageRoute(builder: (_) => const DoctorReviewsScreen());
      case doctorEarnings:
        return MaterialPageRoute(builder: (_) => const DoctorEarningsScreen());
      case doctorSettings:
        return MaterialPageRoute(builder: (_) => const DoctorSettingsScreen());
      
      // Patient routes
      case patientProfile:
        return MaterialPageRoute(builder: (_) => const PatientProfileScreen());
      case patientAppointments:
        return MaterialPageRoute(builder: (_) => const PatientAppointmentsScreen());
      case patientDoctors:
        return MaterialPageRoute(builder: (_) => const PatientDoctorsScreen());
      case patientDoctorDetails:
        return MaterialPageRoute(
          builder: (_) => const PatientDoctorDetailsScreen(),
          settings: settings,
        );
      case patientMedicalRecords:
        return MaterialPageRoute(builder: (_) => const PatientMedicalRecordsScreen());
      case patientPrescriptions:
        return MaterialPageRoute(builder: (_) => const PatientPrescriptionsScreen());
      case patientLabResults:
        return MaterialPageRoute(builder: (_) => const PatientLabResultsScreen());
      case patientBilling:
        return MaterialPageRoute(builder: (_) => const PatientBillingScreen());
      case patientSettings:
        return MaterialPageRoute(builder: (_) => const PatientSettingsScreen());
      
      // Appointment routes
      case bookAppointment:
        return MaterialPageRoute(
          builder: (_) => const BookAppointmentScreen(),
          settings: settings,
        );
      case appointmentDetails:
        return MaterialPageRoute(
          builder: (_) => const AppointmentDetailScreen(),
          settings: settings,
        );
      case appointmentConfirmation:
        return MaterialPageRoute(builder: (_) => const AppointmentConfirmationScreen());
      case appointmentPayment:
        return MaterialPageRoute(
          builder: (_) => const AppointmentPaymentScreen(),
          settings: settings,
        );
      case appointmentSuccess:
        return MaterialPageRoute(
          builder: (_) => const AppointmentSuccessScreen(),
          settings: settings,
        );
      
      // Video consultation routes
      case videoConsultation:
        return MaterialPageRoute(builder: (_) => const VideoConsultationScreen());
      case videoCall:
        return MaterialPageRoute(
          builder: (_) => const VideoCallScreen(),
          settings: settings,
        );
      case videoCallEnded:
        return MaterialPageRoute(
          builder: (_) => const VideoCallEndedScreen(),
          settings: settings,
        );
      
      // Settings routes
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      case privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case termsOfService:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());
      case helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());
      case contactSupport:
        return MaterialPageRoute(builder: (_) => const ContactSupportScreen());
      case aboutApp:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());
      
      // Static content routes
      case aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());
      case ourDoctors:
        return MaterialPageRoute(builder: (_) => const OurDoctorsScreen());
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen());
      case faq:
        return MaterialPageRoute(builder: (_) => const FaqScreen());
      case blog:
        return MaterialPageRoute(builder: (_) => const BlogScreen());
      case blogDetails:
        return MaterialPageRoute(
          builder: (_) => const BlogDetailsScreen(),
          settings: settings,
        );
      case testimonials:
        return MaterialPageRoute(builder: (_) => const TestimonialsScreen());
      
      // Error routes
      case notFound:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
      case comingSoon:
        return MaterialPageRoute(builder: (_) => const ComingSoonScreen());
      case maintenance:
        return MaterialPageRoute(builder: (_) => const MaintenanceScreen());
      case noInternet:
        return MaterialPageRoute(builder: (_) => const NoInternetScreen());
      
      // Default route (404)
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
  
  // Helper method to get route name from enum
  static String getRouteName(dynamic routeEnum) {
    return routeEnum.toString().split('.').last;
  }
  
  // Helper method to get route arguments
  static T? getRouteArgs<T>(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null) {
      final args = route.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
  
  // Helper method to push a named route
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
  
  // Helper method to push a named route and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
  
  // Helper method to pop the current route
  static void pop<T>(
    BuildContext context, [
    T? result,
  ]) {
    Navigator.of(context).pop<T>(result);
  }
  
  // Helper method to check if we can pop the current route
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
  
  // Helper method to pop until the first route
  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  // Helper method to pop until a specific route
  static void popUntilRouteNamed(BuildContext context, String routeName) {
    Navigator.of(context).popUntil((route) {
      return route.settings.name == routeName || route.isFirst;
    });
  }
}
