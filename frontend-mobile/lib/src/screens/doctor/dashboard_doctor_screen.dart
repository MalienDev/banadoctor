import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medecin_mobile/src/services/auth_service.dart';
import 'package:medecin_mobile/src/widgets/app_bar_with_avatar.dart';
import 'package:medecin_mobile/src/theme/app_colors.dart';
import 'package:medecin_mobile/src/models/appointment_model.dart';

class DashboardDoctorScreen extends StatefulWidget {
  const DashboardDoctorScreen({Key? key}) : super(key: key);

  @override
  State<DashboardDoctorScreen> createState() => _DashboardDoctorScreenState();
}

class _DashboardDoctorScreenState extends State<DashboardDoctorScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const _DoctorHomeTab(),
    const _AppointmentsTab(),
    const _PatientsTab(),
    const _DoctorProfileTab(),
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Rendez-vous',
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
      ),
    );
  }
}

class _DoctorHomeTab extends StatelessWidget {
  const _DoctorHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthService>().currentUser!;
    
    // Mock data - replace with actual data from API
    final int totalAppointments = 128;
    final int todayAppointments = 8;
    final int pendingAppointments = 5;
    final double rating = 4.8;
    final int reviews = 87;
    
    // Mock upcoming appointments
    final List<Appointment> upcomingAppointments = [
      Appointment(
        id: '1',
        patient: User(
          id: '1',
          email: 'patient1@example.com',
          firstName: 'Jean',
          lastName: 'Dupont',
          userType: 'patient',
        ),
        doctor: user,
        appointmentDate: DateTime.now().add(const Duration(hours: 2)),
        timeSlot: '14:30 - 15:00',
        status: AppointmentStatus.confirmed,
        reason: 'Consultation de routine',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '2',
        patient: User(
          id: '2',
          email: 'patient2@example.com',
          firstName: 'Marie',
          lastName: 'Martin',
          userType: 'patient',
        ),
        doctor: user,
        appointmentDate: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
        timeSlot: '15:30 - 16:00',
        status: AppointmentStatus.pending,
        reason: 'Douleurs abdominales',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
              title: 'Bonjour, Dr. ${user.lastName}',
              subtitle: 'Comment s\'est passée votre journée ?',
              imageUrl: user.profileImage,
            ),
            const SizedBox(height: 24),
            
            // Stats cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _StatCard(
                  icon: Icons.calendar_today,
                  title: 'Aujourd\'hui',
                  value: todayAppointments.toString(),
                  color: AppColors.primary,
                ),
                _StatCard(
                  icon: Icons.pending_actions,
                  title: 'En attente',
                  value: pendingAppointments.toString(),
                  color: AppColors.warning,
                ),
                _StatCard(
                  icon: Icons.star,
                  title: 'Avis',
                  value: rating.toStringAsFixed(1),
                  subtitle: '($reviews avis)',
                  color: AppColors.rating,
                ),
                _StatCard(
                  icon: Icons.people,
                  title: 'Total patients',
                  value: totalAppointments.toString(),
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Today's schedule
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aujourd\'hui',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to appointments screen
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (upcomingAppointments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Aucun rendez-vous aujourd\'hui'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingAppointments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final appointment = upcomingAppointments[index];
                  return _AppointmentCard(appointment: appointment);
                },
              ),
            const SizedBox(height: 24),
            
            // Quick actions
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Nouveau RDV',
                  onTap: () {
                    // Add new appointment
                  },
                ),
                _QuickActionButton(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Nouveau patient',
                  onTap: () {
                    // Add new patient
                  },
                ),
                _QuickActionButton(
                  icon: Icons.medical_services_outlined,
                  label: 'Ordonnance',
                  onTap: () {
                    // Create prescription
                  },
                ),
                _QuickActionButton(
                  icon: Icons.insert_chart_outlined,
                  label: 'Statistiques',
                  onTap: () {
                    // View statistics
                  },
                ),
                _QuickActionButton(
                  icon: Icons.calendar_view_day_outlined,
                  label: 'Disponibilités',
                  onTap: () {
                    // Manage availability
                  },
                ),
                _QuickActionButton(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () {
                    // Go to settings
                  },
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rendez-vous'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Aujourd\'hui'),
              Tab(text: 'À venir'),
              Tab(text: 'Terminés'),
              Tab(text: 'Annulés'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Show filter options
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                // Show calendar picker
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Aujourd\'hui')),
            Center(child: Text('À venir')),
            Center(child: Text('Terminés')),
            Center(child: Text('Annulés')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add new appointment
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _PatientsTab extends StatelessWidget {
  const _PatientsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search patients
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter patients
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Liste des patients'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new patient
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _DoctorProfileTab extends StatelessWidget {
  const _DoctorProfileTab({Key? key}) : super(key: key);

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
          // Profile header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : const AssetImage('assets/images/default_doctor.png')
                              as ImageProvider,
                      child: user.profileImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Dr. ${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.specialty ?? 'Médecin généraliste',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(128 avis)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile sections
          _ProfileSection(
            title: 'Informations personnelles',
            items: [
              _ProfileItem(
                icon: Icons.email_outlined,
                title: 'Email',
                value: user.email,
                onTap: () {
                  // Edit email
                },
              ),
              _ProfileItem(
                icon: Icons.phone_outlined,
                title: 'Téléphone',
                value: user.phoneNumber ?? 'Non renseigné',
                onTap: () {
                  // Edit phone
                },
              ),
              _ProfileItem(
                icon: Icons.location_on_outlined,
                title: 'Adresse',
                value: user.address ?? 'Non renseignée',
                onTap: () {
                  // Edit address
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _ProfileSection(
            title: 'Informations professionnelles',
            items: [
              _ProfileItem(
                icon: Icons.medical_services_outlined,
                title: 'Spécialité',
                value: user.specialty ?? 'Non renseignée',
                onTap: () {
                  // Edit specialty
                },
              ),
              _ProfileItem(
                icon: Icons.school_outlined,
                title: 'Diplômes',
                value: 'Voir les diplômes',
                isLink: true,
                onTap: () {
                  // View diplomas
                },
              ),
              _ProfileItem(
                icon: Icons.work_outline,
                title: 'Expérience',
                value: '10+ ans d\'expérience',
                onTap: () {
                  // Edit experience
                },
              ),
              _ProfileItem(
                icon: Icons.monetization_on_outlined,
                title: 'Tarifs',
                value: 'Voir les tarifs',
                isLink: true,
                onTap: () {
                  // View/edit pricing
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Settings section
          _ProfileSection(
            title: 'Paramètres',
            items: [
              _ProfileItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // Notification settings
                },
              ),
              _ProfileItem(
                icon: Icons.lock_outline,
                title: 'Sécurité',
                onTap: () {
                  // Security settings
                },
              ),
              _ProfileItem(
                icon: Icons.language_outlined,
                title: 'Langue',
                value: 'Français',
                onTap: () {
                  // Change language
                },
              ),
              _ProfileItem(
                icon: Icons.help_outline,
                title: 'Aide & Support',
                onTap: () {
                  // Help & support
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Logout button
          Center(
            child: ElevatedButton.icon(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Déconnexion'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color statusColor;
    String statusText;
    
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'Confirmé';
        break;
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'En attente';
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.error;
        statusText = 'Annulé';
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.info;
        statusText = 'Terminé';
        break;
      default:
        statusColor = theme.hintColor;
        statusText = 'Inconnu';
    }
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: appointment.patient.profileImage != null
                      ? NetworkImage(appointment.patient.profileImage!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appointment.patient.firstName} ${appointment.patient.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${appointment.timeSlot} • ${appointment.reason ?? 'Sans motif'}' ,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View details or take action
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Voir détails'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Start consultation
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Démarrer'),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).primaryColor,
              size: 24,
            ),
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

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool isLink;
  final VoidCallback? onTap;

  const _ProfileItem({
    Key? key,
    required this.icon,
    required this.title,
    this.value,
    this.isLink = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 24),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: value != null
              ? Text(
                  value!,
                  style: TextStyle(
                    color: isLink
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                    fontWeight: isLink ? FontWeight.w500 : null,
                  ),
                )
              : null,
          trailing: onTap != null
              ? const Icon(Icons.chevron_right, size: 20)
              : null,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minLeadingWidth: 0,
        ),
        if (onTap != null)
          const Divider(height: 1, indent: 56),
      ],
    );
  }
}
