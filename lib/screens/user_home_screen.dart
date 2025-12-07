// screens/user_home_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'sos_form_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  bool _isPressed = false;
  double _pressProgress = 0.0;

  void _onSOSPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SOSFormScreen()),
    );
  }

  void _onSOSLongPressStart() {
    setState(() => _isPressed = true);
    _animatePress();
  }

  void _onSOSLongPressEnd() {
    setState(() {
      _isPressed = false;
      _pressProgress = 0.0;
    });
  }

  void _animatePress() async {
    for (int i = 0; i <= 30 && _isPressed; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isPressed) break;
      setState(() => _pressProgress = i / 30);

      if (i == 30) {
        _onSOSPressed();
        setState(() {
          _isPressed = false;
          _pressProgress = 0.0;
        });
      }
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Welcome text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?['name'] ?? 'User'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?['phone'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Logout button
                  TextButton(
                    onPressed: _logout,
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SOS Button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onLongPressStart: (_) => _onSOSLongPressStart(),
                  onLongPressEnd: (_) => _onSOSLongPressEnd(),
                  onTap: _onSOSPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress indicator
                      if (_isPressed)
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: CircularProgressIndicator(
                            value: _pressProgress,
                            strokeWidth: 8,
                            backgroundColor: Colors.red.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),

                      // Main button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: _isPressed ? 260 : 280,
                        height: _isPressed ? 260 : 280,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red
                                  .withOpacity(_isPressed ? 0.7 : 0.5),
                              blurRadius: _isPressed ? 40 : 30,
                              spreadRadius: _isPressed ? 15 : 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Instruction text
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    _isPressed
                        ? 'Hold for ${(3 - (_pressProgress * 3)).toStringAsFixed(1)}s...'
                        : 'Press and hold for 3 seconds\nor tap to open form',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A1F1F),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, '/user-history');
            } else {
              setState(() => _currentIndex = index);
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.white60,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
