import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/emoji_reaction.dart';

class MessageEmojiReactions extends StatelessWidget {
  const MessageEmojiReactions({
    required this.reactions,
    required this.isClosing,
    this.alignLeft,
    super.key,
  });

  final List<EmojiReaction> reactions;
  final bool isClosing;

  /// If provided, forces alignment to left or right.
  /// If null, alignment is automatically determined based on position.
  final bool? alignLeft;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    // Use the provided alignLeft value or calculate it automatically
    final shouldAlignLeft = alignLeft ?? _calculateAlignment(context, isRTL);

    final alignment = shouldAlignLeft
        ? isRTL
            ? Alignment.centerRight
            : Alignment.centerLeft
        : isRTL
            ? Alignment.centerLeft
            : Alignment.centerRight;

    // Use platform-specific styling
    final backgroundColor = isIOS
        ? CupertinoColors.systemBackground.resolveFrom(context)
        : theme.colorScheme.surface;

    final shadowColor = isIOS
        ? CupertinoColors.systemGrey.resolveFrom(context).withOpacity(0.2)
        : theme.colorScheme.shadow.withOpacity(0.3);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(50),
      elevation: isIOS ? 2 : 3,
      shadowColor: shadowColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reactions
              .asMap()
              .map(
                (index, reaction) => MapEntry(
                  index,
                  Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 4 : 0,
                      right: index == reactions.length - 1 ? 4 : 0,
                    ),
                    child: _buildEmojiReaction(
                      reaction,
                      index,
                      context,
                      isIOS: isIOS,
                      brightness: brightness,
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    )
        .animate(target: isClosing ? 0 : 1)
        .fadeIn(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        )
        .scaleXY(
          alignment: alignment,
          begin: 0,
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
  }

  Widget _buildEmojiReaction(
    EmojiReaction reaction,
    int index,
    BuildContext context, {
    required bool isIOS,
    required Brightness brightness,
  }) {
    final theme = Theme.of(context);

    // Define colors based on platform and theme
    final selectedColor = isIOS
        ? CupertinoColors.systemGrey5.resolveFrom(context)
        : theme.colorScheme.primaryContainer.withOpacity(0.5);

    final rippleColor = isIOS
        ? CupertinoColors.systemGrey3.resolveFrom(context)
        : theme.colorScheme.primary.withOpacity(0.2);

    final spaceBetween = isIOS ? 6.0 : 8.0;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: reaction.onPressed,
        borderRadius: BorderRadius.circular(50),
        splashColor: rippleColor,
        highlightColor: rippleColor.withOpacity(0.5),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.only(
            right: index == reactions.length - 1 ? 0 : spaceBetween,
          ),
          decoration: BoxDecoration(
            color: reaction.isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            reaction.emoji,
            style: TextStyle(
              fontSize: 22,
              // Apply a slight shadow effect for better readability
              shadows: brightness == Brightness.dark
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 1.0,
                      )
                    ]
                  : null,
            ),
          ),
        ),
      ),
    ).animate(target: isClosing ? 0 : 1).scaleX(
          begin: 0,
          end: 1,
          delay: Duration(milliseconds: index * 50),
          duration: Duration(
            milliseconds: 200 + (index * 50),
          ),
          curve: Curves.easeIn,
        );
  }

  /// Calculate the alignment based on the position of the widget on screen
  bool _calculateAlignment(BuildContext context, bool isRTL) {
    final screenWidth = MediaQuery.of(context).size.width;
    final box = context.findRenderObject() as RenderBox?;
    final position = box?.localToGlobal(Offset.zero);
    return position != null ? (position.dx < screenWidth / 2) != isRTL : !isRTL;
  }
}
