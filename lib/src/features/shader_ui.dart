import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import './filters/posterize_widget.dart';
import './ui/floating_button.dart';
import './camera/camera_widget.dart';
import './camera/screenshot_widget.dart';

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
        };
    }

    void toggleBoolShaderSetting(String key) {
        if (state[key].runtimeType != bool) {
            return;
        }
        //state[key] = !state[key];
        state = {...state, key: !state[key]};
    }

    void updateShaderSetting(String key, dynamic value) {
        state = {...state, key: value};
    }
}

final shaderProvider = StateNotifierProvider<ShaderState, Map<String, dynamic>>((ref) => ShaderState());

class ShaderUI extends ConsumerWidget {
    ShaderUI ({super.key});

    FloatingButtonController contrastController = FloatingButtonController();
    FloatingButtonController saturationController = FloatingButtonController();
    final double leftPaddingSliders = 15;
    final double columnPadding = 10;

    void resetAll(WidgetRef ref) {
        ref.read(shaderProvider.notifier).setDefaultShaderSettings();
        //reset contrast
        contrastController.updatePositionByPercent?.call(ref.read(shaderProvider.notifier).state['contrast/level'] / 2);
        contrastController.updateOption?.call(0);
        //reset saturation
        saturationController.updatePositionByPercent?.call(ref.read(shaderProvider.notifier).state['saturation/level'] / 2);
        saturationController.updateOption?.call(0);
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final shaderSettings = ref.watch(shaderProvider);
        final Size screenSize = MediaQuery.of(context).size;

        return Stack(
            children: [
                // Camera and filter stack
                ScreenshotWidget(),
                // flip controls
                // Color picker
                // Filter Slider UI
                Positioned(
                    top: screenSize.height / 2,
                    left: leftPaddingSliders,
                    child: Column(
                        children: [
                            FloatingButton(
                                sliderStartPos: 0.5,
                                toggleIcons: [Icon(Icons.ac_unit), Icon(Icons.add), Icon(Icons.adjust), Icon(Icons.airline_stops)],
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
                                    ref.read(shaderProvider.notifier).updateShaderSetting('contrast/level', newSettingPercent);
                                    contrastController.updatePositionByPercent?.call(newSettingPercent / 2);

                                },
                                onChanged: (val) {
                                    ref.read(shaderProvider.notifier).updateShaderSetting('contrast/level', 2 * val);
                                    contrastController.updateOption?.call(0); //reset icon to default, could be any but 0 is best
                                },
                                controller: contrastController,
                            ),
                            SizedBox(height: columnPadding),
                            FloatingButton(
                                sliderStartPos: 0.5,
                                toggleIcons: [Icon(Icons.color_lens), Icon(Icons.color_lens_outlined), Icon(Icons.color_lens, color: Colors.yellowAccent)],
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
                                    ref.read(shaderProvider.notifier).updateShaderSetting('saturation/level', newSettingPercent);
                                    saturationController.updatePositionByPercent?.call(newSettingPercent / 2);
                                },
                                onChanged: (val) {
                                    ref.read(shaderProvider.notifier).updateShaderSetting('saturation/level', 2 * val);
                                    saturationController.updateOption?.call(0);
                                },
                                controller: saturationController,
                            ),
                        ],
                    ),
                ),
            ],
        );
    }

    //@override
    //Widget build(BuildContext context, WidgetRef ref) {
    //    final shaderSettings = ref.watch(shaderProvider);
    //    return Scaffold(
    //        body: Column(
    //            children: [
    //                // posterize toggle and slider
    //                Padding(
    //                    padding: EdgeInsets.all(16.0),
    //                    child: Row(
    //                        mainAxisAlignment: MainAxisAlignment.center,
    //                        children: [
    //                            FloatingActionButton(
    //                                onPressed: () => resetAll(ref),
    //                                child: Icon(Icons.restart_alt),
    //                            ),
    //                            FloatingActionButton(
    //                                onPressed: () => ref.read(shaderProvider.notifier).toggleBoolShaderSetting('posterize/toRender'),
    //                                child: Icon(Icons.compare_rounded),
    //                            ),
    //                            Slider(
    //                                value: ref.read(shaderProvider.notifier).state['posterize/steps'],
    //                                max: 11.0,
    //                                min: 1.0,
    //                                divisions: 10,
    //                                label: ref.read(shaderProvider.notifier).state['posterize/steps'].toString(),
    //                                onChanged: (double value) {
    //                                    ref.read(shaderProvider.notifier).updateShaderSetting('posterize/steps', value);
    //                                },
    //                            ),
    //                        ],
    //                    ),
    //                ),
    //                // saturation slider
    //                Row(
    //                    mainAxisAlignment: MainAxisAlignment.center,
    //                    children: [
    //                        Text("saturation"),
    //                        Slider(
    //                            value: ref.read(shaderProvider.notifier).state['saturation/level'],
    //                            max: 2.0,
    //                            divisions: 200,
    //                            label: ref.read(shaderProvider.notifier).state['saturation/level'].toString(),
    //                            onChanged: (double value) {
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('saturation/level', value);
    //                            },
    //                        ),
    //                    ],
    //                ),
    //                // brightness slider
    //                Row(
    //                    mainAxisAlignment: MainAxisAlignment.center,
    //                    children: [
    //                        Text("brightness"),
    //                        Slider(
    //                            value: ref.read(shaderProvider.notifier).state['brightness/level'],
    //                            max: 2.0,
    //                            divisions: 200,
    //                            label: ref.read(shaderProvider.notifier).state['brightness/level'].toString(),
    //                            onChanged: (double value) {
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('brightness/level', value);
    //                            },
    //                        ),
    //                    ],
    //                ),
    //                // contrast slider
    //                Row(
    //                    mainAxisAlignment: MainAxisAlignment.center,
    //                    children: [
    //                        Text("contrast"),
    //                        Slider(
    //                            value: ref.read(shaderProvider.notifier).state['contrast/level'],
    //                            max: 2.0,
    //                            divisions: 200,
    //                            label: ref.read(shaderProvider.notifier).state['contrast/level'].toString(),
    //                            onChanged: (double value) {
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('contrast/level', value);
    //                            },
    //                        ),
    //                    ],
    //                ),
    //                Row(
    //                    mainAxisAlignment: MainAxisAlignment.center,
    //                    children: [
    //                        FloatingButton(
    //                            sliderStartPos: 0.5,
    //                            toggleIcons: [Icon(Icons.ac_unit), Icon(Icons.add), Icon(Icons.adjust), Icon(Icons.airline_stops)],
    //                            onTap: (option) {
    //                                double newSettingPercent = 1.0;
    //                                switch (option) {
    //                                    case 0:
    //                                        newSettingPercent = 1.0;
    //                                        break;
    //                                    case 1:
    //                                        newSettingPercent = 0.0;
    //                                        break;
    //                                    case 2:
    //                                        newSettingPercent = 0.5;
    //                                        break;
    //                                    case 3:
    //                                        newSettingPercent = 1.5;
    //                                        break;
    //                                }
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('contrast/level', newSettingPercent);
    //                                contrastController.updatePositionByPercent?.call(newSettingPercent / 2);

    //                            },
    //                            onChanged: (val) {
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('contrast/level', 2 * val);
    //                                contrastController.updateOption?.call(0); //reset icon to default, could be any but 0 is best
    //                            },
    //                            controller: contrastController,
    //                        ),
    //                        FloatingButton(
    //                            sliderStartPos: 0.5,
    //                            toggleIcons: [Icon(Icons.color_lens), Icon(Icons.color_lens_outlined), Icon(Icons.color_lens, color: Colors.yellowAccent)],
    //                            onTap: (option) {
    //                                double newSettingPercent = 1.0;
    //                                switch (option) {
    //                                    case 0:
    //                                        newSettingPercent = 1.0;
    //                                        break;
    //                                    case 1:
    //                                        newSettingPercent = 0.0;
    //                                        break;
    //                                    case 2:
    //                                        newSettingPercent = 2.0;
    //                                        break;
    //                                }
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('saturation/level', newSettingPercent);
    //                                saturationController.updatePositionByPercent?.call(newSettingPercent / 2);
    //                            },
    //                            onChanged: (val) {
    //                                ref.read(shaderProvider.notifier).updateShaderSetting('saturation/level', 2 * val);
    //                                saturationController.updateOption?.call(0);
    //                            },
    //                            controller: saturationController,
    //                        ),
    //                    ],
    //                ),
    //                Expanded(
    //                    child: ScreenshotWidget(),
    //                ),
    //            ],
    //        ),
    //    );
    //}
}

