import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({Key? key}) : super(key: key);

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });
  }


  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          _stopListening();
        }
      },
      onError: (error) {
        print("Speech recognition error: $error");
        _stopListening();
      },
    );

    if (!available) {
      print("Speech recognition unavailable.");
      return;
    }

    setState(() {
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) async {
        if (result.finalResult) {
          String text = result.recognizedWords;
          print("Recognized: $text");

          setState(() => _isListening = false);

          await _speech.stop();
          await _flutterTts.stop(); // Stop any ongoing AI speech
          await _getAIResponse(text);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }


  Future<void> _getAIResponse(String userInput) async {
    try {
      final String conversationId = "680e5a5e63a4ab96e9106bbb";
      final response = await http.post(
        Uri.parse('https://englishbot-devs.onrender.com/message/$conversationId/message'), // Replace with your actual API endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "content": userInput,
          "sender_id": "user",
          "mode": "basic", // Or use a toggle/setting if needed
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiReply = data["content"] ?? "I didn't catch that.";

        // Speak AI response
        await _speak(aiReply);
      } else {
        await _speak("Sorry, something went wrong with the server.");
      }
    } catch (e) {
      await _speak("An error occurred. Please try again later.");
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color aiColor = Colors.greenAccent.shade700;
    final Color userColor = Colors.blueAccent.shade700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top AppBar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Voice Chat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Voice Controls
              Positioned(
                bottom: 50,
                left: 30,
                right: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // AI Voice Icon (Disabled in this phase)
                    _voiceButton(icon: Icons.mic_none, label: "AI", color: aiColor, onTap: () {
                      // Optionally let user replay AI voice
                    }),

                    // User Voice Icon
                    _voiceButton(
                      icon: _isListening ? Icons.mic_off : Icons.mic,
                      label: _isListening ? "Stop" : "You",
                      color: userColor,
                      onTap: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          if (_isSpeaking) _flutterTts.stop(); // Interrupt AI
                          _startListening();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
