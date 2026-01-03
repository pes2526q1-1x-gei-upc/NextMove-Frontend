import 'package:google_maps_flutter/google_maps_flutter.dart';

class Company {
  final String name; // name és clau alternativa (unique + not null)
  final String? email;
  final String? url;
  final String? description;
  final String? logoUrl;
  final LatLng? location;

  Company({
    required this.name,
    required this.email,
    required this.url,
    this.description,
    this.logoUrl,
    this.location,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String,
      email: json['email'] as String?,
      url: json['url'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      location: json['location'] != null
          ? LatLng(
              json['location']['latitude'] as double,
              json['location']['longitude'] as double,
            )
          : null,
    );
  }
}
