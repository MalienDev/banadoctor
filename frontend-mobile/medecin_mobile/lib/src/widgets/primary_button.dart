import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;
  final bool outlined;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.fullWidth = true,
    this.outlined = false,
    this.color,
    this.padding,
    this.height,
    this.width,
    this.borderRadius = 8.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    final textColor = outlined ? buttonColor : theme.colorScheme.onPrimary;
    
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : buttonColor,
          foregroundColor: textColor,
          padding: padding ?? const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: outlined
                ? BorderSide(
                    color: buttonColor,
                    width: 2.0,
                  )
                : BorderSide.none,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: buttonColor.withOpacity(0.5),
          disabledForegroundColor: textColor.withOpacity(0.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor,
                  ),
                ),
              )
            : DefaultTextStyle.merge(
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
      ),
    );
  }
}
