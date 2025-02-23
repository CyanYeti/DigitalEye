import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../camera/camera_widget.dart';

enum ImageMode { camera, still, select}

final imageStreamerModeProvider = StateProvider<ImageMode>((ref) => ImageMode.camera);

final imageModeGlobalKeyProvider = Provider<GlobalKey>((ref) {
    return GlobalKey();
});

final previousCapturedImageProvider = StateProvider<ui.Image?>((ref) => null);

class CameraModeWidget extends ConsumerWidget {

    Future<ui.Image?> _pausedView(WidgetRef ref) async {
        try {
            final globalKey = ref.read(imageModeGlobalKeyProvider);
            final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final ui.Image image = await boundary.toImage();
            ref.read(previousCapturedImageProvider.state).state = image;
            return image;
        } catch (e) {
            final ui.Image? previousImage = ref.read(previousCapturedImageProvider);
            if (previousImage != null) {
                return previousImage;
            } else {
                debugPrint("Error capturing camera still in CameraModeWidget");
            }
        }

    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final globalKey = ref.read(imageModeGlobalKeyProvider);
        final imageMode = ref.watch(imageStreamerModeProvider);

        return Builder(
            builder: (context) {
                switch(ref.read(imageStreamerModeProvider.notifier).state) {
                    case ImageMode.camera:
                        return RepaintBoundary(
                            key: globalKey,
                            child: CameraWidget(),
                        );
                    case ImageMode.still:
                        return FutureBuilder<ui.Image?>(
                            future: _pausedView(ref),
                            builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                    return CircularProgressIndicator();
                                }
                                return RawImage(
                                    image: snapshot.data!,
                                );
                            },
                        );
                    default:
                        return CircularProgressIndicator();
                }
            },
        );
    }
}
