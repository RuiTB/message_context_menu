import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/emoji_reaction.dart';
import '../models/message_action.dart';
import '../rendering/three_box.dart';
import 'message_actions_menu.dart';
import 'message_emoji_reactions.dart';

class MessagePopupPage extends StatefulWidget {
  const MessagePopupPage({
    required this.child,
    required this.anchorRect,
    required this.tag,
    required this.actions,
    required this.reactions,
    required this.isIOS,
    this.alignLeft,
    super.key,
  });

  final Widget child;
  final Rect anchorRect;
  final String tag;
  final List<MessageAction> actions;
  final List<EmojiReaction> reactions;
  final bool isIOS;

  /// If provided, forces alignment to left or right.
  /// If null, alignment is automatically determined based on position.
  final bool? alignLeft;

  @override
  State<MessagePopupPage> createState() => _MessagePopupPageState();
}

class _MessagePopupPageState extends State<MessagePopupPage>
    with SingleTickerProviderStateMixin {
  bool _isClosing = false;
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _blurAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(
        parent: _blurController,
        curve: Curves.easeOut,
      ),
    );
    _blurController.forward();
  }

  @override
  void dispose() {
    _blurController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    setState(() => _isClosing = true);
    Navigator.pop(context);

    _blurController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _blurAnimation,
          builder: (context, child) {
            return BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: Container(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                child: ThreeBox(
                  anchorRect: widget.anchorRect,
                  alignLeft: widget.alignLeft,
                  margin: 12.0,
                  children: [
                    Hero(
                      tag: widget.tag,
                      child: Material(
                        color: Colors.transparent,
                        child: widget.child,
                      ),
                    ),
                    MessageActionsMenu(
                      actions: widget.actions.map((action) {
                        return MessageAction(
                          icon: action.icon,
                          label: action.label,
                          onPressed: () {
                            _handleClose();
                            action.onPressed();
                          },
                          isDestructive: action.isDestructive,
                          color: action.color,
                        );
                      }).toList(),
                      isClosing: _isClosing,
                      isIOS: widget.isIOS,
                      alignLeft: widget.alignLeft,
                    ),
                    MessageEmojiReactions(
                      reactions: widget.reactions.map((reaction) {
                        return EmojiReaction(
                          emoji: reaction.emoji,
                          isSelected: reaction.isSelected,
                          onPressed: () {
                            _handleClose();
                            reaction.onPressed();
                          },
                        );
                      }).toList(),
                      isClosing: _isClosing,
                      alignLeft: widget.alignLeft,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
