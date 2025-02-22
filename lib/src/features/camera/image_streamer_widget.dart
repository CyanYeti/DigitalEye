import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import '../filters/posterize_widget.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';


// This is just to provide the stream with the render objects key.
final screenshotGlobalKeyProvider = Provider<GlobalKey>((ref) {
    return GlobalKey();
});

final screenImageProvider = StreamProvider.autoDispose<ui.Image>((ref) async* {
    //final ssController = ref.read(screenshotControllerProvider);
    final globalKey = ref.read(screenshotGlobalKeyProvider);

    while (true) {
        // Throttle stream
        await Future.delayed(Duration(milliseconds: 200));
        try {
            final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final ui.Image image = await boundary.toImage();
            yield image;
            // This would let us broadcast a image. Since the other side is looking for an image, trying to save time on it
            //final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            //final Uint8List pngBytes = byteData!.buffer.asUint8List();
        } catch (e) {
            debugPrint("Error capturing screenshot in ImageStreamer");
        }
    }
});

class ImageStreamer extends ConsumerWidget {
    Uint8List? _imageFile;
    //GlobalKey globalKey = GlobalKey();

    Widget build(BuildContext context, WidgetRef ref) {
        //final ssController = ref.read(screenshotControllerProvider);
        final globalKey = ref.read(screenshotGlobalKeyProvider);
        return RepaintBoundary(
            key: globalKey,
            child: PosterizeWidget(),
        );
    }
}
