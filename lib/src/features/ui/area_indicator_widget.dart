import 'package:digitaleye/src/color_palette.dart';
import 'package:flutter/material.dart';

enum IndicatorShape { crosshair, rectangle, circle, multipoint }

class AreaIndicatorWidget extends StatelessWidget {
  final IndicatorShape mode;
  final Size size;
  final List<Offset>? points;
  final int crosshairGap = 3;
  // Default just a cross hair with a given size
  AreaIndicatorWidget.crosshair({
    this.mode = IndicatorShape.crosshair,
    required this.size,
    this.points = null,
  });
  AreaIndicatorWidget.rect({
    this.mode = IndicatorShape.rectangle,
    required this.size,
    this.points = null,
  });
  AreaIndicatorWidget.circle({
    this.mode = IndicatorShape.circle,
    required this.size,
    this.points = null,
  });
  AreaIndicatorWidget.multipoint({
    this.mode = IndicatorShape.multipoint,
    required this.size,
    required this.points,
  });

  final Paint linePainter =
      Paint()
        ..color = Colors.grey
        ..blendMode = BlendMode.difference
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 3;

  Widget _drawRect(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: CustomPaint(painter: RectanglePainter(brush: linePainter)),
      ),
    );
  }

  Widget _drawCrosshair(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: CustomPaint(
          painter: CrosshairPainter(brush: linePainter, gap: crosshairGap),
        ),
      ),
    );
  }

  Widget _drawCircle(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: CustomPaint(painter: CirclePainter(brush: linePainter)),
      ),
    );
  }

  // Draws points represented as x,y points in a closed path. Origin is centered
  Widget _drawMultipoint(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Center(
          child: CustomPaint(
            painter: MultiPointPainter(brush: linePainter, points: points!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case IndicatorShape.crosshair:
        return _drawCrosshair(context);
      case IndicatorShape.rectangle:
        return _drawRect(context);
      case IndicatorShape.circle:
        return _drawCircle(context);
      case IndicatorShape.multipoint:
        return _drawMultipoint(context);
    }
  }
}

class CrosshairPainter extends CustomPainter {
  final Paint brush;
  final int gap;

  CrosshairPainter({required this.brush, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    double midX = size.width / 2;
    double midY = size.height / 2;
    // Vertical lines
    // top
    canvas.drawLine(Offset(midX, 0), Offset(midX, midY - gap), brush);
    // bottom
    canvas.drawLine(Offset(midX, size.height), Offset(midX, midY + gap), brush);

    // Horizontal
    // left
    canvas.drawLine(Offset(0, midY), Offset(midX - gap, midY), brush);
    // right
    canvas.drawLine(Offset(size.width, midY), Offset(midX + gap, midY), brush);
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) => false;
}

class RectanglePainter extends CustomPainter {
  final Paint brush;

  RectanglePainter({required this.brush});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, brush);
  }

  @override
  bool shouldRepaint(RectanglePainter oldDelegate) => false;
}

class CirclePainter extends CustomPainter {
  final Paint brush;

  CirclePainter({required this.brush});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      brush,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => false;
}

class MultiPointPainter extends CustomPainter {
  final Paint brush;
  final List<Offset> points;

  MultiPointPainter({required this.brush, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, brush);
  }

  @override
  bool shouldRepaint(MultiPointPainter oldDelegate) => false;
}
