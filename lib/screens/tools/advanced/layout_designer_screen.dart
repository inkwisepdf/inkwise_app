import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';

class LayoutDesignerScreen extends StatefulWidget {
  const LayoutDesignerScreen({super.key});

  @override
  State<LayoutDesignerScreen> createState() => _LayoutDesignerScreenState();
}

class _LayoutDesignerScreenState extends State<LayoutDesignerScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  String _designMode = 'visual'; // 'visual', 'grid', 'freeform'
  String _pageSize = 'A4';
  double _margin = 20.0;
  bool _showGrid = true;
  bool _snapToGrid = true;
  List<Map<String, dynamic>> _layoutElements = [];
  int _selectedElementIndex = -1;

  final Map<String, String> _modeOptions = {
    'visual': 'Visual Designer',
    'grid': 'Grid Layout',
    'freeform': 'Freeform Layout',
  };

  final Map<String, String> _pageSizeOptions = {
    'A4': 'A4 (210 × 297 mm)',
    'A3': 'A3 (297 × 420 mm)',
    'Letter': 'Letter (8.5 × 11 in)',
    'Legal': 'Legal (8.5 × 14 in)',
    'Custom': 'Custom Size',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Layout Designer"),
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
            _buildFileSelector(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildDesignSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildDesignCanvas(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildToolPanel(),
            const SizedBox(height: 24),
            if (_outputPath != null) _buildResult(),
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
            AppColors.primaryPurple.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.design_services,
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
                  "Layout Designer",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rebuild page layouts by moving text blocks, images, and tables",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select PDF Document",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_selectedFile == null)
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 48,
                      color: AppColors.primaryPurple,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap to select PDF file",
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: AppColors.primaryPurple,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Size: ${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _layoutElements.clear();
                        _outputPath = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: AppColors.primaryPurple,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesignSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Design Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _designMode,
            decoration: InputDecoration(
              labelText: "Design Mode",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _modeOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _designMode = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _pageSize,
            decoration: InputDecoration(
              labelText: "Page Size",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _pageSizeOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _pageSize = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Margin: ${_margin.toInt()}px",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _margin,
            min: 0,
            max: 50,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _margin = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Show Grid"),
            subtitle: const Text("Display design grid"),
            value: _showGrid,
            onChanged: (value) {
              setState(() {
                _showGrid = value;
              });
            },
            activeColor: AppColors.primaryPurple,
          ),
          
          SwitchListTile(
            title: const Text("Snap to Grid"),
            subtitle: const Text("Align elements to grid"),
            value: _snapToGrid,
            onChanged: (value) {
              setState(() {
                _snapToGrid = value;
              });
            },
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildDesignCanvas() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Design Canvas",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: _addTextBlock,
                icon: const Icon(Icons.text_fields),
                tooltip: "Add Text Block",
              ),
              IconButton(
                onPressed: _addImageBlock,
                icon: const Icon(Icons.image),
                tooltip: "Add Image",
              ),
              IconButton(
                onPressed: _addTableBlock,
                icon: const Icon(Icons.table_chart),
                tooltip: "Add Table",
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                // Grid background
                if (_showGrid) _buildGrid(),
                
                // Layout elements
                ..._layoutElements.asMap().entries.map((entry) {
                  final index = entry.key;
                  final element = entry.value;
                  return Positioned(
                    left: element['x'].toDouble(),
                    top: element['y'].toDouble(),
                    child: GestureDetector(
                      onTap: () => _selectElement(index),
                      child: Container(
                        width: element['width'].toDouble(),
                        height: element['height'].toDouble(),
                        decoration: BoxDecoration(
                          color: _selectedElementIndex == index 
                              ? AppColors.primaryPurple.withOpacity(0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: _selectedElementIndex == index 
                                ? AppColors.primaryPurple
                                : Colors.grey.withOpacity(0.5),
                            width: _selectedElementIndex == index ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _buildElementContent(element),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: GridPainter(),
    );
  }

  Widget _buildElementContent(Map<String, dynamic> element) {
    switch (element['type']) {
      case 'text':
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            element['content'] ?? 'Text Block',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      case 'image':
        return Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.image, size: 24),
        );
      case 'table':
        return Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.table_chart, size: 24),
        );
      default:
        return Container();
    }
  }

  Widget _buildToolPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Design Tools",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectedElementIndex >= 0 ? _deleteElement : null,
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectedElementIndex >= 0 ? _duplicateElement : null,
                  icon: const Icon(Icons.copy),
                  label: const Text("Duplicate"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearCanvas,
                  icon: const Icon(Icons.clear_all),
                  label: const Text("Clear All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: BorderSide(color: AppColors.primaryOrange),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _generateLayout,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isProcessing ? "Generating..." : "Generate Layout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Layout Generated",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New layout saved successfully",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "File: ${_outputPath!.split('/').last}",
                        style: TextStyle(
                          color: AppColors.primaryGreen.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openGeneratedFile,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open File"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareGeneratedFile,
                  icon: const Icon(Icons.share),
                  label: const Text("Share"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _layoutElements.clear();
          _outputPath = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _addTextBlock() {
    setState(() {
      _layoutElements.add({
        'type': 'text',
        'content': 'New Text Block',
        'x': 50.0,
        'y': 50.0,
        'width': 200.0,
        'height': 100.0,
      });
    });
  }

  void _addImageBlock() {
    setState(() {
      _layoutElements.add({
        'type': 'image',
        'content': 'Image Placeholder',
        'x': 100.0,
        'y': 100.0,
        'width': 150.0,
        'height': 150.0,
      });
    });
  }

  void _addTableBlock() {
    setState(() {
      _layoutElements.add({
        'type': 'table',
        'content': 'Table Placeholder',
        'x': 150.0,
        'y': 150.0,
        'width': 250.0,
        'height': 120.0,
      });
    });
  }

  void _selectElement(int index) {
    setState(() {
      _selectedElementIndex = index;
    });
  }

  void _deleteElement() {
    if (_selectedElementIndex >= 0) {
      setState(() {
        _layoutElements.removeAt(_selectedElementIndex);
        _selectedElementIndex = -1;
      });
    }
  }

  void _duplicateElement() {
    if (_selectedElementIndex >= 0) {
      setState(() {
        final element = Map<String, dynamic>.from(_layoutElements[_selectedElementIndex]);
        element['x'] = (element['x'] as double) + 20;
        element['y'] = (element['y'] as double) + 20;
        _layoutElements.add(element);
      });
    }
  }

  void _clearCanvas() {
    setState(() {
      _layoutElements.clear();
      _selectedElementIndex = -1;
    });
  }

  Future<void> _generateLayout() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate layout generation process
      await Future.delayed(const Duration(seconds: 3));
      
      final outputPath = await _getOutputPath('layout_${DateTime.now().millisecondsSinceEpoch}.pdf');
      
      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Layout generated successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating layout: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _openGeneratedFile() async {
    if (_outputPath == null) return;
    
    try {
      final file = File(_outputPath!);
      await FileService().openFile(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _shareGeneratedFile() async {
    if (_outputPath == null) return;
    
    try {
      final file = File(_outputPath!);
      await FileService().shareFile(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing file: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<String> _getOutputPath(String filename) async {
    final directory = await FileService().getAppDirectoryPath();
    return '$directory/$filename';
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    const gridSize = 20.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
