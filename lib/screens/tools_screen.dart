import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/widgets/tool_card.dart';
import 'package:inkwise_pdf/screens/tools/pdf_compressor_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_editor_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_merge_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_ocr_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_rotate_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_split_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_watermark_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_password_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_grayscale_screen.dart';
import 'package:inkwise_pdf/screens/tools/pdf_images_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      // Core PDF Operations
      {
        "title": "Merge PDFs",
        "icon": Icons.merge_type,
        "color": AppColors.primaryBlue,
        "route": const PDFMergeScreen(),
        "description": "Combine multiple PDF files",
      },
      {
        "title": "Split PDF",
        "icon": Icons.content_cut,
        "color": AppColors.primaryGreen,
        "route": const PDFSplitScreen(),
        "description": "Divide PDF into separate files",
      },
      {
        "title": "Compress PDF",
        "icon": Icons.compress,
        "color": AppColors.primaryOrange,
        "route": const PDFCompressorScreen(),
        "description": "Reduce PDF file size",
      },
      {
        "title": "Rotate Pages",
        "icon": Icons.rotate_90_degrees_ccw,
        "color": AppColors.primaryPurple,
        "route": const PDFRotateScreen(),
        "description": "Rotate page orientation",
      },
      
      // Text & OCR Tools
      {
        "title": "OCR Tool",
        "icon": Icons.text_snippet,
        "color": AppColors.primaryPurple,
        "route": const PDFOCRScreen(),
        "description": "Extract text from scanned documents",
      },
      {
        "title": "PDF Editor",
        "icon": Icons.edit,
        "color": AppColors.primaryBlue,
        "route": const PDFEditorScreen(),
        "description": "Edit PDF content and layout",
      },
      
      // Conversion Tools
      {
        "title": "PDF to Images",
        "icon": Icons.image,
        "color": AppColors.primaryGreen,
        "route": const PDFImagesScreen(),
        "description": "Convert PDF pages to images",
      },
      {
        "title": "Grayscale PDF",
        "icon": Icons.filter_alt,
        "color": AppColors.primaryOrange,
        "route": const PDFGrayscaleScreen(),
        "description": "Convert to black and white",
      },
      
      // Security Tools
      {
        "title": "Add Password",
        "icon": Icons.lock,
        "color": AppColors.primaryRed,
        "route": const PDFPasswordScreen(),
        "description": "Protect PDF with password",
      },
      {
        "title": "Add Watermark",
        "icon": Icons.water_drop,
        "color": AppColors.primaryBlue,
        "route": const PDFWatermarkScreen(),
        "description": "Add text or image watermarks",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Tools"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildToolsGrid(context, tools),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.1),
            AppColors.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.build,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PDF Tools",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Professional PDF editing tools for all your needs",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context, List<Map<String, dynamic>> tools) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ToolCard(
          title: tool["title"] as String,
          icon: tool["icon"] as IconData,
          color: tool["color"] as Color,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => tool["route"] as Widget),
          ),
        );
      },
    );
  }
}