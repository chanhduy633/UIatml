// screens/sos_form_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/rescue_request.dart';
import '../services/province_service.dart';
import '../services/geocoding_service.dart';
import '../services/request_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class SOSFormScreen extends StatefulWidget {
  const SOSFormScreen({super.key});

  @override
  State<SOSFormScreen> createState() => _SOSFormScreenState();
}

class _SOSFormScreenState extends State<SOSFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _adults = 0;
  int _children = 0;
  int _elderly = 0;

  String? _selectedProvince;
  double? _latitude;
  double? _longitude;
  String? _address;

  final List<String> _selectedConditions = [];
  final List<String> _mediaUrls = [];

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  final List<String> _availableConditions = [
    'Medical Emergency',
    'Chest Pain',
    'Fall',
    'Unable to move',
    'Vehicle Accident',
    'Multiple Injuries',
    'Fire',
    'Trapped',
    'Breathing Difficulty',
    'Unconscious',
    'Bleeding',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _getCurrentLocation();
  }

  void _loadUserInfo() {
    final user = AuthService.getCurrentUser();
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _phoneController.text = user['phone'] ?? '';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final location = await LocationService.getCurrentLocation();
      final lat = location['latitude'];
      final lng = location['longitude'];

      if (lat == null || lng == null) {
        throw Exception('Location data is null');
      }

      final address = await GeocodingService.getAddressFromCoordinates(
        lat,
        lng,
      );

      setState(() {
        _latitude = lat;
        _longitude = lng;
        _address = address;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _mediaUrls.add(image.path);
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedConditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one condition')),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Generate request code
      final code =
          ProvinceService.generateCode(_selectedProvince ?? 'TP. Hồ Chí Minh');

      // Create new request
      final newRequest = RescueRequest(
        name: _nameController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        code: code,
        adults: _adults,
        children: _children,
        elderly: _elderly,
        address: _address ?? 'Unknown location',
        latitude: _latitude!,
        longitude: _longitude!,
        conditions: _selectedConditions,
        description: _descriptionController.text.trim(),
        media: _mediaUrls,
        requestTime: DateTime.now(),
        status: 'pending',
      );

      // Save request
      await RequestService.createRequest(newRequest);

      setState(() => _isSubmitting = false);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A1F1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text(
                  'SOS Sent!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your emergency request has been sent successfully.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Code:',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        code,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Help is on the way. Please stay calm and keep your phone nearby.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close form
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0F),
      appBar: AppBar(
        title: const Text('Emergency SOS Request'),
        backgroundColor: Colors.red,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Emergency Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fill in details for emergency assistance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Information Section
            const Text(
              'Contact Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Province Selection
            _buildProvinceDropdown(),

            const SizedBox(height: 24),

            // People Count Section
            const Text(
              'Number of People Involved',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                    child: _buildCounterCard('Adults', _adults,
                        (val) => setState(() => _adults = val))),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildCounterCard('Children', _children,
                        (val) => setState(() => _children = val))),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildCounterCard('Elderly', _elderly,
                        (val) => setState(() => _elderly = val))),
              ],
            ),

            const SizedBox(height: 24),

            // Emergency Conditions Section
            const Text(
              'Emergency Conditions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableConditions.map((condition) {
                final isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConditions.add(condition);
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                  backgroundColor: const Color(0xFF2A1F1F),
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Description Section
            const Text(
              'Additional Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe the emergency situation...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A1F1F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Location Section
            const Text(
              'Location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isLoadingLocation
                              ? 'Getting your location...'
                              : _address ?? 'Location not available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_latitude != null && _longitude != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Location'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Media Upload Section
            const Text(
              'Photos/Videos (Optional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_mediaUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1F1F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeMedia(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photo/Video'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SEND SOS REQUEST',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedProvince,
      dropdownColor: const Color(0xFF2A1F1F),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Province/City',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.location_city, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: ProvinceService.PROVINCE_MAP.keys.map((province) {
        return DropdownMenuItem(
          value: province,
          child: Text(province),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedProvince = value);
      },
    );
  }

  Widget _buildCounterCard(String label, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.red,
                onPressed: () => onChanged(value + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
