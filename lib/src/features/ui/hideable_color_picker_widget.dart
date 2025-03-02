import 'package:digitaleye/src/color_palette.dart';
import 'package:digitaleye/src/features/about_widget.dart';
import 'package:digitaleye/src/features/default_text_wrapper_widget.dart';
import 'package:digitaleye/src/features/ui/base_button_widget.dart';
import 'package:digitaleye/src/features/ui/color_picker.dart';
import 'package:digitaleye/src/features/ui/guide_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HideableColorPickerWidget extends StatefulWidget {
  final double edgePadding;
  HideableColorPickerWidget({super.key, required this.edgePadding});

  @override
  _HideableColorPickerWidgetState createState() =>
      _HideableColorPickerWidgetState();
}

class _HideableColorPickerWidgetState extends State<HideableColorPickerWidget> {
  bool isHidden = false;
  bool showInfo = false;
  bool showGuide = false;
  OverlayEntry? entry;

  void _handleShowTap() {
    isHidden = !isHidden;
    setState(() {});
  }

  void _handletShowGuide() {
    showGuide = !showGuide;
    entry?.markNeedsBuild();
  }

  void _showInfoOverlay() {
    entry = OverlayEntry(
      builder: (context) {
        Color backgroundColor = ColorPalette.dark3;
        Color backgroundColorDark = ColorPalette.dark1;
        return Positioned.fill(
          child: ColoredBox(
            color: Color.from(
              alpha: 0.85,
              red: backgroundColorDark.r,
              green: backgroundColorDark.g,
              blue: backgroundColorDark.b,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.edgePadding * 2,
                    ),
                    child: ColoredBox(
                      color: Color.from(
                        alpha: 1,
                        red: backgroundColor.r,
                        green: backgroundColor.g,
                        blue: backgroundColor.b,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(widget.edgePadding),
                        child: DefaultTextWrapperWidget(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(
                                        widget.edgePadding,
                                      ),
                                      child: BaseButtonWidget(
                                        onTap: _handletShowGuide,
                                        icon: HugeIcons.strokeRoundedHelpCircle,
                                        mini: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        widget.edgePadding,
                                      ),
                                      child: BaseButtonWidget(
                                        icon: HugeIcons.strokeRoundedSettings01,
                                        onTap: _hideInfoOverlay,
                                        mini: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        widget.edgePadding,
                                      ),
                                      child: BaseButtonWidget(
                                        icon: HugeIcons.strokeRoundedCancel01,
                                        onTap: _hideInfoOverlay,
                                        mini: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Builder(
                                  builder: (BuildContext context) {
                                    if (showGuide) {
                                      return GuideWidget();
                                    } else {
                                      return AboutWidget();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void _hideInfoOverlay() {
    showGuide = false;
    showInfo = false;
    entry?.remove();
    entry?.dispose();
    entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (BuildContext context) {
            return Visibility(
              visible: !isHidden,
              maintainState: true,
              child: const ColorPicker(),
            );
          },
        ),
        //Positioned(top: 0, right: 0, left: 0, child: const ColorPicker()),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.all(widget.edgePadding),
              child: BaseButtonWidget(
                icon: HugeIcons.strokeRoundedInformationCircle,
                onTap: _showInfoOverlay,
                mini: true,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(widget.edgePadding),
              child: BaseButtonWidget(
                icon: HugeIcons.strokeRoundedView,
                onTap: _handleShowTap,
                mini: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
