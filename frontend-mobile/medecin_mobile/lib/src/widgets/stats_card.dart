import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final double elevation;

  const StatsCard({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            // Value
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsCardHorizontal extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool showBorder;
  final bool isSelected;
  final VoidCallback? onTap;

  const StatsCardHorizontal({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.showBorder = true,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: showBorder
              ? Border.all(
                  color: isSelected ? color : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1.0,
                )
              : null,
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Value
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.grey[800],
                  ),
                ),
                // Label
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isSelected ? color : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
