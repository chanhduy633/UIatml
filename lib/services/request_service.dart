// services/request_service.dart
import '../models/rescue_request.dart';

class RequestService {
  static final List<RescueRequest> _requests = [
    // Initial mock data
    RescueRequest(
      name: 'John Doe',
      contactPhone: '(555) 234-5678',
      code: 'HCM-482193',
      adults: 1,
      children: 0,
      elderly: 0,
      address: '123 Main St, Anytown, HCMC',
      latitude: 10.7829,
      longitude: 106.6962,
      conditions: ['Medical Emergency', 'Chest Pain'],
      description: 'Experiencing severe chest pain and difficulty breathing.',
      media: [],
      requestTime: DateTime(2023, 10, 26, 8, 15),
      status: 'resolved',
    ),
    RescueRequest(
      name: 'Sarah Connor',
      contactPhone: '(555) 345-6789',
      code: 'HCM-123456',
      adults: 0,
      children: 2,
      elderly: 1,
      address: '456 Oak Ave, Somewhere City, HCMC',
      latitude: 10.7925,
      longitude: 106.7018,
      conditions: ['Vehicle Accident', 'Multiple Injuries'],
      description: 'Car accident at intersection. Need immediate assistance.',
      media: [],
      requestTime: DateTime(2023, 10, 25, 11, 30),
      status: 'in_progress',
    ),
    RescueRequest(
      name: 'Robert Brown',
      contactPhone: '(555) 456-7890',
      code: 'HCM-654321',
      adults: 1,
      children: 0,
      elderly: 0,
      address: '789 Pine Ln, Elsewhere, HCMC',
      latitude: 10.7701,
      longitude: 106.6956,
      conditions: ['Fire', 'Trapped'],
      description: 'Building fire. Trapped on 3rd floor.',
      media: [],
      requestTime: DateTime(2023, 10, 24, 21, 0),
      status: 'cancelled',
    ),
  ];

  // Get all requests
  static List<RescueRequest> getAllRequests() {
    // Sort by request time, newest first
    final sorted = List<RescueRequest>.from(_requests);
    sorted.sort((a, b) => b.requestTime.compareTo(a.requestTime));
    return sorted;
  }

  // Get requests for specific user
  static List<RescueRequest> getUserRequests(String userName) {
    final filtered = _requests.where((req) => req.name == userName).toList();
    filtered.sort((a, b) => b.requestTime.compareTo(a.requestTime));
    return filtered;
  }

  // Get request by code
  static RescueRequest? getRequestByCode(String code) {
    try {
      return _requests.firstWhere((req) => req.code == code);
    } catch (e) {
      return null;
    }
  }

  // Create new request
  static Future<void> createRequest(RescueRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _requests.add(request);
  }

  // Update request status
  static Future<void> updateRequestStatus(String code, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _requests.indexWhere((req) => req.code == code);
    if (index != -1) {
      final oldRequest = _requests[index];
      _requests[index] = RescueRequest(
        name: oldRequest.name,
        contactPhone: oldRequest.contactPhone,
        code: oldRequest.code,
        adults: oldRequest.adults,
        children: oldRequest.children,
        elderly: oldRequest.elderly,
        address: oldRequest.address,
        latitude: oldRequest.latitude,
        longitude: oldRequest.longitude,
        conditions: oldRequest.conditions,
        description: oldRequest.description,
        media: oldRequest.media,
        requestTime: oldRequest.requestTime,
        status: newStatus,
      );
    }
  }

  // Delete request
  static Future<void> deleteRequest(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _requests.removeWhere((req) => req.code == code);
  }

  // Get statistics
  static Map<String, int> getStatistics() {
    return {
      'total': _requests.length,
      'pending': _requests.where((r) => r.status == 'pending').length,
      'in_progress': _requests.where((r) => r.status == 'in_progress').length,
      'resolved': _requests.where((r) => r.status == 'resolved').length,
      'cancelled': _requests.where((r) => r.status == 'cancelled').length,
    };
  }
}
