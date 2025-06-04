import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../models/rendez_vous.dart';
import '../../utils/constants.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/stats_card.dart';
import 'appointment_detail_screen.dart';
import 'doctor_profile_screen.dart';
import 'doctor_schedule_screen.dart';

class DashboardMedecin extends StatefulWidget {
  const DashboardMedecin({super.key});

  @override
  _DashboardMedecinState createState() => _DashboardMedecinState();
}

class _DashboardMedecinState extends State<DashboardMedecin> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<RendezVous> _todayAppointments = [];
  List<RendezVous> _upcomingAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointmentsProvider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );
      
      await appointmentsProvider.fetchDoctorAppointments();
      
      if (mounted) {
        setState(() {
          _todayAppointments = appointmentsProvider.todayAppointments;
          _upcomingAppointments = appointmentsProvider.upcomingAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des rendez-vous: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAppointmentDetail(RendezVous appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    ).then((_) => _loadAppointments());
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorProfileScreen()),
    );
  }

  void _navigateToSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorScheduleScreen()),
    ).then((_) => _loadAppointments());
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, Docteur',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Text(
                    authProvider.currentUser?.lastName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: DecorationImage(
                  image: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(context.read<AuthProvider>().currentUser?.fullName ?? 'D')}&background=2E7D32&color=fff',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aujourd\'hui',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: '${_todayAppointments.length}',
                  label: 'RDV',
                  icon: Icons.calendar_today,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  value: '12',
                  label: 'Patients',
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  value: '\$1,240',
                  label: 'Revenus',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_todayAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: 'Aucun rendez-vous aujourd\'hui',
        subtitle: 'Vous n\'avez pas de rendez-vous programmés pour aujourd\'hui.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes rendez-vous d\'aujourd\'hui',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _navigateToSchedule,
                child: Text(
                  'Voir l\'agenda',
                  style: GoogleFonts.poppins(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _todayAppointments.length,
          itemBuilder: (context, index) {
            final appointment = _todayAppointments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: AppointmentCard(
                appointment: appointment,
                onTap: () => _navigateToAppointmentDetail(appointment),
                showPatientInfo: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upcomingAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'Aucun rendez-vous à venir',
        subtitle: 'Vous n\'avez pas encore de rendez-vous programmés.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Prochains rendez-vous',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _upcomingAppointments.length,
          itemBuilder: (context, index) {
            final appointment = _upcomingAppointments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: AppointmentCard(
                appointment: appointment,
                onTap: () => _navigateToAppointmentDetail(appointment),
                showPatientInfo: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPatientsTab() {
    // This would be replaced with actual patients data
    final List<Map<String, dynamic>> recentPatients = [
      {
        'name': 'Aminata Diop',
        'lastVisit': 'Aujourd\'hui',
        'nextAppointment': '15 Juin 2023',
        'image': 'https://randomuser.me/api/portraits/women/42.jpg',
      },
      {
        'name': 'Moussa Sarr',
        'lastVisit': 'Hier',
        'nextAppointment': '20 Juin 2023',
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      },
      {
        'name': 'Fatou Bâ',
        'lastVisit': '10 Juin 2023',
        'nextAppointment': '25 Juin 2023',
        'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: recentPatients.length,
      itemBuilder: (context, index) {
        final patient = recentPatients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(patient['image']),
            ),
            title: Text(
              patient['name'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Dernière visite: ${patient['lastVisit']}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Prochain RDV: ${patient['nextAppointment']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // TODO: Navigate to patient details
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 3),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.fullName ?? 'D')}&background=2E7D32&color=fff',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Docteur',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.speciality ?? 'Médecin',
                  style: GoogleFonts.poppins(
                    color: kPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '4.9 (128 avis)',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileMenuItem(
            icon: Icons.edit_document,
            title: 'Mon profil professionnel',
            onTap: _navigateToProfile,
          ),
          _buildProfileMenuItem(
            icon: Icons.calendar_month,
            title: 'Mon emploi du temps',
            onTap: _navigateToSchedule,
          ),
          _buildProfileMenuItem(
            icon: Icons.people_outline,
            title: 'Mes patients',
            onTap: () {
              setState(() {
                _selectedIndex = 1; // Switch to patients tab
              });
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.bar_chart,
            title: 'Statistiques et rapports',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.payment,
            title: 'Paiements et factures',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.settings,
            title: 'Paramètres du cabinet',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Aide et support',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Déconnexion',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(icon, color: kPrimaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: kPrimaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Dashboard Tab
            RefreshIndicator(
              onRefresh: _loadAppointments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildStats(),
                    const SizedBox(height: 16),
                    _buildTodayAppointments(),
                    const SizedBox(height: 24),
                    _buildUpcomingAppointments(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Patients Tab
            _buildPatientsTab(),
            // Profile Tab
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToSchedule,
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              elevation: 2,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
