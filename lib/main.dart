// main.dart
import 'package:flutter/material.dart';
import 'screens/user_home_screen.dart';
import 'screens/user_history_screen.dart';
import 'screens/user_request_detail_screen.dart';
import 'screens/rescue_dashboard_screen.dart';
import 'screens/rescue_request_detail_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency SOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A0F0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/user-home': (context) => const UserHomeScreen(),
        '/user-history': (context) => const UserHistoryScreen(),
        '/rescue-dashboard': (context) => const RescueDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/user-request-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UserRequestDetailScreen(request: args),
          );
        }
        if (settings.name == '/rescue-request-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RescueRequestDetailScreen(request: args),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) {
      return const LoginScreen();
    }

    if (currentUser['role'] == 'rescue') {
      return const RescueDashboardScreen();
    }

    return const UserHomeScreen();
  }
}
