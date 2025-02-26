import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../filters/posterize_widget.dart';
import './image_streamer_widget.dart';
import 'dart:typed_data';

final screenshotControllerProvider = Provider<ScreenshotController>((ref) {
  return ScreenshotController();
});

class ScreenshotWidget extends ConsumerStatefulWidget {
  final Widget child;
  const ScreenshotWidget({super.key, required this.child});

  @override
  _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends ConsumerState<ScreenshotWidget> {
  Uint8List? _imageFile;
  late final ScreenshotController ssController;
  late final Widget child;

  @override
  void initState() {
    super.initState();
    child = widget.child;
    ssController = ref.read(screenshotControllerProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void saveImage() async {
    final hasAccess = await Gal.hasAccess(toAlbum: true);

    if (!hasAccess) {
      await Gal.requestAccess(toAlbum: true);
    }

    await Gal.putImageBytes(_imageFile!);

    Gal.open();
  }

  void captureScreenshot() {
    ssController
        .capture()
        .then((Uint8List? image) {
          //Capture Done
          setState(() {
            _imageFile = image;
            saveImage();
          });
        })
        .catchError((onError) {
          debugPrint(onError);
        });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [Screenshot(controller: ssController, child: child)],
    );
  }
}
