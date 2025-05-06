import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApi {
  static const String baseUrl = 'https://englishbot-devs.onrender.com/'; // Updated URL
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login user and retrieve JWT token
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'), // Updated the endpoint path
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token']; // Adjusted key to 'access_token'
      await _storage.write(key: 'jwt_token', value: token); // Store the JWT token securely
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Signup user and retrieve JWT token
  static Future<String> signup(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'), // Updated the endpoint path
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token']; // Adjusted key to 'access_token'
      await _storage.write(key: 'jwt_token', value: token); // Store the JWT token securely
      return token;
    } else {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  // Fetch user details using JWT token
  static Future<Map<String, String>> getUserDetails(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/user'), // Corrected endpoint for user details
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'email': data['email'], // Assuming 'email' is returned in the response
        'username': data['username'], // Assuming 'username' is returned in the response
      };
    } else {
      throw Exception('Failed to fetch user details: ${response.body}');
    }
  }

  // Logout user and remove the JWT token
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token'); // Remove JWT token from storage
  }
}
