// ApiClient — HTTP service for lead submission.
// Reads API_BASE_URL from build-time dart-define.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';

class LeadSubmitException implements Exception {
  final String message;
  final int? statusCode;

  const LeadSubmitException(this.message, {this.statusCode});

  @override
  String toString() => 'LeadSubmitException($statusCode): $message';
}

class ApiClient {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  /// Submit a lead to the backend API.
  ///
  /// Throws [LeadSubmitException] on non-200 response or network error.
  static Future<void> submitLead(LeadModel lead) async {
    final Uri uri = Uri.parse('$_baseUrl/api/leads');
    try {
      final http.Response response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(lead.toJson()),
      );

      if (response.statusCode != 200) {
        throw LeadSubmitException(
          'Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on LeadSubmitException {
      rethrow;
    } catch (e) {
      throw LeadSubmitException('Network error: $e');
    }
  }
}
