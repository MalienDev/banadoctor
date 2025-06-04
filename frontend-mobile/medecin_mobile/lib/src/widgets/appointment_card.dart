import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/rendez_vous.dart';
import '../../utils/constants.dart';
import 'custom_button.dart';

class AppointmentCard extends StatelessWidget {
  final RendezVous appointment;
  final VoidCallback onTap;
  final bool showPatientInfo;
  final bool showActions;
  final bool isCompact;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onTap,
    this.showPatientInfo = false,
    this.showActions = true,
    this.isCompact = false,
  }) : super(key: key);

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatAppointmentTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatAppointmentDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final appointmentDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (appointmentDate == today) {
      return 'Aujourd\'hui';
    } else if (appointmentDate == tomorrow) {
      return 'Demain';
    } else {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(appointment.status);
    final isPastAppointment = appointment.date.isBefore(DateTime.now());
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    if (isCompact) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Time container
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatAppointmentTime(appointment.date),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatAppointmentDate(appointment.date).split(' ')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Doctor/Patient info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showPatientInfo
                            ? '${appointment.patient?.fullName ?? 'Patient'}\n${appointment.patient?.phoneNumber ?? ''}'
                            : 'Dr. ${appointment.doctor?.fullName ?? 'Médecin'}\n${appointment.doctor?.speciality ?? 'Spécialité'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.reason,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.displayName,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatAppointmentDate(appointment.date),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status.displayName,
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time and type
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.access_time,
                        text: _formatAppointmentTime(appointment.date),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: appointment.isVideoConsultation
                            ? Icons.videocam_outlined
                            : Icons.person_outline,
                        text: appointment.isVideoConsultation
                            ? 'Visio-consultation'
                            : 'Consultation en cabinet',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Doctor/Patient info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          image: showPatientInfo && appointment.patient?.photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(appointment.patient!.photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : !showPatientInfo && appointment.doctor?.photoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(appointment.doctor!.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (showPatientInfo && appointment.patient?.photoUrl == null) ||
                                (!showPatientInfo && appointment.doctor?.photoUrl == null)
                            ? Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showPatientInfo
                                  ? appointment.patient?.fullName ?? 'Patient'
                                  : 'Dr. ${appointment.doctor?.fullName ?? 'Médecin'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (showPatientInfo)
                              Text(
                                '${appointment.patient?.phoneNumber ?? ''}${appointment.patient?.email != null ? ' • ${appointment.patient!.email!}' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Text(
                                appointment.doctor?.speciality ?? 'Spécialité non spécifiée',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: kPrimaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Rating (only for doctors)
                      if (!showPatientInfo && appointment.doctor?.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              appointment.doctor!.rating!.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Reason and notes
                  if (appointment.reason.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: Icons.medical_services_outlined,
                      label: 'Motif',
                      value: appointment.reason,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (appointment.notes?.isNotEmpty ?? false) ...[
                    _buildInfoRow(
                      icon: Icons.note_outlined,
                      label: 'Notes',
                      value: appointment.notes!,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Location (if in-person)
                  if (!appointment.isVideoConsultation &&
                      appointment.location?.isNotEmpty == true) ...[
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Adresse',
                      value: appointment.location!,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Video link (if video consultation)
                  if (appointment.isVideoConsultation &&
                      appointment.videoLink?.isNotEmpty == true) ...[
                    _buildInfoRow(
                      icon: Icons.videocam_outlined,
                      label: 'Lien de la visio',
                      value: appointment.videoLink!,
                      isLink: true,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Cancel reason (if cancelled)
                  if (isCancelled && appointment.cancelReason?.isNotEmpty == true) ...[
                    _buildInfoRow(
                      icon: Icons.cancel_outlined,
                      label: 'Motif d\'annulation',
                      value: appointment.cancelReason!,
                      valueColor: Colors.red,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            // Actions
            if (showActions && !isPastAppointment && !isCancelled)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 0,
                ),
                child: Row(
                  children: [
                    if (appointment.status == AppointmentStatus.pending) ...[
                      Expanded(
                        child: CustomButton(
                          onPressed: () {
                            // TODO: Handle cancel action
                          },
                          text: 'Annuler',
                          backgroundColor: Colors.white,
                          textColor: Colors.red,
                          isOutlined: true,
                          borderColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          // TODO: Handle join/start consultation
                        },
                        text: appointment.isVideoConsultation
                            ? 'Rejoindre la consultation'
                            : 'Démarrer la consultation',
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    int maxLines = 1,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label :',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: isLink
                    ? () {
                        // TODO: Handle link tap (copy to clipboard or open URL)
                      }
                    : null,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: valueColor ??
                        (isLink ? Colors.blue : Colors.grey[800]),
                    fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
                    decoration: isLink
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
