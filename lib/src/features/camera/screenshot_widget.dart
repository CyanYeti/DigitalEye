import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../filters/posterize_widget.dart';
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

        await Gal.requestAccess(toAlbum: true);

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
        return Column(
            children: [
                Expanded(
                    child: Screenshot(
                        controller: ssController,
                        child: PosterizeWidget(),
                    ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        FloatingActionButton(
                            onPressed: () => captureScreenshot(),
                            child: Icon(Icons.camera),
                        ),
                    ],
                ),
            ],
        );
    }
}
