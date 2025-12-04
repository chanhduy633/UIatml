// ============================================
// FILE: lib/main.dart
// ============================================
import 'package:flutter/material.dart';
import 'screens/safety_dashboard.dart';

void main() => runApp(const SafetyApp());

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      home: const SafetyDashboard(),
    );
  }
}