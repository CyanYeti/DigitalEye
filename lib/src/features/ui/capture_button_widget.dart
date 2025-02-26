import 'package:flutter/material.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:digitaleye/src/features/camera/screenshot_widget.dart';
import 'dart:typed_data';

import 'package:hugeicons/hugeicons.dart';

class CaptureButtonWidget extends ConsumerWidget {
  void saveImage(Uint8List? imageFile) async {
    if (imageFile == null) {
      return;
    }
    final hasAccess = await Gal.hasAccess(toAlbum: true);

    if (!hasAccess) {
      await Gal.requestAccess(toAlbum: true);
    }

    await Gal.putImageBytes(imageFile);

    Gal.open();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseButtonWidget(
      onTap: () {
        ref
            .read(screenshotControllerProvider)
            .capture()
            .then((Uint8List? image) {
              saveImage(image);
            })
            .catchError((onError) {
              debugPrint(onError);
            });
      },
      icon: HugeIcons.strokeRoundedCameraLens,
    );
  }
}
