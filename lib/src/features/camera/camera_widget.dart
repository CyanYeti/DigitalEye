import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class CameraImageState extends StateNotifier<Map<String, CameraImage>> {
  CameraImageState() : super({}) {}

  void setCameraImage(CameraImage image) {
    state = {"image": image};
  }
}

final cameraImageProvider = StateNotifierProvider<CameraImageState, Map<String, CameraImage>>((ref) => CameraImageState());

class CameraWidget extends ConsumerStatefulWidget {
  const CameraWidget({super.key});
  //const CameraWidget({Key? key}) : super(key : key);

  @override
  ConsumerState<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends ConsumerState<CameraWidget> {
  // get list of cameras async
  final Future<List<CameraDescription>> _camerasFuture = availableCameras();
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
  }

  void _initializeCameraController() {
    //start pulling camera data on init
    _camerasFuture.then((cameras) {
      controller = CameraController(cameras[0], ResolutionPreset.max);
      controller!.initialize().then((_) async {
        if (!mounted) {
          return;
        }
        setState(() {});
        controller?.startImageStream((image) => setState(() {
          ref.read(cameraImageProvider.notifier).setCameraImage(image);
        }));
      }).catchError((Object e) => print(e));
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // From camera doc to dispose camera on inactive app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
  
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
  
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
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
      body: FutureBuilder(
        future: _camerasFuture,
        builder: (context, snapshot) {
          if (controller != null && snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: scaledCameraWidget(context),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}
