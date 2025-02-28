import 'package:digitaleye/src/color_palette.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:hugeicons/hugeicons.dart';
import '../camera/image_streamer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

enum ColorPickerMode { simple, area }

class ColorPickerState extends StateNotifier<Map<String, dynamic>> {
  ColorPickerState() : super({}) {
    setDefaultColorPickerSettings();
  }

  void setDefaultColorPickerSettings() {
    _parseColorJson().then((colorSet) {
      state = {...state, 'colorSet': colorSet};
    });
    state = {
      'pickerMode': ColorPickerMode.simple,
      'previousColor': Colors.grey,
      'currentColorData': null,
    };
  }

  ColorPickerMode getColorPickerMode() {
    return state['pickerMode'];
  }

  void updateColorPickerSetting(String key, dynamic value) {
    state = {...state, key: value};
  }

  Future<List<dynamic>> _parseColorJson() async {
    final String data = await rootBundle.loadString('assets/colors.json');
    final json = jsonDecode(data) as List<dynamic>;

    return json;
  }
}

final colorPickerProvider =
    StateNotifierProvider<ColorPickerState, Map<String, dynamic>>((ref) {
      return ColorPickerState();
    });

class MutableColor {
  int r = 0;
  int g = 0;
  int b = 0;
  int a = 0;

  MutableColor() {
    r = 0;
    g = 0;
    b = 0;
    a = 0;
  }

  MutableColor.withValues(int r, int g, int b, int a) {
    r = r;
    g = g;
    b = b;
    a = a;
  }

  Color toColor() {
    return Color.fromARGB(a, r, g, b);
  }
}

class ColorPicker extends ConsumerWidget {
  const ColorPicker({super.key});

  final double boxHeight = 130;
  final double edgePadding = 15;

  // Util functions
  Color _findComplementaryColor(Color baseColor) {
    HSVColor baseHSV = HSVColor.fromColor(baseColor);
    Color compColor =
        HSVColor.fromAHSV(
          baseHSV.alpha,
          (baseHSV.hue + 180) % 360,
          baseHSV.saturation,
          1.0,
        ).toColor();

    return compColor;
  }

  Color _findBWComplement(Color baseColor) {
    HSVColor baseHSV = HSVColor.fromColor(baseColor);
    if (baseHSV.value <= 0.5) {
      return Colors.white;
    }
    return Colors.black;
  }

  Color _findAppropriateTextColor(Color baseColor) {
    HSVColor baseHSV = HSVColor.fromColor(baseColor);
    if (baseHSV.value < 0.5) {
      return ColorPalette.bright1;
    }
    return ColorPalette.dark1;
  }

  String _colorHexCode(Color? color) {
    if (color == null) {
      return "Loading";
    }
    final String hexCode =
        '#${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}'
        '${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}'
        '${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}';

    return hexCode;
  }

  // Gets the pixel info at target. If not target then middle
  Future<Color?> _getPixelColor(
    ui.Image image,
    WidgetRef ref, {
    Offset? target,
  }) async {
    //final codec = await ui.instantiateImageCodec(imageBytes);
    //final frame = await codec.getNextFrame();
    //final image = frame.image;
    final width = image.width;
    final height = image.height;

    target ??= Offset(width / 2, height / 2); // Default: center pixel

    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    int pixelIndex = ((target.dy.toInt() * width) + target.dx.toInt()) * 4;

    int r = byteData.getUint8(pixelIndex);
    int g = byteData.getUint8(pixelIndex + 1);
    int b = byteData.getUint8(pixelIndex + 2);
    int a = byteData.getUint8(pixelIndex + 3);

    image.dispose();

    final foundColor = Color.fromARGB(a, r, g, b);

    ref
        .read(colorPickerProvider.notifier)
        .updateColorPickerSetting("previousColor", foundColor);
    return foundColor;
  }

  // Get the average color over rect
  Future<Color?> _getRectAverageColor(
    ui.Image image,
    WidgetRef ref,
    Offset pt1,
    Offset pt2,
  ) async {
    final width = image.width;
    final height = image.height;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;
    image.dispose();

    MutableColor runningColor = MutableColor();
    int pixelCount = 0;
    for (int x = pt1.dx.toInt(); x < pt2.dx.toInt(); x++) {
      for (int y = pt1.dy.toInt(); y < pt2.dy.toInt(); y++) {
        int pixelIndex = ((y * width) + x) * 4;

        int r = byteData.getUint8(pixelIndex);
        int g = byteData.getUint8(pixelIndex + 1);
        int b = byteData.getUint8(pixelIndex + 2);
        int a = byteData.getUint8(pixelIndex + 3);

        runningColor.r += pow(r, 2).toInt();
        runningColor.g += pow(g, 2).toInt();
        runningColor.b += pow(b, 2).toInt();
        runningColor.a += pow(a, 2).toInt();

        pixelCount++;
      }
    }

    runningColor.r = sqrt(runningColor.r / pixelCount).round().toInt();
    runningColor.g = sqrt(runningColor.g / pixelCount).round().toInt();
    runningColor.b = sqrt(runningColor.b / pixelCount).round().toInt();
    runningColor.a = sqrt(runningColor.a / pixelCount).round().toInt();

    final Color foundColor = runningColor.toColor();

    ref
        .read(colorPickerProvider.notifier)
        .updateColorPickerSetting("previousColor", foundColor);
    return foundColor;
  }

  // Find the closest name in a json set
  Future<String> _getColorName(Color? color, List<dynamic>? colorSet) async {
    if (color == null || colorSet == null) {
      return "Loading";
    }

    late String foundName = "Loading";
    foundName = await _findClosestName(color!, colorSet!);

    //await _parseColorJson().then((colorSet) {

    //});

    return foundName;
  }

  Future<String> _findClosestName(Color color, List<dynamic> colorSet) async {
    return await _findClosestColorData(
      color,
      colorSet,
    ).then((data) => data["name"]);
  }

  Future<Map<String, dynamic>> _findClosestColorData(
    Color color,
    List<dynamic> colorSet,
  ) async {
    Map<String, dynamic> closestColorData = colorSet[0];
    double minDistance = 9999999;
    final int r1 = (color.r * 255).round().toInt();
    final int g1 = (color.g * 255).round().toInt();
    final int b1 = (color.b * 255).round().toInt();
    colorSet.forEach((dynamic colorData) {
      List<String> colorRGB2String = colorData["rgb"]
          .replaceAll("(", "")
          .replaceAll(")", "")
          .split(" ");
      List<int> colorRGB2 = colorRGB2String.map(int.parse).toList();

      num distance =
          pow(colorRGB2[0] - r1, 2) +
          pow(colorRGB2[1] - g1, 2) +
          pow(colorRGB2[2] - b1, 2);

      if (distance < minDistance) {
        minDistance = distance.toDouble();
        closestColorData = colorData;
      }
    });

    return closestColorData;
  }

  Future<Color?> _selectMode(
    ui.Image image,
    WidgetRef ref, [
    Size? size,
  ]) async {
    switch (ref.read(colorPickerProvider)["pickerMode"]) {
      case ColorPickerMode.simple:
        return await _getPixelColor(image, ref);
      case ColorPickerMode.area:
        size ??= Size(200, 200);
        return await _getRectAverageColor(
          image,
          ref,
          Offset(size.width ~/ 2 - 10, size.height ~/ 2 - 10),
          Offset(size.width ~/ 2 + 10, size.height ~/ 2 + 10),
        );
    }
    return null;
  }

  Future<void> _launchWikiURL(String? urlString) async {
    if (urlString == null) {
      return;
    }
    Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _cycleMode(BuildContext context, WidgetRef ref) {
    final ColorPickerMode previous =
        ref.read(colorPickerProvider)["pickerMode"];

    // Set new mode, refresh indicator
    ref
        .read(colorPickerProvider.notifier)
        .updateColorPickerSetting("pickerMode", _nextEnum(previous));
  }

  ColorPickerMode _nextEnum(ColorPickerMode current) {
    final nextIndex = (current.index + 1) % ColorPickerMode.values.length;
    return ColorPickerMode.values[nextIndex];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageStream = ref.watch(screenImageProvider);
    final colorPickerSetting = ref.watch(colorPickerProvider);

    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: boxHeight,
      child: Builder(
        // Builder listens to the image stream
        builder: (BuildContext context) {
          return imageStream.when(
            data: (image) {
              // While processing the stream, async/isolate process image data to get color
              return FutureBuilder<Color?>(
                future: _selectMode(image, ref, size),
                builder: (context, snapshot) {
                  final Color pickedColor =
                      snapshot.data ?? colorPickerSetting["previousColor"];

                  return ColoredBox(
                    color: pickedColor,
                    child: Stack(
                      children: [
                        // Color selector text
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: size.width - (edgePadding * 2) - (50 * 2),
                              height: boxHeight,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        FutureBuilder(
                                          future: _getColorName(
                                            pickedColor,
                                            colorPickerSetting["colorSet"],
                                          ),
                                          builder: (context, colorName) {
                                            return Text(
                                              colorName.data ?? "Loading...",
                                              style: TextStyle(
                                                color:
                                                    _findAppropriateTextColor(
                                                      pickedColor,
                                                    ),
                                                fontSize: 15.0,
                                              ),
                                            );
                                          },
                                        ),
                                        Text(
                                          _colorHexCode(pickedColor),
                                          style: TextStyle(
                                            color: _findAppropriateTextColor(
                                              pickedColor,
                                            ),
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Buttons
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(edgePadding),
                              child: BaseButtonWidget(
                                onTap: () {
                                  _cycleMode(context, ref);
                                },
                                icon: HugeIcons.strokeRoundedBlend,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(edgePadding),
                              child: BaseButtonWidget(
                                onTap: () async {
                                  final data = await _findClosestColorData(
                                    pickedColor,
                                    colorPickerSetting["colorSet"],
                                  );
                                  _launchWikiURL(data["wiki_link"]);
                                },
                                icon: HugeIcons.strokeRoundedWikipedia,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => ColoredBox(color: Colors.grey), // Placeholder
            error: (error, stack) {
              debugPrint("Stream Error: $error");
              return ColoredBox(color: Colors.red);
            },
          );
        },
      ),
    );
  }
}
