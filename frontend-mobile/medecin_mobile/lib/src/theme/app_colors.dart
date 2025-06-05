import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);
  
  // Secondary colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Other colors
  static const Color accent = Color(0xFFFF4081);
  static const Color highlight = Color(0x66FF4081);
  static const Color splash = Color(0x40FF4081);
  
  // Social colors
  static const Color facebook = Color(0xFF3B5998);
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  // Status background colors
  static const Color successLight = Color(0x1A4CAF50);
  static const Color warningLight = Color(0x1AFFA000);
  static const Color errorLight = Color(0x1AE53935);
  static const Color infoLight = Color(0x1A2196F3);
  
  // Disabled colors
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFF9E9E9E);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF333333);
  
  // Transparent
  static const Color transparent = Color(0x00000000);
  
  // Shadow
  static const Color shadow = Color(0x1A000000);
  
  // Overlay
  static const Color overlay = Color(0x80000000);
  
  // Rating
  static const Color rating = Color(0xFFFFC107);
  
  // Custom colors for specific UI elements
  static const Color appointmentCard = Color(0xFFE3F2FD);
  static const Color emergency = Color(0xFFFF5252);
  static const Color available = Color(0xFF4CAF50);
  static const Color unavailable = Color(0xFF9E9E9E);
  static const Color favorite = Color(0xFFFF4081);
  static const Color notification = Color(0xFFFF5722);
  
  // Background colors for different appointment statuses
  static const Color appointmentPending = Color(0xFFFFF3E0);
  static const Color appointmentConfirmed = Color(0xFFE8F5E9);
  static const Color appointmentCancelled = Color(0xFFFFEBEE);
  static const Color appointmentCompleted = Color(0xFFE8EAF6);
  
  // Text colors for different appointment statuses
  static const Color textPending = Color(0xFFFF6D00);
  static const Color textConfirmed = Color(0xFF2E7D32);
  static const Color textCancelled = Color(0xFFC62828);
  static const Color textCompleted = Color(0xFF3949AB);
}
