import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import './blur_widget.dart';
import '../shader_ui.dart';

class FlipWidget extends ConsumerWidget {
  FlipWidget({super.key});

  final BlurWidget blurWidget = BlurWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderSettings = ref.watch(shaderProvider);

    return ShaderBuilder(
      assetKey: 'shaders/flip.frag',
      (BuildContext context, FragmentShader shader, _) =>
          AnimatedSampler((ui.Image image, Size size, Canvas canvas) {
            shader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              //..setFloat(2, shaderSettings['contrast/level'] ?? 1)
              // flip h
              ..setFloat(2, shaderSettings['flip/horizontal'] ?? 0.0)
              // flip v
              ..setFloat(3, shaderSettings['flip/vertical'] ?? 0.0)
              ..setImageSampler(0, image);
            canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          }, child: blurWidget),
    );
  }
}
