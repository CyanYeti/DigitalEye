import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:digitaleye/src/features/ui/image_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/rendering.dart';
import './image_viewer_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../camera/camera_widget.dart';

enum ImageMode { camera, selection, freezed }

final imageStreamerModeProvider = StateProvider<ImageMode>(
  (ref) => ImageMode.camera,
);

final imageModeGlobalKeyProvider = Provider<GlobalKey>((ref) {
  return GlobalKey();
});

//final currentImageProvider = StateProvider<ui.Image?>((ref) => null);

class CameraModeWidget extends ConsumerStatefulWidget {
  const CameraModeWidget({super.key});

  @override
  _CameraModeWidgetState createState() => _CameraModeWidgetState();
}

class _CameraModeWidgetState extends ConsumerState<CameraModeWidget> {
  final ImagePicker _picker = ImagePicker();
  late final GlobalKey globalKey;
  late ImageMode imageMode;
  bool _pickerActive = false;

  @override
  void initState() {
    super.initState();
    globalKey = ref.read(imageModeGlobalKeyProvider);
    _pickerActive = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<ui.Image?> _captureView(WidgetRef ref) async {
    try {
      final globalKey = ref.read(imageModeGlobalKeyProvider);
      final RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      return image;
    } catch (e) {
      debugPrint("Error capturing camera still in CameraModeWidget: $e");
    }
    return null;
  }

  Future<ui.Image?> _selectFile(WidgetRef ref) async {
    if (_pickerActive ||
        ref.read(imageStreamerModeProvider.notifier).state !=
            ImageMode.selection) {
      return null;
    }
    _pickerActive = true;
    ui.Image? image;
    try {
      XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        await ui.instantiateImageCodec(bytes).then((ui.Codec codec) async {
          await codec.getNextFrame().then((info) {
            image = info.image;
          });
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    _pickerActive = false;
    return image;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    imageMode = ref.watch(imageStreamerModeProvider);
    return Builder(
      builder: (context) {
        switch (imageMode) {
          case ImageMode.camera:
            return RepaintBoundary(key: globalKey, child: const CameraWidget());
          case ImageMode.freezed:
            return FutureBuilder(
              future: _captureView(ref),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return CircularProgressIndicator();
                }
                return ImageViewerWidget(image: snapshot.data!);
              },
            );
          case ImageMode.selection:
            return FutureBuilder(
              future: _selectFile(ref),
              builder: (context, snapshot) {
                if (snapshot.data == null ||
                    snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator();
                }
                return ImageViewerWidget(image: snapshot.data!);
              },
            );
          default:
            return CircularProgressIndicator();
        }
      },
    );
  }
}
