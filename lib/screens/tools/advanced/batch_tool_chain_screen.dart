import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';


class BatchToolChainScreen extends StatefulWidget {
  const BatchToolChainScreen({super.key});

  @override
  State<BatchToolChainScreen> createState() => _BatchToolChainScreenState();
}

class _BatchToolChainScreenState extends State<BatchToolChainScreen> {
  final List<File> _selectedFiles = [];
  bool _isProcessing = false;
  List<Map<String, dynamic>> _availableTools = [];
  final List<Map<String, dynamic>> _selectedTools = [];
  String _processingMode = 'sequential'; // 'sequential', 'parallel'
  bool _stopOnError = true;
  bool _showProgress = true;
  final List<Map<String, dynamic>> _processingResults = [];

  final Map<String, String> _modeOptions = {
    'sequential': 'Sequential Processing',
    'parallel': 'Parallel Processing',
  };

  @override
  void initState() {
    super.initState();
    _loadAvailableTools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Tool Chain"),
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
            if (_selectedFiles.isNotEmpty) _buildToolSelection(),
            const SizedBox(height: 24),
            if (_selectedTools.isNotEmpty) _buildProcessingSettings(),
            const SizedBox(height: 24),
            if (_selectedFiles.isNotEmpty && _selectedTools.isNotEmpty) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_processingResults.isNotEmpty) _buildProcessingResults(),
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
            AppColors.primaryRed.withValues(alpha: 0.1),
            AppColors.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
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
                  "Batch Tool Chain",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Apply multiple tools (compress → watermark → password lock) in one step",
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Select PDF Files",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                "${_selectedFiles.length} files",
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_selectedFiles.isEmpty)
            GestureDetector(
              onTap: _pickFiles,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.3),
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
                      color: AppColors.primaryRed,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap to select PDF files",
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: AppColors.primaryRed,
                        ),
                        title: Text(
                          file.path.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "Size: ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () => _removeFile(index),
                          icon: const Icon(Icons.remove_circle, color: AppColors.primaryRed),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.add),
                        label: const Text("Add More Files"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryRed,
                          side: BorderSide(color: AppColors.primaryRed),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearFiles,
                        icon: const Icon(Icons.clear_all),
                        label: const Text("Clear All"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildToolSelection() {
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
                "Select Tools",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                "${_selectedTools.length} tools",
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableTools.length,
            itemBuilder: (context, index) {
              final tool = _availableTools[index];
              final isSelected = _selectedTools.any((t) => t['id'] == tool['id']);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryRed.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tool['icon'],
                      color: isSelected ? AppColors.primaryRed : Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tool['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                                      subtitle: Text(
                      tool['description'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Selected",
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          if (value == true) {
                            setState(() {
                              _selectedTools.add(tool);
                            });
                          } else {
                            setState(() {
                              _selectedTools.removeWhere((t) => t['id'] == tool['id']);
                            });
                          }
                        },
                        activeColor: AppColors.primaryRed,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          if (_selectedTools.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryRed.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Processing Order:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._selectedTools.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final tool = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(tool['icon'], size: 16, color: AppColors.primaryRed),
                          const SizedBox(width: 8),
                          Text(
                            tool['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessingSettings() {
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
            "Processing Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _processingMode,
            decoration: InputDecoration(
              labelText: "Processing Mode",
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
                _processingMode = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Stop on Error"),
            subtitle: const Text("Stop processing if any tool fails"),
            value: _stopOnError,
            onChanged: (value) {
              setState(() {
                _stopOnError = value;
              });
            },
            activeColor: AppColors.primaryRed,
          ),
          
          SwitchListTile(
            title: const Text("Show Progress"),
            subtitle: const Text("Display detailed processing progress"),
            value: _showProgress,
            onChanged: (value) {
              setState(() {
                _showProgress = value;
              });
            },
            activeColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _startBatchProcessing,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.play_arrow),
        label: Text(_isProcessing ? "Processing..." : "Start Batch Processing"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingResults() {
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
                "Processing Results",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _processingResults.length,
            itemBuilder: (context, index) {
              final result = _processingResults[index];
              final isSuccess = result['status'] == 'success';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSuccess 
                          ? AppColors.primaryGreen.withValues(alpha: 0.1)
                          : AppColors.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? AppColors.primaryGreen : AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    result['fileName'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: ${result['status']}",
                        style: TextStyle(
                          color: isSuccess ? AppColors.primaryGreen : AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (result['message'] != null)
                        Text(
                          result['message'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    result['duration'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openResultsFolder,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Open Folder"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResults,
                  icon: const Icon(Icons.share),
                  label: const Text("Share Results"),
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

  void _loadAvailableTools() {
    _availableTools = [
      {
        'id': 'compress',
        'name': 'Compress PDF',
        'description': 'Reduce file size while maintaining quality',
        'icon': Icons.compress,
        'category': 'optimization',
      },
      {
        'id': 'watermark',
        'name': 'Add Watermark',
        'description': 'Add text or image watermark to PDF',
        'icon': Icons.water_drop,
        'category': 'security',
      },
      {
        'id': 'password',
        'name': 'Password Protection',
        'description': 'Add password protection to PDF',
        'icon': Icons.lock,
        'category': 'security',
      },
      {
        'id': 'grayscale',
        'name': 'Convert to Grayscale',
        'description': 'Convert PDF to black and white',
        'icon': Icons.grayscale,
        'category': 'conversion',
      },
      {
        'id': 'rotate',
        'name': 'Rotate Pages',
        'description': 'Rotate PDF pages by 90 degrees',
        'icon': Icons.rotate_right,
        'category': 'editing',
      },
      {
        'id': 'merge',
        'name': 'Merge PDFs',
        'description': 'Combine multiple PDF files into one',
        'icon': Icons.merge,
        'category': 'editing',
      },
      {
        'id': 'split',
        'name': 'Split PDF',
        'description': 'Split PDF into multiple files',
        'icon': Icons.call_split,
        'category': 'editing',
      },
      {
        'id': 'ocr',
        'name': 'OCR Processing',
        'description': 'Extract text from scanned documents',
        'icon': Icons.text_fields,
        'category': 'extraction',
      },
    ];
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _selectedFiles.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _startBatchProcessing() async {
    if (_selectedFiles.isEmpty || _selectedTools.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _processingResults.clear();
    });

    try {
      // Simulate batch processing
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        final fileName = file.path.split('/').last;
        
        // Simulate processing time
        await Future.delayed(const Duration(seconds: 1));
        
        // Mock processing result
        final isSuccess = i % 3 != 0; // Simulate some failures
        _processingResults.add({
          'fileName': fileName,
          'status': isSuccess ? 'success' : 'failed',
          'message': isSuccess 
              ? 'Processed successfully with ${_selectedTools.length} tools'
              : 'Failed at tool: ${_selectedTools[0]['name']}',
          'duration': '${1 + i}s',
        });
        
        setState(() {});
      }

      setState(() {
        _isProcessing = false;
      });

      final successCount = _processingResults.where((r) => r['status'] == 'success').length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Batch processing completed! $successCount/${_selectedFiles.length} files processed successfully.'),
          backgroundColor: successCount == _selectedFiles.length ? AppColors.primaryGreen : AppColors.primaryOrange,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during batch processing: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _openResultsFolder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening results folder...'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing processing results...'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}
