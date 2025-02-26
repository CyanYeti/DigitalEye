import 'package:digitaleye/src/features/shader_ui.dart';
import 'package:digitaleye/src/features/ui/advanced_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PosterizeSliderWidget extends ConsumerWidget {
  final AdvancedSliderController controller;
  final double posterizeSteps;
  const PosterizeSliderWidget({
    super.key,
    required this.controller,
    required this.posterizeSteps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdvancedSliderWidget(
      sliderStartPos: 0.0,
      steps: posterizeSteps,
      toggleIcons: [
        Icon(Icons.expand_sharp),
        Icon(Icons.looks_two_rounded),
        Icon(Icons.looks_3_rounded),
        Icon(Icons.looks_5_rounded),
        Icon(Icons.nine_k),
      ],
      onTap: (option) {
        double steps = 0.0;
        switch (option) {
          case 0:
            ref
                .read(shaderProvider.notifier)
                .updateShaderSetting('posterize/toRender', false);
            break;
          case 1:
            steps = 1.0;
            break;
          case 2:
            steps = 2.0;
            break;
          case 3:
            steps = 4.0;
            break;
          case 4:
            steps = 8.0;
            break;
        }
        if (steps != 0.0) {
          ref
              .read(shaderProvider.notifier)
              .updateShaderSetting('posterize/toRender', true);
          ref
              .read(shaderProvider.notifier)
              .updateShaderSetting('posterize/steps', steps);
          controller.updatePositionByPercent?.call(
            ((steps - 1) / (posterizeSteps - 1)).toDouble(),
          );
        }
      },
      onChanged: (val) {
        double steps = (val * (posterizeSteps - 1) + 1).round().toDouble();
        ref
            .read(shaderProvider.notifier)
            .updateShaderSetting('posterize/toRender', true);
        ref
            .read(shaderProvider.notifier)
            .updateShaderSetting('posterize/steps', steps);
      },
      controller: controller,
    );
  }
}
