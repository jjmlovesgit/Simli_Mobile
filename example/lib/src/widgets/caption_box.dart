import 'dart:async';

import 'package:example/src/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CaptionBox extends StatelessWidget {
  const CaptionBox({super.key, this.width = 420, required this.controller});
  final double width;
  final CaptionController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.secondary.withOpacity(.2035),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [],
      ),
      child: StreamBuilder<String>(
          stream: controller.stream,
          builder: (context, snapshot) {
            String caption = snapshot.data ?? "";
            return AnimatedSwitcher(
              duration: Durations.medium1,
              child: Text(
                key: ValueKey(caption),
                caption,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }),
    );
  }
}

class CaptionController {
  final StreamController<String> _streamController =
      StreamController.broadcast();
  String? msg;

  Stream<String> get stream => _streamController.stream;

  void add(String captions) {
    _streamController.add(captions);
  }

  void addToPipeLine(String msg) {
    this.msg = msg;
  }

  void clearPipeline() {
    if (msg != null) {
      _streamController.add(msg!);
    }
  }
}
