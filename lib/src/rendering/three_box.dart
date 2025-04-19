import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ThreeBox extends MultiChildRenderObjectWidget {
  /// Creates a ThreeBox widget with 1-3 children.
  ///
  /// The [anchorRect] defines the position and size of the main widget.
  /// The [margin] defines spacing between widgets.
  ThreeBox({
    required this.anchorRect,
    required super.children,
    super.key,
    this.margin = 8.0,
    this.alignLeft,
  }) : assert(
          children.isNotEmpty && children.length <= 3,
          'ThreeBox must have 1-3 children',
        );

  final Rect anchorRect;
  final double margin;

  /// If provided, forces alignment to left or right.
  /// If null, alignment is automatically determined based on position.
  final bool? alignLeft;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderThreeBox(anchorRect, margin, alignLeft);
  }

  @override
  void updateRenderObject(BuildContext context, RenderThreeBox renderObject) {
    renderObject
      ..anchorRect = anchorRect
      ..margin = margin
      ..alignLeft = alignLeft;
  }
}

class ThreeBoxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderThreeBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ThreeBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ThreeBoxParentData> {
  RenderThreeBox(this._anchorRect, this._margin, this._alignLeft);

  Rect _anchorRect;
  double _margin;
  bool? _alignLeft;

  // Cache for safe area calculation
  EdgeInsets? _cachedSafeArea;
  ui.ViewPadding? _lastMetrics;

  set anchorRect(Rect rect) {
    if (rect != _anchorRect) {
      _anchorRect = rect;
      markNeedsLayout();
    }
  }

  set margin(double m) {
    if (m != _margin) {
      _margin = m;
      markNeedsLayout();
    }
  }

  set alignLeft(bool? value) {
    if (value != _alignLeft) {
      _alignLeft = value;
      markNeedsLayout();
    }
  }

  // Get current safe area, with caching for performance
  EdgeInsets get _safeArea {
    final rootNode = owner?.rootNode;
    final currentView = rootNode is RenderView
        ? rootNode.flutterView
        : ui.PlatformDispatcher.instance.implicitView;

    if (currentView == null) {
      _cachedSafeArea = EdgeInsets.zero;
      _lastMetrics = null;
      return EdgeInsets.zero;
    }

    final currentViewPadding = currentView.viewPadding;

    // Only recalculate if cache is invalid
    if (_cachedSafeArea == null || currentViewPadding != _lastMetrics) {
      _cachedSafeArea = MediaQueryData.fromView(currentView).padding;
      _lastMetrics = currentViewPadding;
    }

    return _cachedSafeArea ?? EdgeInsets.zero;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ThreeBoxParentData) {
      child.parentData = ThreeBoxParentData();
    }
  }

  double scaleFactor = 1.0;

  @override
  void performLayout() {
    if (constraints.biggest.isEmpty) {
      size = Size.zero;
      return;
    }

    size = constraints.biggest;
    final children = getChildrenAsList();
    if (children.isEmpty) return;

    final safeArea = _safeArea;
    final safeRect = Rect.fromLTRB(
      safeArea.left,
      safeArea.top,
      size.width - safeArea.right,
      size.height - safeArea.bottom,
    );

    // Get references to the children
    final anchor = children[0];
    final below = children.length > 1 ? children[1] : null;
    final above = children.length > 2 ? children[2] : null;

    // Calculate safe horizontal constraints for children
    final maxSafeWidth = math.max<double>(0, safeRect.width);
    final childConstraints = BoxConstraints(maxWidth: maxSafeWidth);

    // Pre-layout secondary widgets to know their sizes
    final belowSize = _layoutOptionalChild(below, childConstraints);
    final aboveSize = _layoutOptionalChild(above, childConstraints);

    // Calculate scaling if needed to fit in available space
    scaleFactor = _calculateScaleFactor(
      safeRect.height,
      _anchorRect.height,
      belowSize.height,
      aboveSize.height,
    );

    // Scale and layout anchor widget
    final scaledAnchorWidth = _anchorRect.width;
    final scaledAnchorHeight = _anchorRect.height * scaleFactor;

    anchor.layout(
      BoxConstraints.tight(Size(scaledAnchorWidth, scaledAnchorHeight)),
      parentUsesSize: true,
    );
    final anchorSize = anchor.size;

    // Calculate initial position and adjust to fit
    final anchorPosition = _calculateAnchorPosition(
      _anchorRect.topLeft,
      anchorSize,
      belowSize,
      aboveSize,
      safeRect,
    );

    // Position the anchor widget
    final anchorParentData = anchor.parentData! as ThreeBoxParentData;
    anchorParentData.offset = anchorPosition;

    final finalAnchorRect = anchorPosition & anchorSize;

    // Position secondary widgets relative to the anchor
    _positionSecondaryWidgets(
      finalAnchorRect,
      below,
      above,
      belowSize,
      aboveSize,
      safeRect,
    );
  }

  // Layout an optional child and return its size
  Size _layoutOptionalChild(RenderBox? child, BoxConstraints constraints) {
    if (child == null) return Size.zero;

    child.layout(constraints, parentUsesSize: true);
    return child.size;
  }

  // Calculate scale factor based on available space
  double _calculateScaleFactor(
    double availableHeight,
    double anchorHeight,
    double belowHeight,
    double aboveHeight,
  ) {
    final totalMargin =
        (belowHeight > 0 ? _margin : 0) + (aboveHeight > 0 ? _margin : 0);
    final combinedHeight = belowHeight + aboveHeight + totalMargin;
    final combinedHeightWithAnchor = anchorHeight + combinedHeight;
    if (combinedHeightWithAnchor > availableHeight && availableHeight > 0) {
      return (availableHeight - combinedHeight) / anchorHeight;
    }
    return 1;
  }

  // Calculate anchor position with needed adjustments
  Offset _calculateAnchorPosition(
    Offset initialPosition,
    Size anchorSize,
    Size belowSize,
    Size aboveSize,
    Rect safeRect,
  ) {
    // Start with the initial position from anchorRect
    var position = initialPosition;

    // Calculate the top and bottom of the entire group
    final groupTop = aboveSize.height > 0
        ? position.dy - aboveSize.height - _margin
        : position.dy;

    final groupBottom = belowSize.height > 0
        ? position.dy + anchorSize.height + _margin + belowSize.height
        : position.dy + anchorSize.height;

    // Adjust vertically if needed
    double verticalShift = 0;
    if (groupTop < safeRect.top) {
      verticalShift = safeRect.top - groupTop;
    } else if (groupBottom > safeRect.bottom) {
      verticalShift = safeRect.bottom - groupBottom;
    }

    position = position.translate(0, verticalShift);

    // Ensure anchor stays within horizontal safe area
    double x = math.max(safeRect.left, position.dx);
    x = math.min(x, safeRect.right - anchorSize.width);

    return Offset(x, position.dy);
  }

  // Position the above and below widgets relative to anchor
  void _positionSecondaryWidgets(
    Rect anchorRect,
    RenderBox? below,
    RenderBox? above,
    Size belowSize,
    Size aboveSize,
    Rect safeRect,
  ) {
    // Determine if we should align to the left or right
    // Use provided alignLeft value if available, otherwise calculate based on position
    final alignLeft = _alignLeft ??
        (anchorRect.center.dx - safeRect.left) < safeRect.width / 2;

    // Position below widget
    if (below != null) {
      final parentData = below.parentData! as ThreeBoxParentData;
      var x = alignLeft ? anchorRect.left : anchorRect.right - belowSize.width;

      // Ensure it stays within safe area
      x = math.max(safeRect.left, x);
      x = math.min(x, safeRect.right - belowSize.width);

      parentData.offset = Offset(x, anchorRect.bottom + _margin);
    }

    // Position above widget
    if (above != null) {
      final parentData = above.parentData! as ThreeBoxParentData;
      var x = alignLeft ? anchorRect.left : anchorRect.right - aboveSize.width;

      // Ensure it stays within safe area
      x = math.max(safeRect.left, x);
      x = math.min(x, safeRect.right - aboveSize.width);

      parentData.offset = Offset(
        x,
        anchorRect.top - aboveSize.height - _margin,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    var index = 0;

    while (child != null) {
      final childParentData = child.parentData as ThreeBoxParentData;
      final childOffset = offset + childParentData.offset;

      if (index == 0) {
        final transform = Matrix4.identity()
          ..translate(childOffset.dx, childOffset.dy)
          ..scale(scaleFactor, scaleFactor);

        context.pushTransform(
          needsCompositing,
          Offset.zero,
          transform,
          (context, _) => context.paintChild(child!, Offset.zero),
        );
      } else {
        context.paintChild(child, childOffset);
      }

      child = childParentData.nextSibling;
      index++;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  // Helper to get children in order
  @override
  List<RenderBox> getChildrenAsList() {
    final children = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      children.add(child);
      child = (child.parentData! as ThreeBoxParentData).nextSibling;
    }
    return children;
  }
}
