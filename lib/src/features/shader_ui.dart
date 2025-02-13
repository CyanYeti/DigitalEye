import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import './filters/posterize_widget.dart';
import './camera/camera_widget.dart';

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
    const ShaderUI ({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final shaderSettings = ref.watch(shaderProvider);
        return Scaffold(
            body: Column(
                children: [
                    // posterize toggle and slider
                    Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                FloatingActionButton(
                                    onPressed: () => ref.read(shaderProvider.notifier).setDefaultShaderSettings(),
                                    child: Icon(Icons.restart_alt),
                                ),
                                FloatingActionButton(
                                    onPressed: () => ref.read(shaderProvider.notifier).toggleBoolShaderSetting('posterize/toRender'),
                                    child: Icon(Icons.compare_rounded),
                                ),
                                Slider(
                                    value: ref.read(shaderProvider.notifier).state['posterize/steps'],
                                    max: 11.0,
                                    min: 1.0,
                                    divisions: 10,
                                    label: ref.read(shaderProvider.notifier).state['posterize/steps'].toString(),
                                    onChanged: (double value) {
                                        ref.read(shaderProvider.notifier).updateShaderSetting('posterize/steps', value);
                                    },
                                ),
                            ],
                        ),
                    ),
                    // saturation slider
                    Slider(
                        value: ref.read(shaderProvider.notifier).state['saturation/level'],
                        max: 2.0,
                        divisions: 200,
                        label: ref.read(shaderProvider.notifier).state['saturation/level'].toString(),
                        onChanged: (double value) {
                            ref.read(shaderProvider.notifier).updateShaderSetting('saturation/level', value);
                        },
                    ),
                    // brightness slider
                    Slider(
                        value: ref.read(shaderProvider.notifier).state['brightness/level'],
                        max: 2.0,
                        divisions: 200,
                        label: ref.read(shaderProvider.notifier).state['brightness/level'].toString(),
                        onChanged: (double value) {
                            ref.read(shaderProvider.notifier).updateShaderSetting('brightness/level', value);
                        },
                    ),
                    // contrast slider
                    Slider(
                        value: ref.read(shaderProvider.notifier).state['contrast/level'],
                        max: 2.0,
                        divisions: 200,
                        label: ref.read(shaderProvider.notifier).state['contrast/level'].toString(),
                        onChanged: (double value) {
                            ref.read(shaderProvider.notifier).updateShaderSetting('contrast/level', value);
                        },
                    ),
                    Expanded(
                        child: PosterizeWidget(),
                    ),
                ],
            ),
        );
    }
}

