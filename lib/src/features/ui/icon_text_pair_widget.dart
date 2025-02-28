import 'package:digitaleye/src/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

class IconTextPairWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  IconTextPairWidget({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(icon: icon, color: ColorPalette.bright1, size: 30),
        Text(label),
      ],
    );
  }
}
