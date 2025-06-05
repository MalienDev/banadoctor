import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medecin_mobile/src/services/auth_service.dart';
import 'package:medecin_mobile/src/widgets/app_bar_with_avatar.dart';
import 'package:medecin_mobile/src/widgets/upcoming_appointment_card.dart';
import 'package:medecin_mobile/src/widgets/doctor_card.dart';
import 'package:medecin_mobile/src/models/doctor_model.dart';
import 'package:medecin_mobile/src/theme/app_colors.dart';

class DashboardPatientScreen extends StatefulWidget {
  const DashboardPatientScreen({Key? key}) : super(key: key);

  @override
  State<DashboardPatientScreen> createState() => _DashboardPatientScreenState();
}

class _DashboardPatientScreenState extends State<DashboardPatientScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const _HomeTab(),
    const _AppointmentsTab(),
    const _MessagesTab(),
    const _ProfileTab(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
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
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthService>().currentUser!;

    // Mock data - replace with actual data from API
    final List<Doctor> nearbyDoctors = [
      Doctor(
        id: 1,
        name: 'Dr. Jean Dupont',
        specialty: 'Cardiologue',
        rating: 4.8,
        distance: 1.2,
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      ),
      Doctor(
        id: 2,
        name: 'Dr. Marie Martin',
        specialty: 'Dentiste',
        rating: 4.6,
        distance: 0.8,
        imageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      ),
      Doctor(
        id: 3,
        name: 'Dr. Sophie Bernard',
        specialty: 'Pédiatre',
        rating: 4.9,
        distance: 2.1,
        imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with user greeting
            AppBarWithAvatar(
              title: 'Bonjour, ${user.firstName}',
              subtitle: 'Comment allez-vous aujourd\'hui ?',
              imageUrl: user.profileImage,
            ),
            const SizedBox(height: 24),
            
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un médecin, une spécialité...',
                        border: InputBorder.none,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Upcoming appointment card
            const Text(
              'Prochain rendez-vous',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const UpcomingAppointmentCard(
              doctorName: 'Dr. Jean Dupont',
              specialty: 'Cardiologue',
              date: 'Aujourd\'hui',
              time: '14:30 - 15:00',
              location: 'Cabinet Médical, 123 Rue de Paris',
              imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
            ),
            const SizedBox(height: 24),
            
            // Nearby doctors section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Médecins à proximité',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all doctors
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nearbyDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = nearbyDoctors[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: DoctorCard(doctor: doctor),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Categories section
            const Text(
              'Catégories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _CategoryItem(
                  icon: Icons.medical_services,
                  label: 'Généraliste',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.favorite,
                  label: 'Cardiologue',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.airline_seat_recline_normal,
                  label: 'Dentiste',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.visibility,
                  label: 'Ophtalmo',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.psychology,
                  label: 'Psychiatre',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.people,
                  label: 'Pédiatre',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.woman,
                  label: 'Gynéco',
                  onTap: () {},
                ),
                _CategoryItem(
                  icon: Icons.more_horiz,
                  label: 'Plus',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mes rendez-vous'),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Messages'),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Mon profil',
            onTap: () {
              // Navigate to profile edit
            },
          ),
          const Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // Navigate to notifications
            },
          ),
          const Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Moyens de paiement',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          const Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Aide & Support',
            onTap: () {
              // Navigate to help
            },
          ),
          const Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            onTap: () {
              // Navigate to settings
            },
          ),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await authService.logout();
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: Colors.red,
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
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, size: 24),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      onTap: onTap,
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
