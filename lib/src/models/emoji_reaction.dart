import 'package:flutter/material.dart';

class EmojiReaction {
  const EmojiReaction({
    required this.emoji,
    required this.onPressed,
    this.isSelected = false,
  });

  final String emoji;
  final VoidCallback onPressed;
  final bool isSelected;
}
