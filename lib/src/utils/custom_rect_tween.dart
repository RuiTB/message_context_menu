import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class CustomRectTween extends RectTween {
  CustomRectTween({required this.a, required this.b}) : super(begin: a, end: b);
  final Rect a;
  final Rect b;

  @override
  Rect lerp(double t) {
    final curve = Curves.elasticInOut.transform(t);

    return Rect.fromLTRB(
      lerpDouble(a.left, b.left, curve),
      lerpDouble(a.top, b.top, curve),
      lerpDouble(a.right, b.right, curve),
      lerpDouble(a.bottom, b.bottom, curve),
    );
  }

  double lerpDouble(num a, num b, double t) {
    return a + (b - a) * t;
  }
}
