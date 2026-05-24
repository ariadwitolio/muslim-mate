import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationDataSource {
  const LocationDataSource();

  Future<Position> determinePosition() async {
    try {
      return await (() async {
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw Exception('Location services are disabled.');
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied.');
        }

        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }

        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      })().timeout(const Duration(seconds: 20));
    } on TimeoutException catch (_) {
      throw Exception('Location request timed out.');
    }
  }

  Future<String> getLocationLabel(Position position) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'MuslimApp/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return 'Location unavailable';
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      if (body == null) {
        return 'Location unavailable';
      }

      final address = body['address'] as Map<String, dynamic>?;
      if (address == null) {
        return 'Location unavailable';
      }

      final kecamatan = _trimmed(address['city_district']) ?? _trimmed(address['suburb']);
      final kota = _trimmed(address['city']) ?? _trimmed(address['county']);
      final state = _trimmed(address['state']);

      if (kecamatan != null && kota != null) {
        return '$kecamatan, $kota';
      }
      if (kecamatan != null) {
        return kecamatan;
      }
      if (kota != null) {
        return kota;
      }
      if (state != null) {
        return state;
      }

      return 'Location unavailable';
    } catch (_) {
      return 'Location unavailable';
    }
  }

  String? _trimmed(Object? value) {
    final text = value?.toString().trim();
    return text?.isNotEmpty == true ? text : null;
  }
}
