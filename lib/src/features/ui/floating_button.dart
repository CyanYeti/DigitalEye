import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// A button widget that opens a simple percent slider 
// and on tap cycle options and icons
class FloatingButton extends StatefulWidget {
    final double sliderWidth;
    final double sliderHeight;
    final double sliderStartPos;
    final ValueChanged<double> onChanged;
    final Color sliderColor;
    final Color sliderBackgroundColor;
    final Function(int)? onTap;
    final Function()? onDrag;
    final List<dynamic> toggleIcons;
    final double? steps;
    final FloatingButtonController? controller;

    FloatingButton({
        this.sliderWidth = 50,
        this.sliderHeight = 300,
        this.sliderStartPos = 1.0,
        this.sliderColor = Colors.orange,
        this.sliderBackgroundColor = Colors.blueGrey,
        this.onTap,
        this.onDrag,
        this.toggleIcons = const <dynamic>[],
        this.controller,
        this.steps,
        required this.onChanged,
    });
    @override
    _FloatingButtonState createState() => _FloatingButtonState();
}

class FloatingButtonController {
    void Function(double percent)? updatePositionByPercent;
    void Function(int option)? updateOption;
}

class _FloatingButtonState extends State<FloatingButton> {
    OverlayEntry? entry;
    GlobalKey baseKey = GlobalKey();

    // Slider 
    double _dragPosition = 0.0;
    double _dragPercentage = 0.0;
    bool _isDragging = false; //Prevent closing if starting button signals closing
    Offset _dragDiff = Offset.zero;
    ChangeNotifier _repaint = ChangeNotifier();

    // Cycle button
    int currentOption = 0;

    @override
    void initState() {
        super.initState();
        _dragPosition = widget.sliderHeight * widget.sliderStartPos;
        _dragPercentage = widget.sliderStartPos;
        widget.controller?.updateOption = _updateOption;
        widget.controller?.updatePositionByPercent = _updatePositionByPercent;
    }

    _handleChanged(double val) {
        assert(widget.onChanged != null);
        widget.onChanged(val);
    }

    void _updateDragPosition(Offset val) {
        _dragDiff = _dragDiff - val;

        double newDragPosition = _dragPosition - _dragDiff.dy;
        if (newDragPosition <= 0.0) {
            newDragPosition = 0.0;
        } else if (newDragPosition >= widget.sliderHeight) {
            newDragPosition = widget.sliderHeight;
        }

        setState(() {
            _dragPosition = newDragPosition;
            _dragPercentage = _dragPosition / widget.sliderHeight;
            _repaint.notifyListeners();
        });

        _dragDiff = val;

        entry?.markNeedsBuild();

    }
    
    void _updatePositionByPercent(double percent) {
        if (percent < 0.0) {
            percent = 0.0;
        } else if (percent > 1.0) {
            percent = 1.0;
        }

        setState(() {
            _dragPosition = widget.sliderHeight * percent;
            _dragPercentage = percent;
            _repaint.notifyListeners();
        });

        entry?.markNeedsBuild();
    }

    void _onDragStart(BuildContext context, DragStartDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);
        _dragDiff = localOffset;
        _updateDragPosition(localOffset);
        widget.onDrag?.call();
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

    double _roundToSteps(double input, double steps, double maxValue) {
        double stepSize = maxValue / (steps - 1);
        double roundedPosition = (input / stepSize).round().toDouble();
        roundedPosition = roundedPosition * stepSize;
        return roundedPosition;
    }

    void showOverlay(BuildContext context) {
        RenderBox box = baseKey.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);

        entry = OverlayEntry(
            builder: (context) {
                return Positioned(
                    top: position.dy - widget.sliderHeight / 2.0,
                    left: position.dx - widget.sliderWidth / 2.0,
                    child: TapRegion(
                        onTapOutside: (details) => _onDragEnd(context),
                        child: Container(
                            height: widget.sliderHeight,
                            width: widget.sliderWidth,

                            //child: Image.asset('assets/Gradient.png', fit: BoxFit.contain),
                            child: GestureDetector(
                                onVerticalDragStart: (details) => _onDragStart(context, details),
                                onVerticalDragEnd: (details) => _onDragEnd(context, details),
                                onVerticalDragUpdate: (details) => _onDragUpdate(context, details),
                                //child: Image.asset('assets/Gradient.png'),
                                child: CustomPaint(
                                    foregroundPainter: SliderBarPainter(
                                        color: widget.sliderColor,
                                        //sliderPosition: _dragPosition,
                                        sliderPosition: (widget.steps != null && widget.steps! > 0.0) ? 
                                            _roundToSteps(_dragPosition, widget.steps!, widget.sliderHeight) : _dragPosition,
                                        dragPercentage: (widget.steps != null && widget.steps! > 0.0) ? 
                                            _roundToSteps(_dragPercentage, widget.steps!, 1.0) : _dragPercentage,
                                        //dragPercentage: _dragPercentage,
                                        width: widget.sliderWidth,
                                        repaint: _repaint,
                                    ),
                                    painter: SliderPainter(
                                        color: widget.sliderBackgroundColor,
                                        maxSize: Size(widget.sliderWidth, widget.sliderHeight),
                                    ),
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

    void _handleOnTap() {
        _updateOption(currentOption + 1);
        
        widget.onTap?.call(currentOption);

        setState(() {});
        
    }
    void _updateOption(option) {
        currentOption = option;
        int totalOptions = widget.toggleIcons.length;
        if (totalOptions == 0 || currentOption > totalOptions) {
            currentOption = 0;
        } else {
            currentOption = currentOption % totalOptions;
        }
        setState(() {});
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
            onTap: () => {_handleOnTap()},
            onLongPress: () => {showOverlay(context)},
            onLongPressCancel: () => {hideOverlay(context)},
            child: widget.toggleIcons.isEmpty ? Icon(Icons.visibility) : widget.toggleIcons[currentOption],
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
