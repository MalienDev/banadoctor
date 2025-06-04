import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../models/rendez_vous.dart';
import '../../utils/constants.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/custom_button.dart';
import 'doctors_list_screen.dart';
import 'appointment_detail_screen.dart';
import 'profile_screen.dart';

class DashboardPatient extends StatefulWidget {
  const DashboardPatient({super.key});

  @override
  _DashboardPatientState createState() => _DashboardPatientState();
}

class _DashboardPatientState extends State<DashboardPatient> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<RendezVous> _upcomingAppointments = [];
  List<RendezVous> _pastAppointments = [];

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
      
      await appointmentsProvider.fetchUpcomingAppointments();
      
      if (mounted) {
        setState(() {
          _upcomingAppointments = appointmentsProvider.upcomingAppointments;
          _pastAppointments = appointmentsProvider.pastAppointments;
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

  void _navigateToDoctorList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorsListScreen()),
    );
  }

  void _navigateToAppointmentDetail(RendezVous appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
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
                'Bonjour',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Text(
                    authProvider.currentUser?.firstName ?? 'Patient',
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
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(context.read<AuthProvider>().currentUser?.fullName ?? 'U')}&background=2E7D32&color=fff',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un médecin, une spécialité...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onTap: _navigateToDoctorList,
        readOnly: true,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickActionButton(
                icon: Icons.video_call,
                label: 'Consultation\nVidéo',
                color: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
              ),
              _buildQuickActionButton(
                icon: Icons.calendar_today,
                label: 'Prendre\nRDV',
                color: const Color(0xFFE8F5E9),
                iconColor: kPrimaryColor,
                onTap: _navigateToDoctorList,
              ),
              _buildQuickActionButton(
                icon: Icons.medication,
                label: 'Ordonnance\nEn ligne',
                color: const Color(0xFFFFF8E1),
                iconColor: Colors.orange,
              ),
              _buildQuickActionButton(
                icon: Icons.medical_services,
                label: 'Urgence',
                color: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
        subtitle: 'Prenez rendez-vous avec un médecin dès maintenant',
        buttonText: 'Prendre RDV',
        onPressed: _navigateToDoctorList,
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
                'Mes rendez-vous',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Switch to appointments tab
                  });
                },
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: _upcomingAppointments.length,
            itemBuilder: (context, index) {
              final appointment = _upcomingAppointments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: AppointmentCard(
                  appointment: appointment,
                  onTap: () => _navigateToAppointmentDetail(appointment),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyDoctors() {
    // This would be replaced with actual nearby doctors from your data
    final List<Map<String, dynamic>> nearbyDoctors = [
      {
        'name': 'Dr. Marie Diop',
        'specialty': 'Dentiste',
        'rating': 4.8,
        'distance': 1.2,
        'image': 'https://randomuser.me/api/portraits/women/42.jpg',
      },
      {
        'name': 'Dr. Jean Ndiaye',
        'specialty': 'Cardiologue',
        'rating': 4.9,
        'distance': 2.5,
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      },
      {
        'name': 'Dr. Aïssatou Ba',
        'specialty': 'Pédiatre',
        'rating': 4.7,
        'distance': 3.1,
        'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Médecins à proximité',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: nearbyDoctors.length,
            itemBuilder: (context, index) {
              final doctor = nearbyDoctors[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: DoctorCard(
                  name: doctor['name'],
                  specialty: doctor['specialty'],
                  rating: doctor['rating'],
                  distance: doctor['distance'],
                  imageUrl: doctor['image'],
                  onTap: _navigateToDoctorList,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upcomingAppointments.isEmpty && _pastAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'Aucun rendez-vous',
        subtitle: 'Vous n\'avez pas encore de rendez-vous.\nPrenez rendez-vous avec un médecin dès maintenant.',
        buttonText: 'Prendre RDV',
        onPressed: _navigateToDoctorList,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_upcomingAppointments.isNotEmpty) ...[
            Text(
              'À venir',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._upcomingAppointments.map((appointment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AppointmentCard(
                  appointment: appointment,
                  onTap: () => _navigateToAppointmentDetail(appointment),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
          if (_pastAppointments.isNotEmpty) ...[
            Text(
              'Passés',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._pastAppointments.map((appointment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AppointmentCard(
                  appointment: appointment,
                  onTap: () => _navigateToAppointmentDetail(appointment),
                ),
              );
            }),
          ],
        ],
      ),
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
                            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.fullName ?? 'U')}&background=2E7D32&color=fff',
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
                  user?.fullName ?? 'Utilisateur',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Mon profil',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.medical_services_outlined,
            title: 'Mes médecins',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.favorite_border,
            title: 'Mes favoris',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Moyens de paiement',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.history,
            title: 'Historique des consultations',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Aide & Support',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Center(
            child: CustomButton(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              text: 'Déconnexion',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              isOutlined: true,
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
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16),
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
    required String buttonText,
    required VoidCallback onPressed,
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
            const SizedBox(height: 24),
            CustomButton(
              onPressed: onPressed,
              text: buttonText,
              width: 200,
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
            // Home Tab
            RefreshIndicator(
              onRefresh: _loadAppointments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildUpcomingAppointments(),
                    const SizedBox(height: 24),
                    _buildNearbyDoctors(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Appointments Tab
            _buildAppointmentsTab(),
            // Profile Tab
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Rendez-vous',
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
              onPressed: _navigateToDoctorList,
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              elevation: 2,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
