// ============================================
// FILE: lib/models/rescue_request.dart
// ============================================
import 'package:latlong2/latlong.dart';

class RescueRequest {
  final String name;
  final String contactPhone;
  final String code;
  final int adults;
  final int children;
  final int elderly;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> conditions;
  final String? description;
  final List<MediaFile> media;

  RescueRequest({
    required this.name,
    required this.contactPhone,
    required this.code,
    this.adults = 0,
    this.children = 0,
    this.elderly = 0,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.conditions = const [],
    this.description,
    this.media = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact_phone': contactPhone,
      'code': code,
      'adults': adults,
      'children': children,
      'elderly': elderly,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'conditions': conditions,
      'description': description,
      'media': media.map((m) => m.toJson()).toList(),
    };
  }
}

class MediaFile {
  final String type;
  final String data;
  final String name;

  MediaFile({required this.type, required this.data, required this.name});

  Map<String, dynamic> toJson() {
    return {'type': type, 'data': data, 'name': name};
  }
}
