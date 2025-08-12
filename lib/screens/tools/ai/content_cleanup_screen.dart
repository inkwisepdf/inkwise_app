import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class ContentCleanupScreen extends StatefulWidget {
  const ContentCleanupScreen({super.key});

  @override
  State<ContentCleanupScreen> createState() => _ContentCleanupScreenState();
}

class _ContentCleanupScreenState extends State<ContentCleanupScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  String _cleanupMode = 'auto'; // 'auto', 'manual', 'selective'
  String _fileType = 'image'; // 'image', 'pdf'
  double _cleanupIntensity = 0.5;
  bool _removeWatermarks = true;
  bool _removeStains = true;
  bool _removeNoise = true;
  bool _enhanceText = true;
  bool _preserveColors = false;
  List<String> _detectedIssues = [];

  final Map<String, String> _modeOptions = {
    'auto': 'Automatic Cleanup',
    'manual': 'Manual Selection',
    'selective': 'Selective Cleanup',
  };

  final Map<String, String> _fileTypeOptions = {
    'image': 'Image File',
    'pdf': 'PDF Document',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Content Cleanup"),
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
            if (_selectedFile != null) _buildCleanupSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_detectedIssues.isNotEmpty) _buildIssuesList(),
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
            AppColors.primaryGreen.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
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
              Icons.cleaning_services,
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
                  "Content Cleanup",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Remove stains, watermarks, and imperfections from documents",
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
          Text(
            "Select Document",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _fileType,
            decoration: InputDecoration(
              labelText: "File Type",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _fileTypeOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _fileType = value!;
                _selectedFile = null;
                _detectedIssues.clear();
                _outputPath = null;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          if (_selectedFile == null)
            GestureDetector(
              onTap: _selectFile,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _fileType == 'image' ? Icons.image : Icons.description,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to select ${_fileType == 'image' ? 'image' : 'PDF'} file",
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
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _fileType == 'image' ? Icons.image : Icons.description,
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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                        _detectedIssues.clear();
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

  Widget _buildCleanupSettings() {
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
          Text(
            "Cleanup Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _cleanupMode,
            decoration: InputDecoration(
              labelText: "Cleanup Mode",
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
                _cleanupMode = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Cleanup Intensity: ${(_cleanupIntensity * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _cleanupIntensity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _cleanupIntensity = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Cleanup Options",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          SwitchListTile(
            title: const Text("Remove Watermarks"),
            subtitle: const Text("Detect and remove watermarks"),
            value: _removeWatermarks,
            onChanged: (value) {
              setState(() {
                _removeWatermarks = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Remove Stains"),
            subtitle: const Text("Clean up stains and marks"),
            value: _removeStains,
            onChanged: (value) {
              setState(() {
                _removeStains = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Remove Noise"),
            subtitle: const Text("Reduce image noise and artifacts"),
            value: _removeNoise,
            onChanged: (value) {
              setState(() {
                _removeNoise = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Enhance Text"),
            subtitle: const Text("Improve text readability"),
            value: _enhanceText,
            onChanged: (value) {
              setState(() {
                _enhanceText = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Preserve Colors"),
            subtitle: const Text("Maintain original colors"),
            value: _preserveColors,
            onChanged: (value) {
              setState(() {
                _preserveColors = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _analyzeAndCleanup,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.search),
        label: Text(_isProcessing ? "Analyzing..." : "Analyze & Cleanup"),
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

  Widget _buildIssuesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.2),
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
                                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Detected Issues",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_detectedIssues.length} issues found",
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Review and apply cleanup",
                        style: TextStyle(
                          color: AppColors.primaryOrange.withValues(alpha: 0.8),
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
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _detectedIssues.length,
            itemBuilder: (context, index) {
              final issue = _detectedIssues[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIssueIcon(issue),
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    issue,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Will be cleaned up automatically",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: _applyCleanup,
            icon: const Icon(Icons.cleaning_services),
            label: const Text("Apply Cleanup"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
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
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
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
                "Cleanup Complete",
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
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cleaning_services,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Document cleaned successfully",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "File: ${_outputPath!.split('/').last}",
                        style: TextStyle(
                          color: AppColors.primaryGreen.withValues(alpha: 0.8),
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
                  onPressed: _openCleanedFile,
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
                  onPressed: _shareCleanedFile,
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

  Future<void> _selectFile() async {
    try {
      if (_fileType == 'image') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          setState(() {
            _selectedFile = File(image.path);
            _detectedIssues.clear();
            _outputPath = null;
          });
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null) {
          setState(() {
            _selectedFile = File(result.files.single.path!);
            _detectedIssues.clear();
            _outputPath = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _analyzeAndCleanup() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate analysis process
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock detected issues
      final mockIssues = [
        'Watermark detected',
        'Stain on page 1',
        'Image noise present',
        'Text blur detected',
        'Background artifacts',
      ];

      setState(() {
        _detectedIssues = mockIssues;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${mockIssues.length} issues to clean'),
            backgroundColor: AppColors.primaryOrange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing document: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _applyCleanup() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate cleanup process
      await Future.delayed(const Duration(seconds: 2));
      
      final outputPath = await _getOutputPath('cleaned_${DateTime.now().millisecondsSinceEpoch}.${_fileType == 'image' ? 'png' : 'pdf'}');
      
      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Document cleaned successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying cleanup: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _openCleanedFile() async {
    if (_outputPath == null) return;
    
    try {
      final file = File(_outputPath!);
      await FileService.openFile(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _shareCleanedFile() async {
    if (_outputPath == null) return;
    
    try {
      final file = File(_outputPath!);
      await FileService.shareFile(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing file: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<String> _getOutputPath(String filename) async {
    final directory = await FileService.getAppDirectoryPath();
    return '$directory/$filename';
  }

  IconData _getIssueIcon(String issue) {
    if (issue.toLowerCase().contains('watermark')) {
      return Icons.water_drop;
    } else if (issue.toLowerCase().contains('stain')) {
      return Icons.blur_on;
    } else if (issue.toLowerCase().contains('noise')) {
      return Icons.grain;
    } else if (issue.toLowerCase().contains('blur')) {
      return Icons.blur_circular;
    } else {
      return Icons.warning;
    }
  }
}
