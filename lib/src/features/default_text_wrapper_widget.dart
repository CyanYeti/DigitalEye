import 'package:digitaleye/src/color_palette.dart';
import 'package:flutter/material.dart';

// Wrap a child in a consistent text default text style
// Useful for overlay widgets
class DefaultTextWrapperWidget extends StatelessWidget {
  final Widget child;
  const DefaultTextWrapperWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: ColorPalette.bright1, fontSize: 16),
      child: child,
    );
  }
}
