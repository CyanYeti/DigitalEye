import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// A button widget that opens a simple percent slider 
// and on tap cycle options and icons
class FloatingButton extends StatefulWidget {
    final double sliderWidth;
    final double sliderHeight;
    final ValueChanged<double> onChanged;
    VoidCallback? onTap;
    int? toggleCount;
    List<dynamic>? toggleIcons;

    FloatingButton({
        this.sliderWidth = 100,
        this.sliderHeight = 300,
        required this.onChanged,
    });
    @override
    _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
    OverlayEntry? entry;
    GlobalKey baseKey = GlobalKey();

    // Slider 
    double _dragPosition = 0.0;
    double _dragPercentage = 0.0;
    bool _isDragging = false; //Prevent closing if starting button signals closing
    ChangeNotifier _repaint = ChangeNotifier();

    _handleChanged(double val) {
        assert(widget.onChanged != null);
        widget.onChanged(val);
    }

    void _updateDragPosition(Offset val) {
        double newDragPosition = 0.0;
        if (val.dy <= 0.0) {
            newDragPosition = 0.0;
        } else if (val.dy >= widget.sliderHeight) {
            newDragPosition = widget.sliderHeight;
        } else {
            newDragPosition = val.dy;
        }

        setState(() {
            _dragPosition = newDragPosition;
            _dragPercentage = _dragPosition / widget.sliderHeight;
            _repaint.notifyListeners();
        });

        entry?.markNeedsBuild();

    }

    void _onDragStart(BuildContext context, DragStartDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);
        _updateDragPosition(localOffset);
        _isDragging = true;
    }

    void _onDragUpdate(BuildContext context, DragUpdateDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);
        _updateDragPosition(localOffset);
        _handleChanged(_dragPercentage);
    }

    void _onDragEnd(BuildContext context, [DragEndDetails? details]) {
        _isDragging = false;
        hideOverlay(context);
    }

    void showOverlay(BuildContext context) {
        RenderBox box = baseKey.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);

        entry = OverlayEntry(
            builder: (context) {
                return Positioned(
                    top: position.dy - widget.sliderHeight / 2.0,
                    left: position.dx - widget.sliderWidth / 2.0,
                    child: Container(
                        height: widget.sliderHeight,
                        width: widget.sliderWidth,

                        //child: Image.asset('assets/Gradient.png', fit: BoxFit.contain),
                        child: GestureDetector(
                            onDoubleTap: () => _onDragEnd(context),
                            onVerticalDragStart: (details) => _onDragStart(context, details),
                            onVerticalDragEnd: (details) => _onDragEnd(context, details),
                            onVerticalDragUpdate: (details) => _onDragUpdate(context, details),
                            //child: Image.asset('assets/Gradient.png'),
                            child: CustomPaint(
                                foregroundPainter: SliderBarPainter(
                                    color: Colors.red,
                                    sliderPosition: _dragPosition,
                                    dragPercentage: _dragPercentage,
                                    width: widget.sliderWidth,
                                    repaint: _repaint,
                                ),
                                painter: SliderPainter(
                                    color: Colors.grey,
                                    maxSize: Size(widget.sliderWidth, widget.sliderHeight),
                                ),
                            ),
                        ),
                    ),
                );
            },
        );
        final overlay = Overlay.of(context)!;
        overlay.insert(entry!);
    }

    void hideOverlay(BuildContext context) {
        if (_isDragging) {
            return;
        }
        entry?.remove();
        entry = null;
    }

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            key: baseKey,
            //onTapDown: (details) => {showOverlay(context)},
            //onTapUp: (details) => {hideOverlay(context)},
            //onTapCancel: () => {hideOverlay(context)},
            onLongPress: () => {showOverlay(context)},
            onLongPressCancel: () => {hideOverlay(context)},
            child: Icon(Icons.visibility),
        );
    }
}

class SliderBarPainter extends CustomPainter {
    final double sliderPosition;
    final double dragPercentage;
    final double width;

    final Color color;

    final Paint linePainter;

    double _previousSliderPosition = 0.0;

    SliderBarPainter({
        required this.sliderPosition,
        required this.dragPercentage,
        required this.color,
        required this.width,
        super.repaint,
    }) : linePainter = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

    @override
    void paint(Canvas canvas, Size size) {
        _paintLine(canvas, size);
    }

    _paintLine(Canvas canvas, Size size) {
        canvas.drawLine(Offset(0, sliderPosition), Offset(width, sliderPosition), linePainter);
    }

    @override
    bool shouldRepaint(SliderBarPainter oldDelegate) {
        double diff = _previousSliderPosition - oldDelegate.sliderPosition;
        if (diff.abs() > 20) {
            _previousSliderPosition = sliderPosition;
        } else {
            _previousSliderPosition = oldDelegate.sliderPosition;
        }
        return true;
    }
}

class SliderPainter extends CustomPainter {
    final Size maxSize;
    final Color color;

    final Paint fillPainter;

    SliderPainter({
        required this.color,
        required this.maxSize,
        super.repaint,
    }) : fillPainter = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

    @override
    void paint(Canvas canvas, Size size) {
        _paintLine(canvas, size);
    }

    _paintLine(Canvas canvas, Size size) {
        canvas.drawRect(Rect.fromPoints(Offset(0,0), Offset(maxSize.width, maxSize.height)), fillPainter);
    }

    @override
    bool shouldRepaint(SliderPainter oldDelegate) {
        return true;
    }
}
