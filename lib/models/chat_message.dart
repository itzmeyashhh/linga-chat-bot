class ChatMessage {
  final String original;
  final String corrected;
  final String concise;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.original,
    required this.corrected,
    required this.concise,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'original': original,
      'corrected': corrected,
      'concise': concise,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      original: map['original'],
      corrected: map['corrected'],
      concise: map['concise'],
      isUser: map['isUser'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
