import 'package:digitaleye/src/features/camera/camera_mode_widget.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';
import 'package:digitaleye/src/features/ui/image_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class ModeControlsWidget extends ConsumerStatefulWidget {
  final double columnPadding;
  ModeControlsWidget({required this.columnPadding});

  @override
  _ModeControlsWidgetState createState() => _ModeControlsWidgetState();
}

class _ModeControlsWidgetState extends ConsumerState<ModeControlsWidget> {
  late IconData pauseOrPlay;
  @override
  void initState() {
    super.initState();
    pauseOrPlay = HugeIcons.strokeRoundedPause;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleCameraFeed(WidgetRef ref) {
    final ImageMode imageMode = ref.read(imageStreamerModeProvider);
    if (imageMode == ImageMode.freezed || imageMode == ImageMode.selection) {
      _startCameraFeed(ref);
    } else {
      _pauseCameraFeed(ref);
    }
  }

  void _pauseCameraFeed(WidgetRef ref) {
    ref.read(movablePositionStateProvider.notifier).setUnlocked();
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.freezed;
  }

  void _startCameraFeed(WidgetRef ref) {
    ref.read(movablePositionStateProvider.notifier).resetPosition();
    ref.read(movablePositionStateProvider.notifier).setLocked();
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.camera;
  }

  void _startImageSelect(WidgetRef ref) {
    ref.read(movablePositionStateProvider.notifier).setUnlocked();
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.camera;
    ref.read(imageStreamerModeProvider.notifier).state = ImageMode.selection;
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(imageStreamerModeProvider);
    if (viewMode == ImageMode.camera) {
      pauseOrPlay = HugeIcons.strokeRoundedPause;
    } else {
      pauseOrPlay = HugeIcons.strokeRoundedPlay;
    }
    return Column(
      children: [
        BaseButtonWidget(
          onTap: () {
            _toggleCameraFeed(ref);
          },
          icon: pauseOrPlay,
        ),
        SizedBox(height: widget.columnPadding),
        BaseButtonWidget(
          onTap: () {
            _startImageSelect(ref);
          },
          icon: HugeIcons.strokeRoundedImageUpload,
        ),
      ],
    );
  }
}
