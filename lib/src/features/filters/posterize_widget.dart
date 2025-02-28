import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import './brightness_widget.dart';
import '../shader_ui.dart';

class PosterizeWidget extends ConsumerWidget {
  PosterizeWidget({super.key});

  final BrightnessWidget brightnessWidget = BrightnessWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderSettings = ref.watch(shaderProvider);

    return Builder(
      builder: (context) {
        return ShaderBuilder(
          assetKey: 'shaders/posterize.frag',
          (BuildContext context, FragmentShader shader, _) => AnimatedSampler((
            ui.Image image,
            Size size,
            Canvas canvas,
          ) {
            shader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              ..setFloat(2, shaderSettings['posterize/steps'] ?? 1)
              ..setFloat(3, shaderSettings['posterize/toRender'] ? 1.0 : 0.0)
              ..setImageSampler(0, image);
            canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          }, child: brightnessWidget),
        );
      },
    );
  }
}
