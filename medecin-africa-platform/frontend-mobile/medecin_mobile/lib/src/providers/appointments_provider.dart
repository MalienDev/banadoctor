import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/rendez_vous.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AppointmentsProvider with ChangeNotifier {
  final AuthService _authService;
  final ApiService _apiService;
  
  List<RendezVous> _upcomingAppointments = [];
  List<RendezVous> _pastAppointments = [];
  List<RendezVous> _todayAppointments = [];
  bool _isLoading = false;
  String? _error;

  AppointmentsProvider({
    required AuthService authService,
    required ApiService apiService,
  })  : _authService = authService,
        _apiService = apiService;

  // Getters
  List<RendezVous> get upcomingAppointments => _upcomingAppointments;
  List<RendezVous> get pastAppointments => _pastAppointments;
  List<RendezVous> get todayAppointments => _todayAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if a date is in the past
  bool _isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  // Categorize appointments into today, upcoming, and past
  void _categorizeAppointments(List<RendezVous> appointments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _todayAppointments = appointments
        .where((appt) => _isToday(appt.date))
        .sorted((a, b) => a.date.compareTo(b.date))
        .toList();

    _upcomingAppointments = appointments
        .where((appt) => appt.date.isAfter(today) || _isToday(appt.date))
        .where((appt) => !_todayAppointments.contains(appt))
        .sorted((a, b) => a.date.compareTo(b.date))
        .toList();

    _pastAppointments = appointments
        .where((appt) => _isPast(appt.date))
        .sorted((a, b) => b.date.compareTo(a.date))
        .toList();
  }

  // Fetch all appointments for the current user
  Future<void> fetchUpcomingAppointments() async {
    if (_authService.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authService.currentUser!.id;
      final isDoctor = _authService.currentUser!.role == 'doctor';
      
      final appointments = isDoctor 
          ? await _apiService.getDoctorAppointments(userId)
          : await _apiService.getPatientAppointments(userId);
      
      _categorizeAppointments(appointments);
    } catch (e) {
      _error = 'Erreur lors du chargement des rendez-vous: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch appointments for doctor (alias for fetchUpcomingAppointments for clarity)
  Future<void> fetchDoctorAppointments() => fetchUpcomingAppointments();

  // Book a new appointment
  Future<bool> bookAppointment({
    required String doctorId,
    required DateTime dateTime,
    required String reason,
    String? notes,
  }) async {
    if (_authService.currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final patientId = _authService.currentUser!.id;
      final appointment = await _apiService.bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        dateTime: dateTime,
        reason: reason,
        notes: notes,
      );

      // Add to upcoming appointments
      _upcomingAppointments.add(appointment);
      _categorizeAppointments([..._upcomingAppointments, ..._pastAppointments]);
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la prise de rendez-vous: $e';
      if (kDebugMode) {
        print(_error);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
    String? cancelReason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAppointment = await _apiService.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
        cancelReason: cancelReason,
      );

      // Update the appointment in the lists
      final allAppointments = [..._upcomingAppointments, ..._pastAppointments];
      final index = allAppointments.indexWhere((a) => a.id == appointmentId);
      
      if (index != -1) {
        allAppointments[index] = updatedAppointment;
        _categorizeAppointments(allAppointments);
      }
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du rendez-vous: $e';
      if (kDebugMode) {
        print(_error);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel an appointment
  Future<bool> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    return updateAppointmentStatus(
      appointmentId: appointmentId,
      status: AppointmentStatus.cancelled,
      cancelReason: reason,
    );
  }

  // Reschedule an appointment
  Future<bool> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAppointment = await _apiService.rescheduleAppointment(
        appointmentId: appointmentId,
        newDateTime: newDateTime,
      );

      // Update the appointment in the lists
      final allAppointments = [..._upcomingAppointments, ..._pastAppointments];
      final index = allAppointments.indexWhere((a) => a.id == appointmentId);
      
      if (index != -1) {
        allAppointments[index] = updatedAppointment;
        _categorizeAppointments(allAppointments);
      }
      
      return true;
    } catch (e) {
      _error = 'Erreur lors du report du rendez-vous: $e';
      if (kDebugMode) {
        print(_error);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get appointment by ID
  RendezVous? getAppointmentById(String appointmentId) {
    final allAppointments = [..._upcomingAppointments, ..._pastAppointments];
    return allAppointments.firstWhereOrNull((a) => a.id == appointmentId);
  }

  // Clear all appointments (on logout)
  void clearAppointments() {
    _upcomingAppointments = [];
    _pastAppointments = [];
    _todayAppointments = [];
    _isLoading = false;
    _error = null;
    // No need to notify listeners here as this is typically called during logout
  }
}
