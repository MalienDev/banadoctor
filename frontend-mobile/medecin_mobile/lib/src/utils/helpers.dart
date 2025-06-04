import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

/// Formats a date to a human-readable string
String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
  return DateFormat(format).format(date);
}

/// Formats a time to a human-readable string
String formatTime(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('HH:mm').format(dt);
}

/// Formats a date and time to a human-readable string
String formatDateTime(DateTime dateTime, {bool showTime = true}) {
  final dateFormat = DateFormat('dd MMM yyyy');
  final timeFormat = DateFormat('HH:mm');
  
  if (showTime) {
    return '${dateFormat.format(dateTime)} à ${timeFormat.format(dateTime)}';
  }
  return dateFormat.format(dateTime);
}

/// Returns a string representing the time ago (e.g., "2 hours ago", "3 days ago")
String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '$years an${years > 1 ? 's' : ''} plus tôt';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return '$months mois plus tôt';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} plus tôt';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} plus tôt';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} plus tôt';
  } else {
    return 'À l\'instant';
  }
}

/// Returns a color based on the status
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return kStatusPendingColor;
    case 'confirmed':
      return kStatusConfirmedColor;
    case 'completed':
      return kStatusCompletedColor;
    case 'cancelled':
      return kStatusCancelledColor;
    case 'no_show':
      return kStatusNoShowColor;
    default:
      return kTextSecondaryColor;
  }
}

/// Returns an icon based on the status
IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.pending_actions_outlined;
    case 'confirmed':
      return Icons.check_circle_outline;
    case 'completed':
      return Icons.verified_outlined;
    case 'cancelled':
      return Icons.cancel_outlined;
    case 'no_show':
      return Icons.no_accounts_outlined;
    default:
      return Icons.info_outline;
  }
}

/// Shows a snackbar with the given message
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isError ? kErrorColor : kPrimaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// Shows a confirmation dialog
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'Confirmer',
  String cancelText = 'Annuler',
  bool isDestructiveAction = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructiveAction ? kErrorColor : kPrimaryColor,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  
  return result ?? false;
}

/// Shows a loading dialog
void showLoadingDialog(BuildContext context, {String message = 'Chargement...'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

/// Hides the current loading dialog if visible
void hideLoadingDialog(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Formats a phone number for display (e.g., +221 77 123 45 67)
String formatPhoneNumber(String phoneNumber) {
  // Remove all non-digit characters
  final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  
  if (digits.length < 9) return phoneNumber;
  
  String formatted = '';
  
  // Handle international numbers (starting with + or 00)
  if (phoneNumber.startsWith('+') || phoneNumber.startsWith('00')) {
    final countryCode = phoneNumber.startsWith('+')
        ? '+${digits.substring(0, 3)}'  // +XXX
        : digits.startsWith('00')
            ? '+${digits.substring(2, 5)}'  // 00XXX -> +XXX
            : '+${digits.substring(0, 2)}';  // Fallback
    
    final rest = phoneNumber.startsWith('+')
        ? digits.substring(3)
        : digits.substring(phoneNumber.startsWith('00') ? 5 : 2);
    
    // Format the rest of the number
    if (rest.length >= 8) {
      formatted = '$countryCode ${rest.substring(0, 2)} ${rest.substring(2, 4)} ${rest.substring(4, 6)} ${rest.substring(6)}';
    } else {
      formatted = '$countryCode $rest';
    }
  } else {
    // Local number format (e.g., 77 123 45 67)
    if (digits.length >= 8) {
      formatted = '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 8)}';
      if (digits.length > 8) {
        formatted += ' ${digits.substring(8)}';
      }
    } else {
      formatted = digits;
    }
  }
  
  return formatted.trim();
}

/// Returns the first letters of each word in a name (for avatar placeholders)
String getInitials(String name) {
  if (name.isEmpty) return '';
  
  final names = name.split(' ');
  if (names.length == 1) {
    return names[0][0].toUpperCase();
  } else {
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}

/// Returns a color based on a string (for consistent avatar background colors)
Color getColorFromString(String input) {
  // Simple hash function to generate a consistent color from a string
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = input.codeUnitAt(i) + ((hash << 5) - hash);
  }
  
  // Generate a color with a fixed saturation and lightness for good contrast
  final hue = (hash.abs() % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
}

/// Returns a formatted string of a duration (e.g., "2h 30min")
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  
  if (hours > 0 && minutes > 0) {
    return '${hours}h ${minutes}min';
  } else if (hours > 0) {
    return '${hours}h';
  } else if (minutes > 0) {
    return '${minutes}min';
  } else {
    return 'Moins d\'une minute';
  }
}

/// Returns a formatted string of a file size (e.g., "2.5 MB")
String formatFileSize(int bytes, {int decimals = 1}) {
  if (bytes <= 0) return '0 B';
  
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final i = (log(bytes) / log(1024)).floor();
  
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals).replaceAll(RegExp(r'\.0+$'), '')} ${suffixes[i]}';
}

/// Capitalizes the first letter of each word in a string
String capitalize(String text) {
  if (text.isEmpty) return text;
  
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }).join(' ');
}

/// Truncates a string to a maximum length, adding an ellipsis if truncated
String truncateWithEllipsis(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

/// Returns a string with the count and appropriate pluralization
String pluralize(int count, String singular, String plural) {
  return count == 1 ? singular : plural;
}

/// Returns a string with the count and appropriate unit (e.g., "2 jours", "1 heure")
String formatCountWithUnit(int count, String singular, String plural) {
  return '$count ${pluralize(count, singular, plural)}';
}

/// Parses a date string in ISO 8601 format
DateTime? parseIso8601Date(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  
  try {
    return DateTime.parse(dateString).toLocal();
  } catch (e) {
    return null;
  }
}

/// Returns a string representing the time remaining until a future date
String getTimeRemaining(DateTime futureDate) {
  final now = DateTime.now();
  if (futureDate.isBefore(now)) return 'Terminé';
  
  final difference = futureDate.difference(now);
  
  if (difference.inDays > 0) {
    return 'Dans ${difference.inDays} j';
  } else if (difference.inHours > 0) {
    return 'Dans ${difference.inHours} h';
  } else if (difference.inMinutes > 0) {
    return 'Dans ${difference.inMinutes} min';
  } else {
    return 'Bientôt';
  }
}

/// Returns a color with the given opacity
Color withOpacity(Color color, double opacity) {
  return color.withOpacity(opacity);
}

/// Returns a color that contrasts well with the given color (black or white)
Color getContrastColor(Color color) {
  // Calculate the perceptive luminance (aka luma) - human eye favors green color...
  final double luma = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
  
  // Return black for bright colors, white for dark colors
  return luma > 0.5 ? Colors.black : Colors.white;
}
