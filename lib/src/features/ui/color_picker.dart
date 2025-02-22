import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import '../camera/image_streamer_widget.dart';

enum ColorPickerMode { simple, area }

class ColorPickerState extends StateNotifier<Map<String, dynamic>> {
    ColorPickerState() : super({}) {
        setDefaultColorPickerSettings();
    }

    void setDefaultColorPickerSettings() {
        state = {
            'pickerMode': ColorPickerMode.simple,
            'previousColor': Colors.grey,
        };
    }

    void updateColorPickerSetting(String key, dynamic value) {
        state = {...state, key: value};
    }
}

final colorPickerProvider = StateNotifierProvider<ColorPickerState, Map<String, dynamic>>((ref) {
    return ColorPickerState();
});



class ColorPicker extends ConsumerWidget {
    const ColorPicker({super.key});

    final double boxHeight = 130;

    Color _findComplementaryColor(Color baseColor) {
        HSVColor baseHSV = HSVColor.fromColor(baseColor);
        Color compColor = HSVColor.fromAHSV(baseHSV.alpha, (baseHSV.hue + 180) % 360, baseHSV.saturation, 1.0).toColor();

        return compColor;
    }

    Color _findBWComplement(Color baseColor) {
        HSVColor baseHSV = HSVColor.fromColor(baseColor);
        if (baseHSV.value <= 0.5) {
            return Colors.white;
        }
        return Colors.black;
    }

    //Future<Color?> _findColorAtPosition(ui.Image image, WidgetRef ref) async {
    //    return compute(_getPixelColor, image, ref);
    //}

    Color? _processImageForColor(Uint8List image, [Offset? target]) {
        img.Image? imageProcessed = img.decodeImage(image);
        if (imageProcessed != null) {
            final pixel = imageProcessed.getPixel((imageProcessed.width / 2).toInt(), (imageProcessed.height / 2).toInt());
            return Color.fromARGB(pixel.a.toInt(), pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        }
        return null;
    }
    Future<Color?> _getPixelColor(ui.Image image, WidgetRef ref, {Offset? target}) async {
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
        
        ref.read(colorPickerProvider.notifier).updateColorPickerSetting("previousColor", foundColor);
        return foundColor;
    }

    String _colorHexCode(Color? color) {
        if (color == null) {
            return "Loading";
        }
        final String hexCode = '#${(color!.r * 255).round().toRadixString(16).padLeft(2, '0')}'
                            '${(color!.g * 255).round().toRadixString(16).padLeft(2, '0')}'
                            '${(color!.b * 255).round().toRadixString(16).padLeft(2, '0')}';


        return hexCode;
        
    }

    Future<String> _getColorName(Color? color) async {
        if (color == null) {
            return "Loading";
        }

        late String foundName = "Loading";

        await _parseColorJson().then((colorSet) {
            foundName =  _findClosestName(color!, colorSet);

        });

        return foundName;
    }

    String _findClosestName(Color color, List<dynamic> colorSet) {
        Map<String, dynamic> closestColorData = colorSet[0];
        double minDistance = 9999999;
        final int r1 = (color.r * 255).round().toInt();
        final int g1 = (color.g * 255).round().toInt();
        final int b1 = (color.b * 255).round().toInt();
        colorSet.forEach((dynamic colorData) {
            
            List<String> colorRGB2String = colorData["rgb"].replaceAll("(", "").replaceAll(")", "").split(" ");
            List<int> colorRGB2 = colorRGB2String.map(int.parse).toList();

            num distance = pow(colorRGB2[0] - r1, 2) + pow(colorRGB2[1] - g1, 2) + pow(colorRGB2[2] - b1, 2);

            if (distance < minDistance) {
                minDistance = distance.toDouble();
                closestColorData = colorData;
            }
        });

        return closestColorData["name"];
    }

    //Future<Map<String, dynamic>> _parseColorJson() async {
    Future<List<dynamic>> _parseColorJson() async {
        final String data = await rootBundle.loadString('assets/colors.json');
        final json = jsonDecode(data) as List<dynamic>;

        return json;
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
                                future: _getPixelColor(image, ref), 
                                builder: (context, snapshot) {
                                    final Color pickedColor = snapshot.data ?? ref.read(colorPickerProvider.notifier).state["previousColor"];
    
                                    return ColoredBox(
                                        color: pickedColor,
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Center(
                                                    child: DefaultTextStyle(
                                                        style: TextStyle(color: Colors.white),
                                                        child: Column(
                                                            children: [
                                                                FutureBuilder(
                                                                    future: _getColorName(pickedColor),
                                                                    builder: (context, colorName) {
                                                                        return Text(
                                                                            colorName.data ?? "Loading...", 
                                                                            style: TextStyle(
                                                                                color: _findComplementaryColor(pickedColor), 
                                                                                fontSize: 15.0
                                                                            ),
                                                                        );
                                                                    },
                                                                ),
                                                                Text(
                                                                    _colorHexCode(pickedColor), 
                                                                    style: TextStyle(
                                                                        color: _findBWComplement(pickedColor), 
                                                                        fontSize: 4.0,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                            ),
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
    //@override
    //Widget build(BuildContext context, WidgetRef ref) {
    //    //final imageStream = ref.watch(cameraImageProvider);
    //    final imageStream = ref.watch(screenImageProvider);
    //    final Size size = MediaQuery.of(context).size;
    //    Color? pickedColor = null;
    //    return SizedBox(
    //        width: size.width,
    //        height: boxHeight,
    //        child: Builder (
    //            builder: (BuildContext context) {
    //                imageStream.when(
    //                    data: (imageBytes) => {pickedColor = _findColorAt(imageBytes)},
    //                    loading: () => {pickedColor = Colors.grey},
    //                    error: (error, stack) => {debugPrint("Stream Error: $error")}
    //                );

    //                return ColoredBox(
    //                    color: (pickedColor != null) ? pickedColor! : Colors.grey,
    //                    child: FittedBox(
    //                        fit: BoxFit.fitHeight,
    //                        child: Padding(
    //                            padding: EdgeInsets.all(5.0),
    //                            child: Center(
    //                                child: DefaultTextStyle(
    //                                    style: TextStyle(color: Colors.white),
    //                                    child: Column(
    //                                        children: [
    //                                            Text("Blue", style: TextStyle(color: _findComplementaryColor(pickedColor!), fontSize: 15.0)),
    //                                            Text(_colorHexCode(pickedColor), style: TextStyle(color: _findBWComplement(pickedColor!), fontSize: 4.0)),
    //                                        ],
    //                                    ),
    //                                ),
    //                            ),
    //                        ),
    //                    ),
    //                );
    //            }
    //        ), 
    //    );
    //}

}
