import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../shader_ui.dart';
import './saturation_widget.dart';

class BlurWidget extends ConsumerWidget {
  BlurWidget({super.key});

  final SaturationWidget saturationWidget = SaturationWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderSettings = ref.watch(shaderProvider);
    final double strength = 1.0;

    return Builder(
      builder: (context) {
        return ShaderBuilder(
          assetKey: 'shaders/blur.frag',
          (BuildContext context, FragmentShader shader, _) => AnimatedSampler(
            (ui.Image image, Size size, Canvas canvas) {
              shader
                ..setFloat(0, size.width)
                ..setFloat(1, size.height)
                ..setFloat(2, 1.0)
                ..setFloat(3, 0.0)
                ..setFloat(4, shaderSettings['blur/strength'] ?? 0.0)
                ..setImageSampler(0, image);
              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            },
            // Static image to test shaders independent of camera
            //child: Image.asset('assets/test_image.jpg'),
            child: ShaderBuilder(
              assetKey: 'shaders/blur.frag',
              (BuildContext context, FragmentShader shader, _) =>
                  AnimatedSampler(
                    (ui.Image image, Size size, Canvas canvas) {
                      shader
                        ..setFloat(0, size.width)
                        ..setFloat(1, size.height)
                        ..setFloat(2, 0.0)
                        ..setFloat(3, 1.0)
                        ..setFloat(4, shaderSettings['blur/strength'] ?? 0.0)
                        ..setImageSampler(0, image);
                      canvas.drawRect(
                        Offset.zero & size,
                        Paint()..shader = shader,
                      );
                    },
                    // Static image to test shaders independent of camera
                    //child: Image.asset('assets/test_image.jpg'),
                    child: saturationWidget,
                  ),
            ),
          ),
        );
      },
    );
  }
}
