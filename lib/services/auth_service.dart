// services/auth_service.dart
class AuthService {
  static Map<String, dynamic>? _currentUser;

  static void login(String username, String password) {
    // Mock login logic
    if (username == 'user' && password == 'user123') {
      _currentUser = {
        'id': '1',
        'name': 'Jane Doe',
        'role': 'user',
        'phone': '(555) 123-4567',
      };
    } else if (username == 'rescue' && password == 'rescue123') {
      _currentUser = {
        'id': '2',
        'name': 'Rescue Team Alpha',
        'role': 'rescue',
        'phone': '(555) 999-0000',
      };
    }
  }

  static void logout() {
    _currentUser = null;
  }

  static Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  static bool isRescueTeam() {
    return _currentUser?['role'] == 'rescue';
  }

  static bool isUser() {
    return _currentUser?['role'] == 'user';
  }
}
