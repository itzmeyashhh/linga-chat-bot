import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:mini_project_new/widgets/chat_input_bar.dart';
import 'package:mini_project_new/widgets/chat_bubble.dart';
import 'package:mini_project_new/widgets/profile_modal.dart';
import 'package:mini_project_new/screens/voice_chat_screen.dart';
import 'package:mini_project_new/api/auth_api.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, String> user;
  final Function(bool) onThemeChange;
  final Function onLogout;

  const HomeScreen({
    Key? key,
    required this.user,
    required this.onThemeChange,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> messages = [];
  final String conversationId = "680e5a5e63a4ab96e9106bbb";
  final _storage = const FlutterSecureStorage();
  bool isLoading = false;
  bool isAdvanced = false; // Toggle value for Basic/Pro mode

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadConversationHistory();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        final userData = await AuthApi.getUserDetails(token);
        setState(() {
          widget.user['email'] = userData['email'] ?? '';
          widget.user['username'] = userData['username'] ?? '';
        });
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

  Future<void> _loadConversationHistory() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://englishbot-devs.onrender.com/message/$conversationId/message'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages.clear();
          messages.addAll(data.map<Map<String, dynamic>>((msg) => {
            'role': msg['sender_id'] == 'user' ? 'user' : 'bot',
            'text': msg['content']
          }).toList());
        });
      } else {
        throw Exception('Failed to fetch conversation history');
      }
    } catch (e) {
      print('Error loading conversation history: $e');
    }
  }

  void _handleSend(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    try {
      final replyWidgets = await _sendMessageToBot(text);
      setState(() {
        messages.addAll(replyWidgets);
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Error: Failed to fetch response. $e"
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _sendMessageToBot(String message) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('User not logged in');

    try {
      final response = await http.post(
        Uri.parse('https://englishbot-devs.onrender.com/message/$conversationId/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': message,
          'sender_id': 'user',
          'mode': isAdvanced ? 'advanced' : 'basic', // send toggle state to backend
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'] ?? "No reply from AI.";
        final corrections = data['corrections'] ?? "No corrections provided.";
        final score = data['grammar_score'] != null ? "Grammar Score: ${data['grammar_score']}%" : "Score not available.";

        return [
          {"role": "bot", "text": content},
          {"role": "bot", "text": corrections, "isCorrection": true},
          {"role": "bot", "text": score, "isScore": true},
        ];
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      print('Error sending chat message: $e');
      throw Exception('Error: $e');
    }
  }

  void _newChat() {
    setState(() {
      messages.clear();
      messages.add({
        "role": "bot",
        "text": "Hi there! How can I help you prepare today?"
      });
    });
  }

  void _logout() async {
    await AuthApi.logout();
    widget.onLogout();
    setState(() {
      widget.user.clear();
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = widget.user.isNotEmpty;

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text("Previous Chats", style: TextStyle(fontSize: 20)),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("New Chat"),
              onTap: () {
                Navigator.pop(context);
                _newChat();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Talkie Tool"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Switch(
                      value: isAdvanced,
                      onChanged: (value) {
                        setState(() {
                          isAdvanced = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Switched to ${value ? "Pro" : "Basic"} Mode"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    if (isAdvanced)
                      const Positioned(
                        child: Text(
                          "Pro",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                loggedIn
                    ? IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ProfileModal(
                      email: widget.user['email'] ?? '',
                      username: widget.user['username'] ?? '',
                      onThemeToggle: widget.onThemeChange,
                      onLogout: _logout,
                    ),
                  ),
                )
                    : Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text("Login"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == messages.length && isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                final isCorrection = msg['isCorrection'] == true;
                final isScore = msg['isScore'] == true;

                Color? bubbleColor;
                if (isCorrection) {
                  bubbleColor = Colors.green[100];
                } else if (isScore) {
                  bubbleColor = Colors.red[100];
                }

                return ChatBubble(
                  text: msg['text'],
                  isUser: isUser,
                  bubbleColor: bubbleColor,
                );
              },
            ),
          ),
          const Divider(height: 1),
          ChatInputBar(
            onSend: _handleSend,
            onVoicePress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceChatScreen(),
                ),
              );
            },
          ),
          if (!loggedIn)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                "Guest mode enabled",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
