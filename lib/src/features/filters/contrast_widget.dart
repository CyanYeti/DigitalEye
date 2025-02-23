import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import './saturation_widget.dart';
import '../shader_ui.dart';

class ContrastWidget extends ConsumerWidget {
    ContrastWidget({super.key});
    
    final SaturationWidget saturationWidget = SaturationWidget();

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final shaderSettings = ref.watch(shaderProvider);

        return ShaderBuilder(
            assetKey: 'shaders/contrast.frag',
            (BuildContext context, FragmentShader shader, _) => AnimatedSampler(
                (ui.Image image, Size size, Canvas canvas) {
                    shader
                        ..setFloat(0, size.width)
                        ..setFloat(1, size.height)
                        ..setFloat(2, shaderSettings['contrast/level'] ?? 1)
                        ..setImageSampler(0, image);
                    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
                },
                child: saturationWidget,
            ),
        );
    }
}
