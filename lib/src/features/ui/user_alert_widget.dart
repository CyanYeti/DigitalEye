// Alert queue to display alert to user

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertQueue extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void addAlert(String alert) {
    state = [...state, alert];
  }
}

final userAlertQueueProvider = NotifierProvider<AlertQueue, List<String>>(() {
  return AlertQueue();
});

class UserAlertWidget extends ConsumerStatefulWidget {
  const UserAlertWidget({super.key});

  @override
  _UserAlertWidgetState createState() => _UserAlertWidgetState();
}

class _UserAlertWidgetState extends ConsumerState<UserAlertWidget> {
  bool _ready = true;
  bool _isVisible = false;
  bool _showFade = false;
  String alertText = "";
  Timer? displayTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _collapseAlert() {
    alertText = "";
    _isVisible = false;
    _showFade = false;

    // what 300 for next alert
    displayTimer = Timer(const Duration(milliseconds: 300), () {
      _ready = true;
      displayTimer = null;
      setState(() {});
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // watch a queue state
    final alertQueue = ref.watch(userAlertQueueProvider);
    final Size size = MediaQuery.of(context).size;

    // if queue if >1 Show message for timer
    if (alertQueue.isNotEmpty && _ready) {
      _ready = false;
      _isVisible = true;
      _showFade = true;
      setState(() {});

      alertText = alertQueue.first;
      alertQueue.removeAt(0);

      displayTimer = Timer(const Duration(seconds: 3), () {
        _showFade = false;
        setState(() {});
      });
    }

    // dequeue and set invisible
    return Visibility(
      visible: _isVisible,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: size.width,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: AnimatedOpacity(
              opacity: _showFade ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              onEnd: _collapseAlert,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoredBox(
                  color: Colors.redAccent.shade700,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Error: $alertText",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
