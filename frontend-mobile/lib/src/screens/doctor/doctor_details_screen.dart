import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medecin_mobile/src/models/doctor_model.dart';
import 'package:medecin_mobile/src/theme/app_colors.dart';
import 'package:medecin_mobile/src/widgets/primary_button.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Doctor doctor;
  
  const DoctorDetailsScreen({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isFavorite = widget.doctor.isFavorite;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }
  
  void _bookAppointment() {
    // TODO: Implement book appointment navigation
  }
  
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      // TODO: Update favorite status in the backend
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite 
            ? 'Ajouté aux favoris' 
            : 'Retiré des favoris'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctor = widget.doctor;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Dr. ${doctor.name.split(' ').sublist(1).join(' ')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Hero(
                  tag: 'doctor-${doctor.id}',
                  child: doctor.imageUrl != null
                      ? Image.network(
                          doctor.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(doctor),
                        )
                      : _buildPlaceholderAvatar(doctor),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: theme.primaryColor,
                    unselectedLabelColor: theme.hintColor,
                    indicatorColor: theme.primaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'À propos'),
                      Tab(text: 'Disponibilités'),
                      Tab(text: 'Avis'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _AboutTab(doctor: doctor),
            _AvailabilityTab(doctor: doctor),
            _ReviewsTab(doctor: doctor),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${doctor.consultationFee.toInt()} FCFA',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'par consultation',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                onPressed: _bookAppointment,
                text: 'Prendre RDV',
                icon: Icons.calendar_today,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderAvatar(Doctor doctor) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Center(
        child: Text(
          doctor.name.split(' ').map((e) => e[0]).join(),
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Doctor doctor;
  
  const _AboutTab({
    Key? key,
    required this.doctor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section
          const Text(
            'À propos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.description ?? 'Aucune description disponible.',
            style: TextStyle(
              fontSize: 14,
              color: theme.hintColor,
              height: 1.5,
            ),
          ),
          
          // Experience and patients
          const SizedBox(height: 24),
          Row(
            children: [
              _InfoChip(
                icon: Icons.work_outline,
                label: 'Expérience',
                value: '${doctor.experienceYears}+ ans',
              ),
              const SizedBox(width: 16),
              _InfoChip(
                icon: Icons.people_outline,
                label: 'Patients',
                value: '${doctor.reviewCount * 10}+',
              ),
            ],
          ),
          
          // Specialties
          const SizedBox(height: 24),
          const Text(
            'Spécialités',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (doctor.specialties ?? [doctor.specialty]).map((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Education
          if (doctor.education != null && doctor.education!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Formation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...doctor.education!.map((degree) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      degree,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          // Languages
          if (doctor.languages != null && doctor.languages!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Langues parlées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: doctor.languages!.map((language) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    language,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Contact info
          const SizedBox(height: 24),
          const Text(
            'Coordonnées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (doctor.contactInfo?['address'] != null)
            _ContactInfoItem(
              icon: Icons.location_on_outlined,
              title: 'Adresse',
              value: doctor.contactInfo!['address'],
              onTap: () => _launchUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(doctor.contactInfo!['address'])}'),
            ),
          if (doctor.contactInfo?['phone'] != null)
            _ContactInfoItem(
              icon: Icons.phone_outlined,
              title: 'Téléphone',
              value: doctor.contactInfo!['phone'],
              onTap: () => _launchUrl('tel:${doctor.contactInfo!['phone']}'),
            ),
          if (doctor.contactInfo?['email'] != null)
            _ContactInfoItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: doctor.contactInfo!['email'],
              onTap: () => _launchUrl('mailto:${doctor.contactInfo!['email']}'),
            ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _InfoChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).primaryColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  
  const _ContactInfoItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
