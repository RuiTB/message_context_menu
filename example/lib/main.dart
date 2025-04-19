import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:message_context_menu/message_context_menu.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Context Menu Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HeroPopupExample(),
    );
  }
}

class HeroPopupExample extends StatefulWidget {
  const HeroPopupExample({super.key});

  @override
  State<HeroPopupExample> createState() => _HeroPopupExampleState();
}

class _HeroPopupExampleState extends State<HeroPopupExample> {
  final messages = <Message>[
    Message(
      text: 'Hey! How are you?',
      isMe: true,
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      reactions: {'👍': true}, // This message has a thumbs up reaction
    ),
    Message(
      text: "I'm doing great! Just finished the new feature.",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Message(
      text: '''
Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis.''',
      isMe: false,
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      reactions: {'❤️': true}, // This message has a heart reaction
    ),
    Message(
      text: "Sure! I'll send you some screenshots.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Message(
      text: 'Looking forward to seeing them! 😊',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Context Menu Demo'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About alignLeft Parameter'),
                  content: const Text(
                    'This example demonstrates using the alignLeft parameter to control menu alignment.\n\n'
                    'For "my" messages (right side), alignLeft is set to false.\n\n'
                    'For other messages (left side), alignLeft is set to true.\n\n'
                    'This ensures consistent alignment regardless of screen position.\n\n'
                    'Some messages have reactions already selected (shown with a background).',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('About'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return Row(
                  mainAxisAlignment: message.isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    MessageContextMenu(
                      tag: 'message-$index',
                      alignLeft: !message.isMe,
                      actions: [
                        MessageAction(
                          icon: Icons.reply,
                          label: 'Reply',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Replied to: ${message.text.substring(0, math.min(20, message.text.length))}...',
                                ),
                              ),
                            );
                          },
                        ),
                        MessageAction(
                          icon: Icons.copy,
                          label: 'Copy',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message copied')),
                            );
                          },
                        ),
                        MessageAction(
                          icon: Icons.edit,
                          label: 'Edit',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit message')),
                            );
                          },
                        ),
                        MessageAction(
                          icon: Icons.forward,
                          label: 'Forward',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forward message')),
                            );
                          },
                        ),
                        MessageAction(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message deleted')),
                            );
                          },
                          isDestructive: true,
                        ),
                      ],
                      reactions: [
                        EmojiReaction(
                          emoji: '👍',
                          isSelected: message.reactions['👍'] ?? false,
                          onPressed: () {
                            setState(() {
                              if (message.reactions['👍'] == true) {
                                message.reactions.remove('👍');
                              } else {
                                message.reactions['👍'] = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message.reactions['👍'] == true
                                      ? 'Added 👍 reaction'
                                      : 'Removed 👍 reaction',
                                ),
                              ),
                            );
                          },
                        ),
                        EmojiReaction(
                          emoji: '❤️',
                          isSelected: message.reactions['❤️'] ?? false,
                          onPressed: () {
                            setState(() {
                              if (message.reactions['❤️'] == true) {
                                message.reactions.remove('❤️');
                              } else {
                                message.reactions['❤️'] = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message.reactions['❤️'] == true
                                      ? 'Added ❤️ reaction'
                                      : 'Removed ❤️ reaction',
                                ),
                              ),
                            );
                          },
                        ),
                        EmojiReaction(
                          emoji: '😂',
                          isSelected: message.reactions['😂'] ?? false,
                          onPressed: () {
                            setState(() {
                              if (message.reactions['😂'] == true) {
                                message.reactions.remove('😂');
                              } else {
                                message.reactions['😂'] = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message.reactions['😂'] == true
                                      ? 'Added 😂 reaction'
                                      : 'Removed 😂 reaction',
                                ),
                              ),
                            );
                          },
                        ),
                        EmojiReaction(
                          emoji: '😮',
                          isSelected: message.reactions['😮'] ?? false,
                          onPressed: () {
                            setState(() {
                              if (message.reactions['😮'] == true) {
                                message.reactions.remove('😮');
                              } else {
                                message.reactions['😮'] = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message.reactions['😮'] == true
                                      ? 'Added 😮 reaction'
                                      : 'Removed 😮 reaction',
                                ),
                              ),
                            );
                          },
                        ),
                        EmojiReaction(
                          emoji: '😢',
                          isSelected: message.reactions['😢'] ?? false,
                          onPressed: () {
                            setState(() {
                              if (message.reactions['😢'] == true) {
                                message.reactions.remove('😢');
                              } else {
                                message.reactions['😢'] = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message.reactions['😢'] == true
                                      ? 'Added 😢 reaction'
                                      : 'Removed 😢 reaction',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      child: MessageBubble(message: message),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMe;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              message.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
                if (message.reactions.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${message.reactions.length}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  Message({
    required this.text,
    this.isMe = false,
    DateTime? timestamp,
    this.isRead = false,
    Map<String, bool>? reactions,
  })  : timestamp = timestamp ?? DateTime.now(),
        reactions = reactions ?? {};

  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, bool> reactions; // Map of emoji to selection state
}
