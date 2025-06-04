import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isOutlined;
  final Color borderColor;
  final double borderRadius;
  final double height;
  final double? width;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final bool isFullWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final bool hasShadow;
  final bool isRounded;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.textColor = Colors.white,
    this.isOutlined = false,
    this.borderColor = const Color(0xFF2E7D32),
    this.borderRadius = 8.0,
    this.height = 48.0,
    this.width,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.elevation = 0,
    this.isFullWidth = false,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.hasShadow = true,
    this.isRounded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? backgroundColor : textColor,
              ),
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: isOutlined ? backgroundColor : textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : backgroundColor,
      foregroundColor: textColor,
      elevation: elevation,
      padding: padding ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isRounded ? 30.0 : borderRadius),
        side: isOutlined
            ? BorderSide(color: borderColor, width: 1.5)
            : BorderSide.none,
      ),
      shadowColor: hasShadow ? Colors.black12 : Colors.transparent,
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }
}

// A smaller version of the button for more compact UIs
class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isOutlined;
  final Color borderColor;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? fontSize;

  const SmallButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.textColor = Colors.white,
    this.isOutlined = false,
    this.borderColor = const Color(0xFF2E7D32),
    this.borderRadius = 6.0,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 36.0,
    this.fontSize = 13.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isOutlined: isOutlined,
      borderColor: borderColor,
      borderRadius: borderRadius,
      height: height!,
      width: width,
      isLoading: isLoading,
      icon: icon != null
          ? Icon(
              icon,
              size: fontSize! * 1.2,
              color: isOutlined ? backgroundColor : textColor,
            )
          : null,
      fontSize: fontSize!,
      fontWeight: FontWeight.w500,
    );
  }
}

// A text button with an icon
class TextIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final bool reverse;

  const TextIconButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF2E7D32),
    this.iconSize = 18.0,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w500,
    this.padding,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!reverse) ..._buildIcon(),
          if (!reverse) const SizedBox(width: 4.0),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
          if (reverse) const SizedBox(width: 4.0),
          if (reverse) ..._buildIcon(),
        ],
      ),
    );
  }

  List<Widget> _buildIcon() {
    return [
      Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    ];
  }
}

// A circular icon button
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double elevation;
  final bool isOutlined;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;

  const CircleIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.iconColor = Colors.white,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.elevation = 0,
    this.isOutlined = false,
    this.borderColor = const Color(0xFF2E7D32),
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOutlined ? Colors.transparent : backgroundColor,
        border: isOutlined
            ? Border.all(
                color: borderColor,
                width: 1.5,
              )
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          color: isOutlined ? borderColor : iconColor,
        ),
        padding: padding ?? EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
