import 'package:flutter/material.dart';

class MessageAction {
  const MessageAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final Color? color;
}
