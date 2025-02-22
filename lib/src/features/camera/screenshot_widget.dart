import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../filters/posterize_widget.dart';
import './image_streamer_widget.dart';
import 'dart:typed_data';

class ScreenshotWidget extends StatefulWidget {
    const ScreenshotWidget({super.key});

    @override
    _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
    Uint8List? _imageFile;
    ScreenshotController ssController = ScreenshotController();

    @override
    void initState() {
        super.initState();
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
        ssController.capture().then((Uint8List? image) {
            //Capture Done
            setState(() {
                _imageFile = image;
                saveImage();
            });
        }).catchError((onError) {
            print(onError);
        });
    }

    @override
    Widget build(BuildContext context) {
        final Size screenSize = MediaQuery.of(context).size;
        return Stack(
            children: [
                Screenshot(
                    controller: ssController,
                    child: ImageStreamer(),
                ),
                Positioned(
                    bottom: 10,
                    left: screenSize.width / 2,
                    child: FloatingActionButton(
                        onPressed: () => captureScreenshot(),
                        child: Icon(Icons.camera),
                    ),
                ),
            ],
        );
    }
}
