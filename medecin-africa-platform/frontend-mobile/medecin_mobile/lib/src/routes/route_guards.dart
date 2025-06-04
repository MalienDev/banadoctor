import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/error/not_found_screen.dart';
import '../utils/constants.dart';
import 'app_routes.dart';

/// A route guard that checks if the user is authenticated
class AuthGuard {
  /// Check if the user is authenticated
  static bool isAuthenticated(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated;
  }
  
  /// Check if the user is not authenticated
  static bool isNotAuthenticated(BuildContext context) {
    return !isAuthenticated(context);
  }
  
  /// Check if the user is a doctor
  static bool isDoctor(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated && authService.currentUser?.userType == 'doctor';
  }
  
  /// Check if the user is a patient
  static bool isPatient(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated && authService.currentUser?.userType == 'patient';
  }
  
  /// Check if the user's email is verified
  static bool isEmailVerified(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated && authService.currentUser?.emailVerified == true;
  }
  
  /// Check if the user's profile is complete
  static bool isProfileComplete(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated && authService.currentUser?.isProfileComplete == true;
  }
  
  /// Handle authentication required routes
  static Route<dynamic> handleAuthentication({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
    bool requireEmailVerification = false,
    bool requireProfileCompletion = false,
  }) {
    // Check if user is authenticated
    if (!isAuthenticated(context)) {
      // Redirect to login page with a return URL
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: RouteSettings(
          name: AppRoutes.login,
          arguments: {
            'returnUrl': settings.name,
            'returnArgs': settings.arguments,
          },
        ),
      );
    }
    
    // Check if email verification is required
    if (requireEmailVerification && !isEmailVerified(context)) {
      // Redirect to email verification page
      return MaterialPageRoute(
        builder: (context) => const VerifyEmailScreen(),
        settings: const RouteSettings(name: AppRoutes.verifyEmail),
      );
    }
    
    // Check if profile completion is required
    if (requireProfileCompletion && !isProfileComplete(context)) {
      // Redirect to complete profile page
      return MaterialPageRoute(
        builder: (context) => const CompleteProfileScreen(),
        settings: const RouteSettings(name: AppRoutes.completeProfile),
      );
    }
    
    // Return the requested route if all checks pass
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
  
  /// Handle role-based access control
  static Route<dynamic> handleRoleBasedAccess({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
    List<String>? allowedRoles,
    String? requiredPermission,
  }) {
    // If no role or permission is required, allow access
    if ((allowedRoles == null || allowedRoles.isEmpty) && requiredPermission == null) {
      return MaterialPageRoute(
        builder: (context) => child,
        settings: settings,
      );
    }
    
    // Check if user is authenticated
    if (!isAuthenticated(context)) {
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: RouteSettings(
          name: AppRoutes.login,
          arguments: {
            'returnUrl': settings.name,
            'returnArgs': settings.arguments,
          },
        ),
      );
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    // Check if user has the required role
    if (allowedRoles != null && allowedRoles.isNotEmpty) {
      final hasRole = user?.roles?.any((role) => allowedRoles.contains(role)) ?? false;
      if (!hasRole) {
        return _buildUnauthorizedRoute(settings);
      }
    }
    
    // Check if user has the required permission
    if (requiredPermission != null) {
      final hasPermission = user?.permissions?.contains(requiredPermission) ?? false;
      if (!hasPermission) {
        return _buildForbiddenRoute(settings);
      }
    }
    
    // Return the requested route if all checks pass
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
  
  /// Build an unauthorized route
  static Route<dynamic> _buildUnauthorizedRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const UnauthorizedScreen(),
      settings: const RouteSettings(name: AppRoutes.unauthorized),
    );
  }
  
  /// Build a forbidden route
  static Route<dynamic> _buildForbiddenRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ForbiddenScreen(),
      settings: const RouteSettings(name: AppRoutes.forbidden),
    );
  }
  
  /// Handle maintenance mode
  static Route<dynamic> handleMaintenanceMode({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
  }) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Skip maintenance check for admin users
    if (authService.isAuthenticated && authService.currentUser?.isAdmin == true) {
      return MaterialPageRoute(
        builder: (context) => child,
        settings: settings,
      );
    }
    
    // Check if maintenance mode is enabled
    final maintenanceMode = false; // TODO: Get from app config or API
    if (maintenanceMode) {
      return MaterialPageRoute(
        builder: (context) => const MaintenanceScreen(),
        settings: const RouteSettings(name: AppRoutes.maintenance),
      );
    }
    
    // Return the requested route if maintenance mode is off
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
  
  /// Handle app version check
  static Route<dynamic> handleAppVersion({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
  }) {
    // TODO: Implement app version check
    // Check if the current app version is supported
    // If not, redirect to update screen
    
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
  
  /// Handle feature flags
  static Route<dynamic> handleFeatureFlag({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
    required String featureFlag,
  }) {
    // TODO: Implement feature flag check
    // Check if the feature is enabled for the current user
    
    // Example:
    // final isFeatureEnabled = await FeatureFlagsService.isEnabled(featureFlag, context);
    // if (!isFeatureEnabled) {
    //   return MaterialPageRoute(
    //     builder: (context) => const FeatureNotAvailableScreen(),
    //     settings: const RouteSettings(name: AppRoutes.featureNotAvailable),
    //   );
    // }
    
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
}

/// A route guard that checks if the user is a patient
class PatientGuard extends AuthGuard {
  static Route<dynamic> handle({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
  }) {
    if (!isAuthenticated(context)) {
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: RouteSettings(
          name: AppRoutes.login,
          arguments: {
            'returnUrl': settings.name,
            'returnArgs': settings.arguments,
          },
        ),
      );
    }
    
    if (!isPatient(context)) {
      return MaterialPageRoute(
        builder: (context) => const UnauthorizedScreen(),
        settings: const RouteSettings(name: AppRoutes.unauthorized),
      );
    }
    
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
}

/// A route guard that checks if the user is a doctor
class DoctorGuard extends AuthGuard {
  static Route<dynamic> handle({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
  }) {
    if (!isAuthenticated(context)) {
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: RouteSettings(
          name: AppRoutes.login,
          arguments: {
            'returnUrl': settings.name,
            'returnArgs': settings.arguments,
          },
        ),
      );
    }
    
    if (!isDoctor(context)) {
      return MaterialPageRoute(
        builder: (context) => const UnauthorizedScreen(),
        settings: const RouteSettings(name: AppRoutes.unauthorized),
      );
    }
    
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
}

/// A route guard that checks if the user is an admin
class AdminGuard extends AuthGuard {
  static Route<dynamic> handle({
    required BuildContext context,
    required RouteSettings settings,
    required Widget child,
  }) {
    if (!isAuthenticated(context)) {
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: RouteSettings(
          name: AppRoutes.login,
          arguments: {
            'returnUrl': settings.name,
            'returnArgs': settings.arguments,
          },
        ),
      );
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final isAdmin = authService.currentUser?.isAdmin == true;
    
    if (!isAdmin) {
      return MaterialPageRoute(
        builder: (context) => const ForbiddenScreen(),
        settings: const RouteSettings(name: AppRoutes.forbidden),
      );
    }
    
    return MaterialPageRoute(
      builder: (context) => child,
      settings: settings,
    );
  }
}
