import 'package:digitaleye/src/features/ui/advanced_slider_widget.dart';
import 'package:digitaleye/src/features/ui/capture_button_widget.dart';
import 'package:digitaleye/src/features/ui/contrast_slider_widget.dart';
import 'package:digitaleye/src/features/ui/image_viewer_widget.dart';
import 'package:digitaleye/src/features/ui/mode_controls_widget.dart';
import 'package:digitaleye/src/features/ui/posterize_slider_widget.dart';
import 'package:digitaleye/src/features/ui/saturation_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import './ui/color_picker.dart';
import './ui/area_indicator_widget.dart';
import './camera/image_streamer_widget.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';

class ShaderState extends StateNotifier<Map<String, dynamic>> {
  ShaderState() : super({}) {
    setDefaultShaderSettings();
  }

  void setDefaultShaderSettings() {
    state = {
      'posterize/steps': 1.0,
      'posterize/toRender': false,
      'saturation/level': 1.0,
      'brightness/level': 1.0,
      'contrast/level': 1.0,
      'blur/strength': 0.0,
      'flip/horizontal': 0.0,
      'flip/vertical': 0.0,
    };
  }

  void toggleBoolShaderSetting(String key) {
    if (state[key].runtimeType != bool) {
      return;
    }
    //state[key] = !state[key];
    state = {...state, key: !state[key]};
  }

  dynamic getCurrentState(String key) {
    return state[key];
  }

  void updateShaderSetting(String key, dynamic value) {
    state = {...state, key: value};
  }
}

final shaderProvider = StateNotifierProvider<ShaderState, Map<String, dynamic>>(
  (ref) => ShaderState(),
);

class ShaderUI extends ConsumerWidget {
  ShaderUI({super.key});

  final AdvancedSliderController contrastController =
      AdvancedSliderController();
  final AdvancedSliderController saturationController =
      AdvancedSliderController();
  final AdvancedSliderController posterizeController =
      AdvancedSliderController();
  final AdvancedSliderController brightnessController =
      AdvancedSliderController();
  final AdvancedSliderController blurController = AdvancedSliderController();

  // Posterize starts at 2 value, so ten steps would give 2 -> 11
  final double posterizeSteps = 10.0;

  // TODO: These should be a static const somewhere to sync across app
  final double leftPaddingSliders = 15;
  final double edgePadding = 15;
  final double columnPadding = 10;

  void resetAll(WidgetRef ref) {
    ref.read(shaderProvider.notifier).setDefaultShaderSettings();

    //reset contrast
    contrastController.updatePositionByPercent?.call(
      ref.read(shaderProvider.notifier).getCurrentState('contrast/level') / 2,
    );
    contrastController.updateOption?.call(0);

    //reset saturation
    saturationController.updatePositionByPercent?.call(
      ref.read(shaderProvider.notifier).getCurrentState('saturation/level') / 2,
    );
    saturationController.updateOption?.call(0);

    //reset brightness
    brightnessController.updatePositionByPercent?.call(
      ref.read(shaderProvider.notifier).getCurrentState('brightness/level') / 2,
    );

    //reset blur
    blurController.updatePositionByPercent?.call(
      ref.read(shaderProvider.notifier).getCurrentState('blur/strength'),
    );

    //reset saturation
    posterizeController.updatePositionByPercent?.call(0);
    posterizeController.updateOption?.call(0);

    //reset position
    ref.read(movablePositionStateProvider.notifier).resetPosition();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    //final colorPickerWatcher = ref.watch(colorPickerProvider);
    final colorPickerMode = ref.watch(colorPickerProvider)["pickerMode"];
    final Size indicatorSize = Size.square(20);
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Camera and filter stack
        const ImageStreamer(),
        // Screenshot button
        Positioned(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: edgePadding),
              child: CaptureButtonWidget(),
            ),
          ),
        ),
        // flip and reset controls
        Positioned(
          bottom: edgePadding,
          right: edgePadding,
          child: Column(
            children: [
              BaseButtonWidget(
                onTap:
                    () => ref
                        .read(shaderProvider.notifier)
                        .updateShaderSetting(
                          'flip/horizontal',
                          1.0 - ref.read(shaderProvider)['flip/horizontal'],
                        ),
                icon: HugeIcons.strokeRoundedFlipHorizontal,
              ),
              SizedBox(height: columnPadding),
              BaseButtonWidget(
                onTap:
                    () => ref
                        .read(shaderProvider.notifier)
                        .updateShaderSetting(
                          'flip/vertical',
                          1.0 - ref.read(shaderProvider)['flip/vertical'],
                        ),
                icon: HugeIcons.strokeRoundedFlipVertical,
              ),
              SizedBox(height: columnPadding),
              BaseButtonWidget(
                onTap: () => resetAll(ref),
                icon: HugeIcons.strokeRoundedReload,
              ),
            ],
          ),
        ),
        // Pause camera and select from files
        Positioned(
          bottom: edgePadding,
          left: edgePadding,
          child: ModeControlsWidget(columnPadding: columnPadding),
        ),
        // Color picker
        Positioned(top: 0, right: 0, left: 0, child: const ColorPicker()),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Builder(
              builder: (context) {
                // TODO: Make this actually link to the true area
                switch (colorPickerMode) {
                  case ColorPickerMode.simple:
                    return AreaIndicatorWidget.crosshair(size: indicatorSize);
                  case ColorPickerMode.area:
                    return AreaIndicatorWidget.rect(size: indicatorSize);
                  default:
                    return AreaIndicatorWidget.crosshair(size: indicatorSize);
                }
              },
            ),
          ),
        ),
        // Filter Slider UI
        Positioned(
          top: screenSize.height / 2,
          left: leftPaddingSliders,
          child: Column(
            children: [
              // Contrast Slider
              ContrastSliderWidget(controller: contrastController),
              SizedBox(height: columnPadding),

              // Saturation Slider
              SaturationSliderWidget(controller: saturationController),
              SizedBox(height: columnPadding),

              // WARN: If these get to big break them into other files
              // Brightness Slider
              AdvancedSliderWidget(
                sliderStartPos: 0.5,
                onChanged: (val) {
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('brightness/level', 2 * val);
                },
                controller: brightnessController,
              ),

              SizedBox(height: columnPadding),

              // Posterize slider
              PosterizeSliderWidget(
                controller: posterizeController,
                posterizeSteps: posterizeSteps,
              ),
              SizedBox(height: columnPadding),

              // Blur Slider
              AdvancedSliderWidget(
                sliderStartPos: 0.0,
                onChanged: (val) {
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('blur/strength', val);
                },
                controller: blurController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
