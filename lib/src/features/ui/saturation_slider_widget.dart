import 'package:digitaleye/src/features/shader_ui.dart';
import 'package:digitaleye/src/features/ui/advanced_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaturationSliderWidget extends ConsumerWidget {
  final AdvancedSliderController controller;
  const SaturationSliderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdvancedSliderWidget(
      sliderStartPos: 0.5,
      toggleIcons: [
        Icon(Icons.color_lens),
        Icon(Icons.color_lens_outlined),
        Icon(Icons.color_lens, color: Colors.yellowAccent),
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
            newSettingPercent = 2.0;
            break;
        }
        ref
            .read(shaderProvider.notifier)
            .updateShaderSetting('saturation/level', newSettingPercent);
        controller.updatePositionByPercent?.call(newSettingPercent / 2);
      },
      onChanged: (val) {
        ref
            .read(shaderProvider.notifier)
            .updateShaderSetting('saturation/level', 2 * val);
        controller.updateOption?.call(0);
      },
      controller: controller,
    );
  }
}
