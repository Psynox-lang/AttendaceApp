import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl =
      "http://10.99.191.76:8000";

  static Future<void> checkIn() async {

    final response = await http.post(
      Uri.parse("$baseUrl/checkin"),
    );

    print(response.body);
  }

  static Future<void> checkOut() async {

    final response = await http.post(
      Uri.parse("$baseUrl/checkout"),
    );

    print(response.body);
  }

  static Future<void> resetAttendance() async {

  await http.delete(
    Uri.parse("$baseUrl/reset"),
  );
}

  static Future<Map<String, dynamic>?> getStatus() async {

    final response = await http.get(
      Uri.parse("$baseUrl/status"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  static Future<void> approveAttendance() async {

  await http.post(
    Uri.parse(
      "$baseUrl/approve",
    ),
  );
}


  static Future<List<dynamic>> getAttendanceHistory() async {

  final response = await http.get(
    Uri.parse("$baseUrl/attendance"),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  return [];
}
}