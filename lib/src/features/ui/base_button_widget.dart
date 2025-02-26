import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:digitaleye/src/color_palette.dart';

class BaseButtonWidget extends StatefulWidget {
  final IconData icon;
  final Function()? onTap;
  bool mini;
  BaseButtonWidget({
    super.key,
    required this.icon,
    this.onTap,
    this.mini = false,
  });

  @override
  _BaseButtonWidgetState createState() => _BaseButtonWidgetState();
}

class _BaseButtonWidgetState extends State<BaseButtonWidget> {
  late final Size size;
  late final double iconSize;

  @override
  void initState() {
    super.initState();
    if (widget.mini) {
      size = const Size.square(38);
      iconSize = 25;
    } else {
      size = const Size.square(48);
      iconSize = 31;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color iconColor = ColorPalette.bright1;
  Color buttonColorDark = ColorPalette.dark1;
  Color buttonColorLight = ColorPalette.dark2;

  void _handleOnTap() {
    widget.onTap?.call();
  }

  void _handleOnTapDown() {
    iconColor = ColorPalette.bright3;
    buttonColorDark = ColorPalette.dark2;
    buttonColorLight = ColorPalette.dark3;
    setState(() {});
  }

  void _handleOnTapUp() {
    iconColor = ColorPalette.bright1;
    buttonColorDark = ColorPalette.dark1;
    buttonColorLight = ColorPalette.dark2;
    setState(() {});
  }

  void _handleOnTapCancel() {
    _handleOnTapUp();
  }

  @override
  Widget build(BuildContext context) {
    // Creates a button that can take an on press function
    // standard color, on tap animation, optional flag + direction,
    // Takes in icon to use

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTapDown: (details) => _handleOnTapDown(),
                onTapUp: (details) => _handleOnTapUp(),
                onTapCancel: () => _handleOnTapCancel(),
                onTap: _handleOnTap,
                child: CustomPaint(
                  painter: ButtonPainter(
                    darkColor: buttonColorDark,
                    lightColor: buttonColorLight,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: widget.icon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonPainter extends CustomPainter {
  final Color darkColor;
  final Color lightColor;
  ButtonPainter({required this.darkColor, required this.lightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint brush = Paint()..style = PaintingStyle.fill;

    brush.color = darkColor;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 + 2),
      size.width / 2 + 2,
      brush,
    );

    brush.color = lightColor;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      //Offset(size.width / 2, size.height / 2),
      size.width / 2,
      brush,
    );
  }

  @override
  bool shouldRepaint(ButtonPainter oldDelegate) => true;
}
