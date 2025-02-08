import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  bool useShader = true;
  double _currentSaturation = 1.0;

  // get list of cameras async
  final Future<List<CameraDescription>> _camerasFuture = availableCameras();
  late CameraDescription camera;
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    //start pulling camera data on init
    _camerasFuture.then((cameras) {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        controller?.startImageStream((image) => setState(() {}));
      }).catchError((Object e) => print(e));
    });
  }

  //Future<void> initializeCamera() async {
  //  final cameras = await availableCameras();

  //  controller = CameraController(cameras[0], ResolutionPreset.max);

  //  await controller.initialize();
  //}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget scaledCameraWidget(context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    var camera = controller!.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;
        

    //double aspectRatio = camera.previewSize!.height / camera.previewSize!.width;
    //double scale = size.height / (size.width * aspectRatio);
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera!.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        Slider(
          value: _currentSaturation,
          max: 2.0,
          divisions: 100,
          label: _currentSaturation.toString(),
          onChanged: (double value) {
            setState(() {_currentSaturation = value;});
          },
        ),
      ]),
      body: FutureBuilder(
        future: _camerasFuture,
        builder: (context, snapshot) {
          if (controller != null && snapshot.connectionState == ConnectionState.done) {
            if (useShader) {
              return ShaderBuilder(
                assetKey: 'shaders/saturation.frag',
                (BuildContext context, FragmentShader shader, _) => AnimatedSampler(
                  (ui.Image image, Size size, Canvas canvas) {
                    shader
                      ..setFloat(0, size.width)
                      ..setFloat(1, size.height)
                      ..setFloat(2, _currentSaturation)
                      ..setImageSampler(0, image);
                    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
                  },
                  //child: CameraPreview(controller),
                  child: Center(
                    child: scaledCameraWidget(context),
                  ),
                ),
              );
            } else {
              return Center(child: CameraPreview(controller!));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}
