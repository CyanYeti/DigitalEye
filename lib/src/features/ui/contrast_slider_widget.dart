import 'package:digitaleye/src/features/shader_ui.dart';
import 'package:digitaleye/src/features/ui/advanced_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContrastSliderWidget extends ConsumerWidget {
  final AdvancedSliderController controller;
  const ContrastSliderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdvancedSliderWidget(
      sliderStartPos: 0.5,
      toggleIcons: [
        Icon(Icons.ac_unit),
        Icon(Icons.add),
        Icon(Icons.adjust),
        Icon(Icons.airline_stops),
      ],
      onTap: (option) {
        double newSettingPercent = 1.0;
        switch (option) {
          case 0:
            newSettingPercent = 1.0;
            break;
          case 1:
            newSettingPercent = 0.0;
            break;
          case 2:
            newSettingPercent = 0.5;
            break;
          case 3:
            newSettingPercent = 1.5;
            break;
        }
        ref
            .read(shaderProvider.notifier)
            .updateShaderSetting('contrast/level', newSettingPercent);
        controller.updatePositionByPercent?.call(newSettingPercent / 2);
      },
      onChanged: (val) {
        ref
            .read(shaderProvider.notifier)
            .updateShaderSetting('contrast/level', 2 * val);
        controller.updateOption?.call(
          0,
        ); //reset icon to default, could be any but 0 is best
      },
      controller: controller,
    );
  }
}
