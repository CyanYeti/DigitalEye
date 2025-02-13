import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import './saturation_widget.dart';
import '../shader_ui.dart';

class PosterizeWidget extends ConsumerWidget {
    const PosterizeWidget({super.key});
    
    final SaturationWidget saturationWidget = const SaturationWidget();

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final shaderSettings = ref.watch(shaderProvider);
        double _posterizeSteps = 4; //must be double for sampler but must be whole number for shader
        bool useShader = true;

        return Builder(
            builder: (context) {
                if (shaderSettings['posterize/toRender'] ?? false) {
                    return ShaderBuilder(
                        assetKey: 'shaders/posterize.frag',
                        (BuildContext context, FragmentShader shader, _) => AnimatedSampler(
                            (ui.Image image, Size size, Canvas canvas) {
                                shader
                                    ..setFloat(0, size.width)
                                    ..setFloat(1, size.height)
                                    ..setFloat(2, shaderSettings['posterize/steps'] ?? 1)
                                    ..setImageSampler(0, image);
                                canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
                            },
                            child: saturationWidget,
                        ),
                    );
                } else {
                    return saturationWidget;
                }
            }
        );
    }
}

//class PosterizeWidget extends StatefulWidget {
//    const PosterizeWidget({super.key});
//
//    @override
//    _PosterizeWidgetState createState() => _PosterizeWidgetState();
//}
//
//class _PosterizeWidgetState extends State<PosterizeWidget> {
//    // Steps cannot be 0 as that causes divide by 0 errors
//    double _posterizeSteps = 4; //must be double for sampler but must be whole number for shader
//    bool useShader = true;
//    final CameraWidget cameraWidget = CameraWidget(key: UniqueKey());
//
//    @override
//    void initState() {
//        super.initState();
//    }
//
//    @override
//    void dispose() {
//        super.dispose();
//    }
//
//    @override
//    Widget build(BuildContext context){
//        return Scaffold(
//            appBar: AppBar(actions: [
//              Slider(
//                value: _posterizeSteps,
//                max: 11.0,
//                min: 1.0,
//                divisions: 10,
//                label: _posterizeSteps.toString(),
//                onChanged: (double value) {
//                  setState(() {_posterizeSteps = value;});
//                },
//              ),
//              ElevatedButton(
//                onPressed: () {
//                    setState(() {useShader = !useShader;});
//                },
//                child: Text('POST'),
//              ),
//            ]),
//            body: Builder(
//                builder: (context) {
//                    if (useShader) {
//                        return ShaderBuilder(
//                            assetKey: 'shaders/posterize.frag',
//                            (BuildContext context, FragmentShader shader, _) => AnimatedSampler(
//                                (ui.Image image, Size size, Canvas canvas) {
//                                    shader
//                                        ..setFloat(0, size.width)
//                                        ..setFloat(1, size.height)
//                                        ..setFloat(2, _posterizeSteps)
//                                        ..setImageSampler(0, image);
//                                    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
//                                },
//                                child: cameraWidget,
//                                //child: Center(
//                                //    child: CameraWidget(),
//                                //),
//                            ),
//                        );
//                    } else {
//                        return cameraWidget;
//                    }
//                }
//            )
//        );
//    }
//} 
