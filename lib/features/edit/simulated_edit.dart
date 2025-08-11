import 'package:flutter/material.dart';
import 'overlay_text_widget.dart';
import '../../widgets/custom_app_bar.dart';

class SimulatedEditScreen extends StatefulWidget {
  final String filePath;

  const SimulatedEditScreen({super.key, required this.filePath});

  @override
  State<SimulatedEditScreen> createState() => _SimulatedEditScreenState();
}

class _SimulatedEditScreenState extends State<SimulatedEditScreen> {
  final List<OverlayTextWidget> overlays = [];

  void _addOverlay() {
    setState(() {
      overlays.add(OverlayTextWidget(
        key: UniqueKey(),
        onRemove: (overlay) => setState(() => overlays.remove(overlay)),
      ));
    });
  }

  void _simulateEraseArea() {
    setState(() {
      overlays.add(OverlayTextWidget(
        key: UniqueKey(),
        eraseOnly: true,
        onRemove: (overlay) => setState(() => overlays.remove(overlay)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Simulated Edit'),
      body: Stack(
        children: [
          Center(child: Text("PDF Preview Placeholder")), // Actual rendering later
          ...overlays,
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'erase',
            onPressed: _simulateEraseArea,
            child: const Icon(Icons.square),
            tooltip: 'Erase Area',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addText',
            onPressed: _addOverlay,
            child: const Icon(Icons.text_fields),
            tooltip: 'Add Text',
          ),
        ],
      ),
    );
  }
}
