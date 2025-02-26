import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovablePositionState extends StateNotifier<Map<String, dynamic>> {
  MovablePositionState() : super({}) {
    _initDefault();
  }

  void _initDefault() {
    state = {
      'position': Offset.zero,
      'zoom': 1.0,
      'isLocked': state['isLocked'],
    };
  }

  void setLocked() {
    state = {...state, 'isLocked': true};
  }

  void resetPosition() {
    _initDefault();
  }

  void setUnlocked() {
    state = {...state, 'isLocked': false};
  }

  bool _isLocked() {
    return state["isLocked"];
  }

  void _updateSetting(String key, dynamic value) {
    state = {...state, key: value};
  }
}

final movablePositionStateProvider =
    StateNotifierProvider<MovablePositionState, Map<String, dynamic>>((ref) {
      return MovablePositionState();
    });

class MovableViewerWidget extends ConsumerStatefulWidget {
  final Widget child;
  const MovableViewerWidget({super.key, required this.child});

  @override
  _MovableViewerWidgetState createState() => _MovableViewerWidgetState();
}

class _MovableViewerWidgetState extends ConsumerState<MovableViewerWidget> {
  double previousZoom = 1.0;
  late final Widget child;

  @override
  void initState() {
    super.initState();
    child = widget.child;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (ref.read(movablePositionStateProvider.notifier)._isLocked()) {
      return;
    }

    // if one finder pan
    if (details.pointerCount == 2) {
      previousZoom = ref.read(movablePositionStateProvider)['zoom'];
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (ref.read(movablePositionStateProvider.notifier)._isLocked()) {
      return;
    }
    Offset position = ref.read(movablePositionStateProvider)["position"];
    double zoom = ref.read(movablePositionStateProvider)["zoom"];

    if (details.pointerCount == 1) {
      Offset delta = details.focalPointDelta;
      position = Offset(position.dx + delta.dx, position.dy + delta.dy);
      ref
          .read(movablePositionStateProvider.notifier)
          ._updateSetting('position', position);
    } else if (details.pointerCount == 2) {
      zoom = previousZoom * details.scale;
      zoom = zoom.clamp(.5, 10);
      ref
          .read(movablePositionStateProvider.notifier)
          ._updateSetting('zoom', zoom);
    }
    setState(() {});
  }

  void _handleDoubleTap() {
    ref.read(movablePositionStateProvider.notifier).resetPosition();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Offset position = ref.watch(movablePositionStateProvider)['position'];
    double zoom = ref.watch(movablePositionStateProvider)['zoom'];
    // Gesture detect drags
    // move image around
    // zoom in and out
    // have empty space be filled with default texture
    return Stack(
      children: [
        Positioned(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox.expand(
              child: GestureDetector(
                onDoubleTap: () => _handleDoubleTap(),
                child: ColoredBox(color: Colors.grey),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onDoubleTap: () => _handleDoubleTap(),
              onScaleStart: (details) => _handleScaleStart(details),
              onScaleUpdate: (details) => _handleScaleUpdate(details),
              child: SizedBox.expand(
                child: Transform.translate(
                  offset: position,
                  child: Transform.scale(
                    scale: zoom,
                    //child: RawImage(image: image),
                    child: child,
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
