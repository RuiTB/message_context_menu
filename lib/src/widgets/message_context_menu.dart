import 'dart:io';

import 'package:flutter/material.dart';

import '../models/emoji_reaction.dart';
import '../models/message_action.dart';
import 'message_popup_page.dart';

class MessageContextMenu extends StatelessWidget {
  const MessageContextMenu({
    required this.tag,
    required this.child,
    required this.actions,
    required this.reactions,
    this.enebled = true,
    this.alignLeft,
    super.key,
  });

  final String tag;
  final Widget child;
  final List<MessageAction> actions;
  final List<EmojiReaction> reactions;
  final bool enebled;

  /// If provided, forces alignment to left or right.
  /// If null, alignment is automatically determined based on position.
  final bool? alignLeft;

  void _handleLongPress(BuildContext context) {
    if (!enebled) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final topLeftGlobal = renderBox.localToGlobal(Offset.zero);
    final sourceRect = topLeftGlobal & renderBox.size;

    Navigator.of(context).push(
      _HeroPopupRoute(
        anchorRect: sourceRect,
        tag: tag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                child,
              ],
            ),
          ),
        ),
        actions: actions,
        reactions: reactions,
        isIOS: Platform.isIOS,
        alignLeft: alignLeft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: GestureDetector(
        onLongPress: () => _handleLongPress(context),
        child: child,
      ),
    );
  }
}

class _HeroPopupRoute extends PageRouteBuilder<void> {
  _HeroPopupRoute({
    required this.child,
    required this.anchorRect,
    required this.tag,
    required this.actions,
    required this.reactions,
    required this.isIOS,
    this.alignLeft,
  }) : super(
          opaque: false,
          barrierColor: const Color(0x6604040F),
          pageBuilder: (_, __, ___) => MessagePopupPage(
            anchorRect: anchorRect,
            tag: tag,
            actions: actions,
            reactions: reactions,
            isIOS: isIOS,
            alignLeft: alignLeft,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 500),
        );
  final Widget child;
  final Rect anchorRect;
  final String tag;
  final List<MessageAction> actions;
  final List<EmojiReaction> reactions;
  final bool isIOS;
  final bool? alignLeft;
}
