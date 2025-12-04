// ============================================
// FILE: lib/screens/rescue_form_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/rescue_request.dart';
import '../constants/province_map.dart';
import '../constants/conditions.dart';
import '../services/rescue_service.dart';
import '../utils/location_utils.dart';

class RescueFormScreen extends StatefulWidget {
  const RescueFormScreen({super.key});

  @override
  State<RescueFormScreen> createState() => _RescueFormScreenState();
}

class _RescueFormScreenState extends State<RescueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _adults = 0;
  int _children = 0;
  int _elderly = 0;
  LatLng? _currentLocation;
  String? _provinceCode;
  final List<String> _selectedConditions = [];
  final List<MediaFile> _mediaFiles = [];
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    _nameController.text = 'Nguyễn Văn A';
    _phoneController.text = '0912345678';
    _adults = 2;
    _children = 1;
    _elderly = 1;
    _selectedConditions.addAll(['Đói', 'Khát', 'Cần thuốc']);
    _descriptionController.text =
        'Nhà bị ngập sâu 2m, cần cứu trợ khẩn cấp. Có người già và trẻ em.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final location = await LocationUtils.getCurrentLocation();
    if (location != null) {
      setState(() => _currentLocation = location);

      final address = await LocationUtils.reverseGeocode(location);
      if (address != null) {
        _addressController.text = address;
        setState(() {
          _provinceCode = ProvinceMap.getProvinceCode(address);
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lấy vị trí. Vui lòng bật GPS.'),
          ),
        );
      }
    }

    setState(() => _isLoadingLocation = false);
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    for (var file in pickedFiles) {
      final bytes = await File(file.path).readAsBytes();
      final base64 = base64Encode(bytes);

      setState(() {
        _mediaFiles.add(
          MediaFile(
            type: 'image',
            data: 'data:image/jpeg;base64,$base64',
            name: file.name,
          ),
        );
      });
    }
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng lấy vị trí hiện tại')),
      );
      return;
    }

    if (_adults + _children + _elderly == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phải có ít nhất 1 người cần cứu trợ')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final code = ProvinceMap.generateCode(_provinceCode);

    final request = RescueRequest(
      name: _nameController.text.trim(),
      contactPhone: _phoneController.text.replaceAll(RegExp(r'\s'), ''),
      code: code,
      adults: _adults,
      children: _children,
      elderly: _elderly,
      address: _addressController.text.trim(),
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      conditions: _selectedConditions,
      description: _descriptionController.text.trim(),
      media: _mediaFiles,
    );

    final success = await RescueService.submitRequest(request);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF40C057), size: 32),
                SizedBox(width: 12),
                Text('Gửi thành công!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yêu cầu cứu trợ của bạn đã được gửi đi.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mã theo dõi:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B5BDB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Đội cứu trợ sẽ liên hệ với bạn sớm nhất có thể.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close form
                },
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Yêu Cầu Cứu Trợ'),
        backgroundColor: const Color(0xFFFA5252),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildPeopleSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildConditionsSection(),
            const SizedBox(height: 16),
            _buildDescriptionSection(),
            const SizedBox(height: 16),
            _buildMediaSection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return _buildCard(
      title: 'Thông tin liên hệ',
      icon: Icons.person,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên người liên hệ *',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại *',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            final phone = value.replaceAll(RegExp(r'\s'), '');
            if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
              return 'Số điện thoại không hợp lệ (10 số)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPeopleSection() {
    return _buildCard(
      title: 'Số người cần cứu trợ',
      icon: Icons.people,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCounter(
                'Người lớn',
                _adults,
                (val) => setState(() => _adults = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCounter(
                'Trẻ em',
                _children,
                (val) => setState(() => _children = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCounter(
                'Người già',
                _elderly,
                (val) => setState(() => _elderly = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people, color: Color(0xFF3B5BDB), size: 20),
              const SizedBox(width: 8),
              Text(
                'Tổng: ${_adults + _children + _elderly} người',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 24,
                color: const Color(0xFF3B5BDB),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 24,
                color: const Color(0xFF3B5BDB),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildCard(
      title: 'Vị trí',
      icon: Icons.location_on,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          icon: _isLoadingLocation
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.my_location),
          label: Text(
            _isLoadingLocation ? 'Đang lấy vị trí...' : 'Lấy vị trí hiện tại',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B5BDB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (_currentLocation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF40C057),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Đã lấy vị trí',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF40C057),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tọa độ: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                if (_provinceCode != null)
                  Text(
                    'Mã tỉnh: $_provinceCode',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B5BDB),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ chi tiết *',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập địa chỉ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConditionsSection() {
    return _buildCard(
      title: 'Tình trạng',
      icon: Icons.health_and_safety,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RescueConditions.all.map((condition) {
            final isSelected = _selectedConditions.contains(condition);
            return FilterChip(
              label: Text(condition),
              selected: isSelected,
              onSelected: (selected) => _toggleCondition(condition),
              selectedColor: const Color(0xFFFA5252),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _buildCard(
      title: 'Mô tả thêm',
      icon: Icons.description,
      children: [
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Mô tả chi tiết tình hình hiện tại...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return _buildCard(
      title: 'Ảnh/Video hiện trường',
      icon: Icons.camera_alt,
      children: [
        OutlinedButton.icon(
          onPressed: _pickMedia,
          icon: const Icon(Icons.upload),
          label: const Text('Chọn ảnh/video'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: Color(0xFF3B5BDB)),
            foregroundColor: const Color(0xFF3B5BDB),
          ),
        ),
        if (_mediaFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Đã chọn ${_mediaFiles.length} file',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaFiles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _mediaFiles.removeAt(index));
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFA5252),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'GỬI YÊU CẦU CỨU TRỢ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3B5BDB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}
