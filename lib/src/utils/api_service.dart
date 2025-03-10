import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/utils/log.dart';

class ApiService {

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  static Future<http.Response> sendGetRequest(String endPoint) async {

    try {
      final response = await http.get(Uri.parse(endPoint), 
        headers: _defaultHeaders
      );

      if (response.statusCode != 200) {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown Error';
        throw Exception('Request failed with status ${response.statusCode} : $errorMessage');
      }

      return response;
    } catch (e) {
       Log.e('Error in GET request to $endPoint : $e');
      throw Exception('Error in GET request $e');
    }
  }

  static Future<http.Response> sendPostRequest(String endPoint, Map<String, dynamic> body) async {

    try {
      final response = await http.post(Uri.parse(endPoint), 
        body: jsonEncode(body),
        headers: _defaultHeaders);

      if (response.statusCode != 200) {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown Error';
        throw Exception('Request failed with status ${response.statusCode} : $errorMessage');
      }

      return response;
    } catch (e) {
      Log.e('Error in POST request to $endPoint : $e');
      throw Exception('Error in POST request $e');
    }
  }
   
  static Future<http.Response> sendPutRequest(String endPoint, Map<String, dynamic> body) async {

    try {
      final response = await http.put(Uri.parse(endPoint),
        body: jsonEncode(body),
        headers: _defaultHeaders
      );

      if (response.statusCode != 200) {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown Error';
        throw Exception('Request failed with status ${response.statusCode} : $errorMessage');
      }

      return response;
    } catch (e) {
      Log.e('Error in PUT request to $endPoint : $e');
      throw Exception('Error in PUT request $e');
    }
  }

  static Future<void> sendDeleteRequest(String endPoint) async {

    try {
      final response = await http.delete(Uri.parse(endPoint));

      if (response.statusCode != 200) {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown Error';
        throw Exception('Request failed with status ${response.statusCode} : $errorMessage');
      }

    } catch (e) {
      Log.e('Error in DELETE request to $endPoint : $e');
      //throw Exception('Error in DELETE request $e');
    }
  }
}
