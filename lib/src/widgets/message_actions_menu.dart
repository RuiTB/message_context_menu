import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/message_action.dart';

class MessageActionsMenu extends StatelessWidget {
  const MessageActionsMenu({
    required this.actions,
    required this.isClosing,
    required this.isIOS,
    this.stepWidth = 100,
    this.alignLeft,
    super.key,
  });

  final List<MessageAction> actions;
  final bool isClosing;
  final bool isIOS;
  final double stepWidth;

  /// If provided, forces alignment to left or right.
  /// If null, alignment is automatically determined based on position.
  final bool? alignLeft;

  @override
  Widget build(BuildContext context) {
    // Determine if we should align left based on directionality and parent position
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Use the provided alignLeft value or calculate it automatically
    final shouldAlignLeft = alignLeft ?? _calculateAlignment(context, isRTL);

    final alignment = shouldAlignLeft
        ? isRTL
            ? Alignment.topRight
            : Alignment.topLeft
        : isRTL
            ? Alignment.topLeft
            : Alignment.topRight;

    Widget menu = isIOS ? _buildIOSMenu(context) : _buildMaterialMenu(context);

    return menu
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

  /// Calculate the alignment based on the position of the widget on screen
  bool _calculateAlignment(BuildContext context, bool isRTL) {
    final screenWidth = MediaQuery.of(context).size.width;
    final box = context.findRenderObject() as RenderBox?;
    final position = box?.localToGlobal(Offset.zero);
    return position != null ? (position.dx < screenWidth / 2) != isRTL : !isRTL;
  }

  Widget _buildIOSMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: IntrinsicWidth(
          stepWidth: stepWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions.map((action) {
              return CupertinoContextMenuAction(
                isDestructiveAction: action.isDestructive,
                trailingIcon: action.icon,
                onPressed: action.onPressed,
                child: Text(
                  action.label,
                  style: TextStyle(
                    color: action.isDestructive
                        ? CupertinoColors.destructiveRed
                        : action.color ?? CupertinoColors.label,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialMenu(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias, // This ensures ripples are properly clipped
      child: IntrinsicWidth(
        stepWidth: stepWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions.map((action) {
            final actionColor = action.isDestructive
                ? Theme.of(context).colorScheme.error
                : action.color ?? Theme.of(context).colorScheme.primary;

            return InkWell(
              onTap: action.onPressed,
              child: ListTile(
                leading: Icon(
                  action.icon,
                  color: actionColor,
                ),
                title: Text(
                  action.label,
                  style: action.isDestructive
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        )
                      : null,
                ),
                // Ensure the ListTile doesn't handle taps (we're using InkWell)
                onTap: null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
