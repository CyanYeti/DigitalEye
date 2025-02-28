import 'package:digitaleye/src/features/ui/icon_text_pair_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class GuideWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color picker guide
        SizedBox(height: 10),
        Text("Color Picker:", style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedView,
          label: ": Collapse/Show color picker",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedWikipedia,
          label: ": Open wiki of current highlighted color",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedBlend,
          label: ": Change color selector shape",
        ),

        // Filter
        SizedBox(height: 10),
        Text("Filter Options:", style: TextStyle(fontSize: 20)),
        Text("Press to cycle presets"),
        Text("Long press for slider"),
        SizedBox(height: 10),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedView,
          label: ": Contrast",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedWikipedia,
          label: ": Saturation",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedBlend,
          label: ": Brightness",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedBlend,
          label: ": Posterize",
        ),
        IconTextPairWidget(icon: HugeIcons.strokeRoundedBlend, label: ": Blur"),

        // Color picker guide
        SizedBox(height: 10),
        Text("Image Selection:", style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedPause,
          label: ": Pause/Play camera feed",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedImageUpload,
          label: ": Select image from gallery",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedCameraLens,
          label: ": Capture current image with filters",
        ),
        IconTextPairWidget(
          icon: HugeIcons.strokeRoundedReload,
          label: ": Reset filters and image position",
        ),
      ],
    );
  }
}
