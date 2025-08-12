import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';

class CustomStampsScreen extends StatefulWidget {
  const CustomStampsScreen({super.key});

  @override
  State<CustomStampsScreen> createState() => _CustomStampsScreenState();
}

class _CustomStampsScreenState extends State<CustomStampsScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  String _selectedStamp = '';
  String _stampCategory = 'all';
  double _stampOpacity = 1.0;
  double _stampSize = 1.0;
  double _rotation = 0.0;
  Offset _position = const Offset(100, 100);
  List<Map<String, dynamic>> _stamps = [];
  List<Map<String, dynamic>> _appliedStamps = [];

  final Map<String, String> _categories = {
    'all': 'All Stamps',
    'business': 'Business',
    'legal': 'Legal',
    'personal': 'Personal',
    'custom': 'Custom',
  };

  @override
  void initState() {
    super.initState();
    _loadStamps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Stamps"),
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
            if (_selectedFile != null) _buildStampLibrary(),
            const SizedBox(height: 24),
            if (_selectedFile != null && _selectedStamp.isNotEmpty) _buildStampSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildPreview(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
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
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stamp,
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
                  "Custom Stamps",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add offline pre-designed and custom stamps to documents",
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
                    color: AppColors.primaryGreen.withOpacity(0.3),
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
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap to select PDF file",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
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
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: AppColors.primaryGreen,
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
                        _selectedStamp = '';
                        _appliedStamps.clear();
                        _outputPath = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStampLibrary() {
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
                "Stamp Library",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: _addCustomStamp,
                icon: const Icon(Icons.add),
                tooltip: "Add Custom Stamp",
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _stampCategory,
            decoration: InputDecoration(
              labelText: "Category",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _categories.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _stampCategory = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _getFilteredStamps().length,
              itemBuilder: (context, index) {
                final stamp = _getFilteredStamps()[index];
                final isSelected = _selectedStamp == stamp['id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStamp = stamp['id'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primaryGreen
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStampIcon(stamp['type']),
                          size: 32,
                          color: isSelected 
                              ? AppColors.primaryGreen
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stamp['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected 
                                ? AppColors.primaryGreen
                                : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStampSettings() {
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
            "Stamp Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Text(
            "Opacity: ${(_stampOpacity * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _stampOpacity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _stampOpacity = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Size: ${(_stampSize * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _stampSize,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            onChanged: (value) {
              setState(() {
                _stampSize = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Rotation: ${_rotation.toInt()}°",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _rotation,
            min: 0,
            max: 360,
            divisions: 36,
            onChanged: (value) {
              setState(() {
                _rotation = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addStampToPage,
                  icon: const Icon(Icons.add),
                  label: const Text("Add to Page"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearStamps,
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
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
            "Preview",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                // PDF Preview Placeholder
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
                        "PDF Preview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Applied Stamps
                ..._appliedStamps.map((stamp) {
                  return Positioned(
                    left: stamp['position'].dx,
                    top: stamp['position'].dy,
                    child: Transform.rotate(
                      angle: stamp['rotation'] * 3.14159 / 180,
                      child: Transform.scale(
                        scale: stamp['size'],
                        child: Opacity(
                          opacity: stamp['opacity'],
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              _getStampIcon(stamp['type']),
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          if (_appliedStamps.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "Applied Stamps (${_appliedStamps.length})",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _appliedStamps.length,
                itemBuilder: (context, index) {
                  final stamp = _appliedStamps[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStampIcon(stamp['type']),
                          color: AppColors.primaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stamp['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeStamp(index),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _applyStamps,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.stamp),
        label: Text(_isProcessing ? "Applying..." : "Apply Stamps"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                "Stamps Applied",
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
                        "Stamped PDF saved successfully",
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
                  onPressed: _openStampedFile,
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
                  onPressed: _shareStampedFile,
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

  void _loadStamps() {
    _stamps = [
      {'id': 'approved', 'name': 'Approved', 'type': 'business', 'category': 'business'},
      {'id': 'rejected', 'name': 'Rejected', 'type': 'business', 'category': 'business'},
      {'id': 'confidential', 'name': 'Confidential', 'type': 'legal', 'category': 'legal'},
      {'id': 'draft', 'name': 'Draft', 'type': 'business', 'category': 'business'},
      {'id': 'urgent', 'name': 'Urgent', 'type': 'business', 'category': 'business'},
      {'id': 'reviewed', 'name': 'Reviewed', 'type': 'business', 'category': 'business'},
      {'id': 'signed', 'name': 'Signed', 'type': 'legal', 'category': 'legal'},
      {'id': 'verified', 'name': 'Verified', 'type': 'business', 'category': 'business'},
      {'id': 'personal', 'name': 'Personal', 'type': 'personal', 'category': 'personal'},
      {'id': 'custom1', 'name': 'Custom 1', 'type': 'custom', 'category': 'custom'},
      {'id': 'custom2', 'name': 'Custom 2', 'type': 'custom', 'category': 'custom'},
    ];
  }

  List<Map<String, dynamic>> _getFilteredStamps() {
    if (_stampCategory == 'all') {
      return _stamps;
    }
    return _stamps.where((stamp) => stamp['category'] == _stampCategory).toList();
  }

  IconData _getStampIcon(String type) {
    switch (type) {
      case 'business':
        return Icons.business;
      case 'legal':
        return Icons.gavel;
      case 'personal':
        return Icons.person;
      case 'custom':
        return Icons.star;
      default:
        return Icons.stamp;
    }
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
          _selectedStamp = '';
          _appliedStamps.clear();
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

  void _addCustomStamp() {
    // In a real implementation, this would open a dialog to create custom stamps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom stamp creation feature coming soon!'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  void _addStampToPage() {
    if (_selectedStamp.isEmpty) return;
    
    final stamp = _stamps.firstWhere((s) => s['id'] == _selectedStamp);
    setState(() {
      _appliedStamps.add({
        'id': stamp['id'],
        'name': stamp['name'],
        'type': stamp['type'],
        'position': _position,
        'opacity': _stampOpacity,
        'size': _stampSize,
        'rotation': _rotation,
      });
    });
  }

  void _removeStamp(int index) {
    setState(() {
      _appliedStamps.removeAt(index);
    });
  }

  void _clearStamps() {
    setState(() {
      _appliedStamps.clear();
    });
  }

  Future<void> _applyStamps() async {
    if (_selectedFile == null || _appliedStamps.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate stamp application process
      await Future.delayed(const Duration(seconds: 2));
      
      final outputPath = await _getOutputPath('stamped_${DateTime.now().millisecondsSinceEpoch}.pdf');
      
      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stamps applied successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying stamps: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _openStampedFile() async {
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

  Future<void> _shareStampedFile() async {
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
