import 'package:digitaleye/src/color_palette.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class AboutWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        BaseButtonWidget(icon: HugeIcons.strokeRoundedQuestion),
        Text(
          "This is the about me section",
          style: TextStyle(color: ColorPalette.bright1),
        ),
      ],
    );
  }
}
