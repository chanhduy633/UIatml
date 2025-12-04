// ============================================
// FILE: lib/services/rescue_service.dart
// ============================================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rescue_request.dart';

class RescueService {
  static const String baseUrl = 'YOUR_BACKEND_API_URL';

  static Future<bool> submitRequest(RescueRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rescue-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
