import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../camera/camera_mode_widget.dart';
import '../shader_ui.dart';
import '../camera/camera_widget.dart';

class SaturationWidget extends ConsumerWidget {
  SaturationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderSettings = ref.watch(shaderProvider);
    // The first shader needs to watch for updates
    final cameraWatcher = ref.watch(cameraImageProvider);

    return Builder(
      builder: (context) {
        return ShaderBuilder(
          assetKey: 'shaders/saturation.frag',
          (BuildContext context, FragmentShader shader, _) => AnimatedSampler(
            (ui.Image image, Size size, Canvas canvas) {
              shader
                ..setFloat(0, size.width)
                ..setFloat(1, size.height)
                ..setFloat(2, shaderSettings['saturation/level'] ?? 1.0)
                ..setImageSampler(0, image);
              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            },
            // Static image to test shaders independent of camera
            //child: Image.asset('assets/test_image.jpg'),
            child: const CameraModeWidget(),
          ),
        );
      },
    );
  }
}
