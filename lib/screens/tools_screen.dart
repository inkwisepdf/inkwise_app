import 'package:flutter/material.dart';
import '../../widgets/tool_card.dart';
import 'tools/pdf_compressor_screen.dart';
import 'tools/pdf_editor_screen.dart';
import 'tools/pdf_merge_screen.dart';
import 'tools/pdf_ocr_screen.dart';
import 'tools/pdf_rotate_screen.dart';
// Add more imports as needed...

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {
        "title": "Compress PDF",
        "icon": Icons.compress,
        "route": const PDFCompressorScreen(),
      },
      {
        "title": "Simulated PDF Edit",
        "icon": Icons.edit,
        "route": const PDFEditorScreen(),
      },
      {
        "title": "Merge PDFs",
        "icon": Icons.merge_type,
        "route": const PDFMergeScreen(),
      },
      {
        "title": "OCR Tool",
        "icon": Icons.text_snippet,
        "route": const PDFOCRScreen(),
      },
      {
        "title": "Rotate Pages",
        "icon": Icons.rotate_90_degrees_ccw,
        "route": const PDFRotateScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Utility Tools")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final tool = tools[index];
          return ToolCard(
            title: tool["title"] as String,
            icon: tool["icon"] as IconData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => tool["route"] as Widget),
            ),
          );
        },
      ),
    );
  }
}
