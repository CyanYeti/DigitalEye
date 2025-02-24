import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageViewerWidget extends ConsumerStatefulWidget {
  final ui.Image image;
  const ImageViewerWidget({super.key, required this.image});

  @override
  _ImageViewerWidgetState createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends ConsumerState<ImageViewerWidget> {
  Offset position = Offset.zero;
  double zoom = 1.0;
  double previousZoom = 1.0;
  late ui.Image image;

  @override
  void initState() {
    super.initState();
    image = widget.image;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    // if one finder pan
    if (details.pointerCount == 2) {
      previousZoom = zoom;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      Offset delta = details.focalPointDelta;
      position = Offset(position.dx + delta.dx, position.dy + delta.dy);
    } else if (details.pointerCount == 2) {
      zoom = previousZoom * details.scale;
      zoom = zoom.clamp(.5, 10);
    }
  }

  void _handleDoubleTap() {
    _resetTransform();
  }

  void _resetTransform() {
    zoom = 1.0;
    position = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    // Gesture detect drags
    // move image around
    // zoom in and out
    // have empty space be filled with default texture
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: TapRegion(
              onTapOutside: (details) => _resetTransform(),
              child: GestureDetector(
                onDoubleTap: () => _handleDoubleTap(),
                onScaleStart: (details) => _handleScaleStart(details),
                onScaleUpdate: (details) => _handleScaleUpdate(details),
                child: SizedBox.expand(
                  child: Transform.translate(
                    offset: position,
                    child: Transform.scale(
                      scale: zoom,
                      child: RawImage(image: image),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
