import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_project_new/screens/home_screen.dart';
import 'package:mini_project_new/screens/login_screen.dart';
import 'package:mini_project_new/screens/signup_screen.dart';
import 'package:mini_project_new/theme/app_theme.dart';
import 'package:mini_project_new/api/auth_api.dart'; // Import AuthApi for authentication

void main() {
  runApp(const MyApp());
}

// Define User model to store user details
class User {
  final String email;
  final String username;

  User({required this.email, required this.username});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  User? _user;  // Store user as a User model
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  // Function to check if user is logged in by fetching the JWT token
  Future<void> _checkUserLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        // Fetch user details if token exists
        final userData = await AuthApi.getUserDetails(token);
        setState(() {
          _user = User(email: userData['email'] ?? "", username: userData['username'] ?? "");
        });
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

  // Function to update theme mode
  void updateTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Function to log in user and store JWT token
  void loginUser(String email, String username, String token) async {
    try {
      // Store the token
      await _storage.write(key: 'jwt_token', value: token);
      setState(() {
        _user = User(email: email, username: username);
      });
    } catch (e) {
      print("Login error: $e");
    }
  }


  // Function to log out user and delete JWT token
  void logoutUser() async {
    setState(() {
      _user = null; // Clear user data on logout
    });
    await _storage.delete(key: 'jwt_token'); // Remove JWT token securely
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talkie Tool',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => HomeScreen(
          user: _user != null
              ? {'email': _user!.email, 'username': _user!.username} // Convert User to Map
              : {},
          onThemeChange: updateTheme,
          onLogout: logoutUser, // Pass logout callback here
        ),
        '/login': (_) => LoginScreen(onLogin: loginUser),
        // Pass login callback here
        '/signup': (_) => SignupScreen(onSignup: loginUser), // Pass signup callback here
      },
    );
  }
}
