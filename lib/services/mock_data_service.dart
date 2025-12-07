// services/mock_data_service.dart
import '../models/rescue_request.dart';
import 'request_service.dart';

class MockDataService {
  // Deprecated: Use RequestService instead
  static List<RescueRequest> getAllRequests() {
    return RequestService.getAllRequests();
  }

  static List<RescueRequest> getUserRequests(String userId) {
    return RequestService.getUserRequests(userId);
  }

  static RescueRequest? getRequestByCode(String code) {
    return RequestService.getRequestByCode(code);
  }
}
