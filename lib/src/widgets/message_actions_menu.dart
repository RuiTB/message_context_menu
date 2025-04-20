import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/message_action.dart';

class MessageActionsMenu extends StatelessWidget {
  MessageActionsMenu({
    required this.actions,
    required this.isClosing,
    required this.isIOS,
    this.stepWidth = 100,
    this.alignLeft,
    super.key,
  }) : _controller = ScrollController();

  static const double _kMenuWidth = 250.0;
  static const double _kScrollbarMainAxisMargin = 13.0;
  static const Color _borderColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFA9A9AF),
    darkColor: Color(0xFF57585A),
  );

  final List<MessageAction> actions;
  final bool isClosing;
  final bool isIOS;
  final double stepWidth;

  /// If provided, forces alignment to left or right.
  /// If null, alignment is automatically determined based on position.
  final bool? alignLeft;

  final ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    // Determine if we should align left based on directionality and parent position
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Use the provided alignLeft value or calculate it automatically
    final shouldAlignLeft = alignLeft ?? _calculateAlignment(context, isRTL);

    final alignment = shouldAlignLeft ? Alignment.topLeft : Alignment.topRight;

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
    return SizedBox(
      width: _kMenuWidth,
      child: IntrinsicHeight(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(13.0)),
          child: ColoredBox(
            color: CupertinoDynamicColor.resolve(
              CupertinoContextMenu.kBackgroundColor,
              context,
            ),
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: CupertinoScrollbar(
                mainAxisMargin: _kScrollbarMainAxisMargin,
                controller: _controller,
                child: SingleChildScrollView(
                  controller: _controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIOSAction(actions.first, context),
                      for (final action in actions.skip(1))
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: CupertinoDynamicColor.resolve(
                                  _borderColor,
                                  context,
                                ),
                                width: 0.4,
                              ),
                            ),
                          ),
                          position: DecorationPosition.foreground,
                          child: _buildIOSAction(action, context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSAction(MessageAction action, BuildContext context) {
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
