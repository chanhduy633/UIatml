// ============================================
// FILE: lib/utils/location_utils.dart
// ============================================
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationUtils {
  static Future<LatLng?> getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return null;
    }

    final locationData = await location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  static Future<String?> reverseGeocode(LatLng position) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?'
          'format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=vi';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'];
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
