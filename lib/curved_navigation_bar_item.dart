import 'package:flutter/material.dart';

class CurvedNavigationBarItem {
  /// Icon of [CurvedNavigationBarItem].
  final Widget Function(int, double) childBuilder;

  /// Text of [CurvedNavigationBarItem].
  final String? label;

  /// TextStyle for [label].
  final TextStyle? labelStyle;

  final Widget Function(int, double)? labelBuilder;

  const CurvedNavigationBarItem({
    required this.childBuilder,
    this.label,
    this.labelStyle,
    this.labelBuilder,
  });
}
