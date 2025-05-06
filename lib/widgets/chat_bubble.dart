import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color? bubbleColor; // Added optional bubbleColor parameter

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    this.bubbleColor, // Optional parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default bubble color based on user or bot
    final defaultBubbleColor = isUser
        ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
        : Theme.of(context).colorScheme.surfaceVariant;

    // Use the provided bubbleColor if available, otherwise fallback to default
    final currentBubbleColor = bubbleColor ?? defaultBubbleColor;

    final textColor = isUser ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(left: 8, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: currentBubbleColor, // Use the computed bubble color
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser)
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
