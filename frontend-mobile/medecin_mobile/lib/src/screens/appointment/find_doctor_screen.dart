import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medecin_mobile/src/models/doctor_model.dart';
import 'package:medecin_mobile/src/services/api_service.dart';
import 'package:medecin_mobile/src/widgets/doctor_card.dart';
import 'package:medecin_mobile/src/theme/app_colors.dart';

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({Key? key}) : super(key: key);

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 10;
  String _selectedSpecialty = 'Toutes les spécialités';
  String _selectedLocation = 'Tous les lieux';
  String _selectedSort = 'Pertinence';
  double _minRating = 0.0;
  
  final List<Doctor> _doctors = [];
  final List<String> _specialties = [
    'Toutes les spécialités',
    'Médecine générale',
    'Cardiologie',
    'Dermatologie',
    'Pédiatrie',
    'Gynécologie',
    'Ophtalmologie',
    'ORL',
    'Dentiste',
    'Orthopédie',
    'Neurologie',
  ];
  
  final List<String> _locations = [
    'Tous les lieux',
    'Abidjan',
    'Yamoussoukro',
    'Bouaké',
    'San-Pédro',
    'Korhogo',
    'Man',
    'Daloa',
  ];
  
  final List<String> _sortOptions = [
    'Pertinence',
    'Note la plus élevée',
    'Prix croissant',
    'Prix décroissant',
    'Distance la plus proche',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _doctors.clear();
      }
    });
    
    try {
      // In a real app, you would fetch doctors from your API
      // final response = await context.read<ApiService>().getDoctors(
      //   page: _currentPage,
      //   perPage: _perPage,
      //   search: _searchController.text,
      //   specialty: _selectedSpecialty != 'Toutes les spécialités' 
      //       ? _selectedSpecialty 
      //       : null,
      //   location: _selectedLocation != 'Tous les lieux' 
      //       ? _selectedLocation 
      //       : null,
      //   minRating: _minRating,
      //   sort: _selectedSort,
      // );
      
      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));
      
      final List<Doctor> newDoctors = List.generate(10, (index) {
        final specialties = [
          'Médecine générale',
          'Cardiologie',
          'Dermatologie',
          'Pédiatrie',
          'Gynécologie',
          'Ophtalmologie',
          'ORL',
          'Dentiste',
          'Orthopédie',
          'Neurologie',
        ];
        
        final locations = [
          'Abidjan',
          'Yamoussoukro',
          'Bouaké',
          'San-Pédro',
          'Korhogo',
          'Man',
          'Daloa',
        ];
        
        final names = [
          'Dr. Jean Dupont',
          'Dr. Marie Martin',
          'Dr. Pierre Dubois',
          'Dr. Sophie Laurent',
          'Dr. Thomas Bernard',
          'Dr. Julie Petit',
          'Dr. Michel Durand',
          'Dr. Isabelle Moreau',
          'Dr. Laurent Simon',
          'Dr. Nathalie Leroy',
        ];
        
        final name = names[index % names.length];
        final nameParts = name.split(' ');
        
        return Doctor(
          id: 'doc_${index + 1}',
          name: name,
          specialty: specialties[index % specialties.length],
          rating: 3.5 + (index % 4) * 0.5, // 3.5 to 5.0
          reviewCount: 10 + index * 5,
          distance: 0.5 + (index % 10) * 0.5, // 0.5 to 5.0 km
          location: locations[index % locations.length],
          description: 'Médecin spécialisé en ${specialties[index % specialties.length]} avec plusieurs années d\'expérience.',
          experienceYears: 5 + (index % 15),
          consultationFee: 5000.0 + (index % 10) * 1000.0, // 5000 to 14000 FCFA
          isAvailable: index % 5 != 0, // 80% available
          isFavorite: index % 4 == 0, // 25% favorite
          languages: const ['Français', 'Anglais'],
          education: [
            'Diplôme en médecine',
            'Spécialisation en ${specialties[index % specialties.length]}',
          ],
          specialties: [
            specialties[index % specialties.length],
            'Médecine générale',
          ],
          availability: [
            {
              'day': 'Lundi',
              'slots': ['09:00', '10:00', '11:00', '14:00', '15:00'],
            },
            {
              'day': 'Mardi',
              'slots': ['09:00', '10:00', '11:00', '14:00', '15:00'],
            },
            {
              'day': 'Mercredi',
              'slots': ['09:00', '10:00', '11:00', '14:00', '15:00'],
            },
          ],
          contactInfo: {
            'phone': '+225 01 23 45 67 89',
            'email': '${nameParts[1].toLowerCase()}.${nameParts[0].toLowerCase()}@example.com',
            'address': '${locations[index % locations.length]}, Côte d\'Ivoire',
          },
        );
      });
      
      setState(() {
        _doctors.addAll(newDoctors);
        _isLoading = false;
        _currentPage++;
        // In a real app, check if there are more pages
        // _hasMore = response.doctors.length == _perPage;
        _hasMore = false; // For demo, only load one page
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      _loadDoctors();
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSpecialty = 'Toutes les spécialités';
                        _selectedLocation = 'Tous les lieux';
                        _selectedSort = 'Pertinence';
                        _minRating = 0.0;
                      });
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Specialty filter
              const Text(
                'Spécialité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _specialties.map((specialty) {
                  return DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Location filter
              const Text(
                'Localisation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: const Icon(Icons.location_on_outlined),
                ),
                items: _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Rating filter
              const Text(
                'Note minimale',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _minRating == 0.0 ? 'Toutes' : '${_minRating.toInt()}+',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: _minRating,
                      min: 0.0,
                      max: 5.0,
                      divisions: 5,
                      label: _minRating == 0.0 
                          ? 'Toutes' 
                          : '${_minRating.toInt()}+',
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                        });
                      },
                    ),
                  ),
                  ...List.generate(5, (index) {
                    return Icon(
                      index < _minRating.round() 
                          ? Icons.star 
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),
              
              // Apply filters button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadDoctors(refresh: true);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver un médecin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un médecin, une spécialité...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _showFilters,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _loadDoctors(refresh: true),
            ),
          ),
          
          // Sort and filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Sort chip
                InputChip(
                  label: Text('Trier: $_selectedSort'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Trier par',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._sortOptions.map((option) {
                              return RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _selectedSort,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSort = value!;
                                  });
                                  Navigator.pop(context);
                                  _loadDoctors(refresh: true);
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  labelStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                
                // Specialty chip
                if (_selectedSpecialty != 'Toutes les spécialties')
                  InputChip(
                    label: Text(_selectedSpecialty),
                    onDeleted: () {
                      setState(() {
                        _selectedSpecialty = 'Toutes les spécialités';
                      });
                      _loadDoctors(refresh: true);
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  
                // Location chip
                if (_selectedLocation != 'Tous les lieux')
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InputChip(
                      label: Text(_selectedLocation),
                      onDeleted: () {
                        setState(() {
                          _selectedLocation = 'Tous les lieux';
                        });
                        _loadDoctors(refresh: true);
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: Colors.blue[50],
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  
                // Rating chip
                if (_minRating > 0.0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InputChip(
                      label: Text('${_minRating.toInt()}+ ⭐'),
                      onDeleted: () {
                        setState(() {
                          _minRating = 0.0;
                        });
                        _loadDoctors(refresh: true);
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: Colors.blue[50],
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
              ],
            ),
          ),
          
          // Doctors list
          Expanded(
            child: _isLoading && _doctors.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? const Center(
                        child: Text('Aucun médecin trouvé'),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadDoctors(refresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _doctors.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _doctors.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            
                            final doctor = _doctors[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: DoctorCard(
                                id: doctor.id,
                                name: doctor.name,
                                specialty: doctor.specialty,
                                rating: doctor.rating,
                                reviewCount: doctor.reviewCount,
                                distance: doctor.distance,
                                imageUrl: doctor.imageUrl,
                                isOnline: index % 3 == 0, // 33% online for demo
                                onTap: () {
                                  // Navigate to doctor details
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => DoctorDetailsScreen(doctor: doctor),
                                  //   ),
                                  // );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
