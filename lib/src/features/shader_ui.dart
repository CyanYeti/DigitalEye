import 'package:digitaleye/src/features/ui/image_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import './ui/floating_button.dart';
import './ui/color_picker.dart';
import './camera/screenshot_widget.dart';
import './camera/camera_mode_widget.dart';
import './ui/area_indicator_widget.dart';
import './camera/image_streamer_widget.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';
import 'dart:typed_data';
import 'package:gal/gal.dart';

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

  final FloatingButtonController contrastController =
      FloatingButtonController();
  final FloatingButtonController saturationController =
      FloatingButtonController();
  final FloatingButtonController posterizeController =
      FloatingButtonController();
  final double posterizeSteps =
      10.0; // Posterize starts at 2 value, so ten steps would give 2 -> 11
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

    //reset position
    ref.read(movablePositionStateProvider.notifier).resetPosition();
  }

  void _toggleCameraFeed(WidgetRef ref) {
    final ImageMode imageMode = ref.read(imageStreamerModeProvider);
    if (imageMode == ImageMode.freezed || imageMode == ImageMode.selection) {
      _startCameraFeed(ref);
    } else {
      _pauseCameraFeed(ref);
    }
  }

  void _pauseCameraFeed(WidgetRef ref) {
    ref.read(movablePositionStateProvider.notifier).setUnlocked();
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.freezed;
  }

  void _startCameraFeed(WidgetRef ref) {
    ref.read(movablePositionStateProvider.notifier).resetPosition();
    ref.read(movablePositionStateProvider.notifier).setLocked();
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.camera;
  }

  void _startImageSelect(WidgetRef ref) {
    ref.read(movablePositionStateProvider.notifier).setUnlocked();
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.camera;
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.selection;
  }

  void saveImage(Uint8List? imageFile) async {
    if (imageFile == null) {
      return;
    }
    final hasAccess = await Gal.hasAccess(toAlbum: true);

    if (!hasAccess) {
      await Gal.requestAccess(toAlbum: true);
    }

    await Gal.putImageBytes(imageFile);

    Gal.open();
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
          bottom: 10,
          left: screenSize.width / 2 - 25,
          child: FloatingActionButton(
            onPressed: () {
              ref
                  .read(screenshotControllerProvider)
                  .capture()
                  .then((Uint8List? image) {
                    saveImage(image);
                  })
                  .catchError((onError) {
                    debugPrint(onError);
                  });
            },
            child: Icon(Icons.camera),
          ),
        ),
        // flip and reset controls
        Positioned(
          bottom: edgePadding,
          right: edgePadding,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed:
                    () => ref
                        .read(shaderProvider.notifier)
                        .updateShaderSetting(
                          'flip/horizontal',
                          1.0 - ref.read(shaderProvider)['flip/horizontal'],
                        ),
                child: Icon(Icons.swap_horiz),
              ),
              SizedBox(height: columnPadding),
              FloatingActionButton(
                onPressed:
                    () => ref
                        .read(shaderProvider.notifier)
                        .updateShaderSetting(
                          'flip/vertical',
                          1.0 - ref.read(shaderProvider)['flip/vertical'],
                        ),
                child: Icon(Icons.swap_vert),
              ),
              SizedBox(height: columnPadding),
              FloatingActionButton(
                onPressed: () => resetAll(ref),
                child: Icon(Icons.restart_alt),
              ),
            ],
          ),
        ),
        // Pause camera and select from files
        Positioned(
          bottom: edgePadding,
          left: edgePadding,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: () {
                  _toggleCameraFeed(ref);
                },
                child: Icon(Icons.pause_circle),
              ),
              SizedBox(height: columnPadding),
              FloatingActionButton(
                onPressed: () {
                  _startImageSelect(ref);
                },
                child: Icon(Icons.file_open),
              ),
            ],
          ),
        ),
        // Color picker
        Positioned(top: 0, right: 0, left: 0, child: const ColorPicker()),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Builder(
              builder: (context) {
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
              FloatingButton(
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
                  contrastController.updatePositionByPercent?.call(
                    newSettingPercent / 2,
                  );
                },
                onChanged: (val) {
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('contrast/level', 2 * val);
                  contrastController.updateOption?.call(
                    0,
                  ); //reset icon to default, could be any but 0 is best
                },
                controller: contrastController,
              ),

              SizedBox(height: columnPadding),

              // Saturation Slider
              FloatingButton(
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
                      .updateShaderSetting(
                        'saturation/level',
                        newSettingPercent,
                      );
                  saturationController.updatePositionByPercent?.call(
                    newSettingPercent / 2,
                  );
                },
                onChanged: (val) {
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('saturation/level', 2 * val);
                  saturationController.updateOption?.call(0);
                },
                controller: saturationController,
              ),

              SizedBox(height: columnPadding),

              // Brightness Slider
              FloatingButton(
                sliderStartPos: 0.5,
                onChanged: (val) {
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('brightness/level', 2 * val);
                },
              ),

              SizedBox(height: columnPadding),

              // Posterize slider
              FloatingButton(
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
                    posterizeController.updatePositionByPercent?.call(
                      ((steps - 1) / (posterizeSteps - 1)).toDouble(),
                    );
                  }
                },
                onChanged: (val) {
                  double steps =
                      (val * (posterizeSteps - 1) + 1).round().toDouble();
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('posterize/toRender', true);
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('posterize/steps', steps);
                },
                controller: posterizeController,
              ),

              SizedBox(height: columnPadding),

              // Blur Slider
              FloatingButton(
                sliderStartPos: 0.0,
                onChanged: (val) {
                  ref
                      .read(shaderProvider.notifier)
                      .updateShaderSetting('blur/strength', val);
                },
              ),
            ],
          ),
        ),
        // TODO: REMOVE THIS IS IT TEMP
        Positioned(
          child: Align(
            alignment: Alignment.center,
            child: BaseButtonWidget(
              icon: HugeIcons.strokeRoundedPlayCircle,
              mini: false,
            ),
          ),
        ),
      ],
    );
  }
}
