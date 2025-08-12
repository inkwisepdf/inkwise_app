import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';

class DualPageViewScreen extends StatefulWidget {
  const DualPageViewScreen({super.key});

  @override
  State<DualPageViewScreen> createState() => _DualPageViewScreenState();
}

class _DualPageViewScreenState extends State<DualPageViewScreen> {
  File? _selectedFile;
  bool _isLoading = false;
  String _viewMode = 'side_by_side'; // 'side_by_side', 'split', 'overlay'
  String _layoutMode = 'horizontal'; // 'horizontal', 'vertical'
  double _splitRatio = 0.5;
  bool _syncScrolling = true;
  bool _showPageNumbers = true;
  bool _showZoomControls = true;
  int _leftPage = 1;
  int _rightPage = 2;
  double _leftZoom = 1.0;
  double _rightZoom = 1.0;

  final Map<String, String> _viewModeOptions = {
    'side_by_side': 'Side by Side',
    'split': 'Split View',
    'overlay': 'Overlay Mode',
  };

  final Map<String, String> _layoutModeOptions = {
    'horizontal': 'Horizontal Layout',
    'vertical': 'Vertical Layout',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dual Page View"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          if (_selectedFile != null) _buildControls(),
          Expanded(
            child: _selectedFile != null ? _buildDualView() : _buildFileSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFilePicker(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.view_column,
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
                  "Dual Page View",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "View two different parts of a PDF side-by-side",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
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
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.3),
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
                    color: AppColors.primaryOrange,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap to select PDF file",
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _viewMode,
                  decoration: InputDecoration(
                    labelText: "View Mode",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _viewModeOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _viewMode = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _layoutMode,
                  decoration: InputDecoration(
                    labelText: "Layout",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _layoutModeOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _layoutMode = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text("Left Page:", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: _leftPage.toString()),
                        onChanged: (value) {
                          setState(() {
                            _leftPage = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    const Text("Right Page:", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: _rightPage.toString()),
                        onChanged: (value) {
                          setState(() {
                            _rightPage = int.tryParse(value) ?? 2;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SwitchListTile(
                title: const Text("Sync Scrolling", style: TextStyle(fontSize: 12)),
                value: _syncScrolling,
                onChanged: (value) {
                  setState(() {
                    _syncScrolling = value;
                  });
                },
                activeColor: AppColors.primaryOrange,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              SwitchListTile(
                title: const Text("Page Numbers", style: TextStyle(fontSize: 12)),
                value: _showPageNumbers,
                onChanged: (value) {
                  setState(() {
                    _showPageNumbers = value;
                  });
                },
                activeColor: AppColors.primaryOrange,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              SwitchListTile(
                title: const Text("Zoom Controls", style: TextStyle(fontSize: 12)),
                value: _showZoomControls,
                onChanged: (value) {
                  setState(() {
                    _showZoomControls = value;
                  });
                },
                activeColor: AppColors.primaryOrange,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDualView() {
    switch (_viewMode) {
      case 'side_by_side':
        return _buildSideBySideView();
      case 'split':
        return _buildSplitView();
      case 'overlay':
        return _buildOverlayView();
      default:
        return _buildSideBySideView();
    }
  }

  Widget _buildSideBySideView() {
    if (_layoutMode == 'horizontal') {
      return Row(
        children: [
          Expanded(
            child: _buildPageView('left', _leftPage, _leftZoom),
          ),
          Container(
            width: 2,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildPageView('right', _rightPage, _rightZoom),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: _buildPageView('left', _leftPage, _leftZoom),
          ),
          Container(
            height: 2,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildPageView('right', _rightPage, _rightZoom),
          ),
        ],
      );
    }
  }

  Widget _buildSplitView() {
    return Stack(
      children: [
        _buildPageView('left', _leftPage, _leftZoom),
        Positioned(
          left: MediaQuery.of(context).size.width * _splitRatio - 1,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: AppColors.primaryOrange,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * _splitRatio,
          top: 0,
          bottom: 0,
          right: 0,
          child: _buildPageView('right', _rightPage, _rightZoom),
        ),
      ],
    );
  }

  Widget _buildOverlayView() {
    return Stack(
      children: [
        _buildPageView('left', _leftPage, _leftZoom),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryOrange, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildPageView('right', _rightPage, _rightZoom),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageView(String side, int pageNumber, double zoom) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Stack(
        children: [
          // PDF Viewer Placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "Page $pageNumber",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "PDF Viewer",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Zoom: ${(zoom * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Page Number
          if (_showPageNumbers)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Page $pageNumber",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          // Zoom Controls
          if (_showZoomControls)
            Positioned(
              bottom: 8,
              right: 8,
              child: Column(
                children: [
                  IconButton(
                    onPressed: () => _adjustZoom(side, 0.1),
                    icon: const Icon(Icons.zoom_in, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange.withOpacity(0.9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    onPressed: () => _adjustZoom(side, -0.1),
                    icon: const Icon(Icons.zoom_out, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange.withOpacity(0.9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _adjustZoom(String side, double delta) {
    setState(() {
      if (side == 'left') {
        _leftZoom = (_leftZoom + delta).clamp(0.5, 3.0);
      } else {
        _rightZoom = (_rightZoom + delta).clamp(0.5, 3.0);
      }
    });
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
          _isLoading = true;
        });

        // Simulate loading
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isLoading = false;
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
}
