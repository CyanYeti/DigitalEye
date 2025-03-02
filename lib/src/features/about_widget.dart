import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            "DigitalEye allows you to quickly apply filters to your camera to aid in color and value recongintion for artists and colorblind. Posterize to flatten values and desaturate to see simple value scales, like notan or 3/5/9 value scales.",
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            "Check either single pixel or area colors. Colors are matched to the closest color in the wikiapedia list of colors. Colors are averaged in linear RGB",
          ),
        ),
      ],
      // Color source, color blending,
    );
  }
}
