// models/rescue_request.dart
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
  final List<String> media;
  final DateTime requestTime;
  final String status; // "pending", "in_progress", "resolved", "cancelled"

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
    required this.conditions,
    this.description,
    required this.media,
    required this.requestTime,
    required this.status,
  });

  factory RescueRequest.fromJson(Map<String, dynamic> json) {
    return RescueRequest(
      name: json['name'],
      contactPhone: json['contact_phone'],
      code: json['code'],
      adults: json['adults'] ?? 0,
      children: json['children'] ?? 0,
      elderly: json['elderly'] ?? 0,
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      conditions: List<String>.from(json['conditions']),
      description: json['description'],
      media: List<String>.from(json['media']),
      requestTime: DateTime.parse(json['request_time']),
      status: json['status'],
    );
  }

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
      'media': media,
      'request_time': requestTime.toIso8601String(),
      'status': status,
    };
  }
}
