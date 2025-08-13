import 'package:flutter/material.dart';

class OverlayTextWidget extends StatefulWidget {
  final bool eraseOnly;
  final Function(OverlayTextWidget) onRemove;

  const OverlayTextWidget({
    super.key,
    this.eraseOnly = false,
    required this.onRemove,
  });

  @override
  State<OverlayTextWidget> createState() => _OverlayTextWidgetState();
}

class _OverlayTextWidgetState extends State<OverlayTextWidget> {
  Offset position = const Offset(100, 100);
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _overlayBox(),
        childWhenDragging: const SizedBox(),
        onDragEnd: (details) {
          setState(() => position = details.offset);
        },
        child: _overlayBox(),
      ),
    );
  }

  Widget _overlayBox() {
    return GestureDetector(
      onLongPress: () => widget.onRemove(widget),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.eraseOnly
              ? Colors.white
              : Colors.black.withValues(alpha: 0.7),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: widget.eraseOnly
            ? const SizedBox(width: 80, height: 30)
            : SizedBox(
                width: 120,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration:
                      const InputDecoration.collapsed(hintText: 'Enter text'),
                ),
              ),
      ),
    );
  }
}
