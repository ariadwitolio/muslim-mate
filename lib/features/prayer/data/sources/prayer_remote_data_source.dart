import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:muslim_mate/features/prayer/data/models/prayer_response_model.dart';

class PrayerRemoteDataSource {
  const PrayerRemoteDataSource();

  Future<PrayerResponseModel> fetchPrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    final dateString = DateFormat('dd-MM-yyyy').format(date);
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateString?latitude=$latitude&longitude=$longitude&method=11',
    );

    final httpResponse = await http.get(uri).timeout(const Duration(seconds: 15));
    if (httpResponse.statusCode != 200) {
      throw Exception('Prayer times fetch failed (${httpResponse.statusCode}).');
    }

    final body = jsonDecode(httpResponse.body) as Map<String, dynamic>?;
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid prayer times response.');
    }

    return PrayerResponseModel.fromJson(data, date);
  }
}
