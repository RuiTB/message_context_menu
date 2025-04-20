import 'package:flutter/material.dart';

class EmojiReaction {
  const EmojiReaction({
    required this.emoji,
    required this.onPressed,
    this.autoClose = true,
    this.isSelected = false,
  });

  final String emoji;
  final Future<bool?>? Function(bool value, BuildContext context) onPressed;
  final bool isSelected;
  final bool autoClose;
}
