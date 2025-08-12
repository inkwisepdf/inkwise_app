import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';

class AutoTaggingScreen extends StatefulWidget {
  const AutoTaggingScreen({super.key});

  @override
  State<AutoTaggingScreen> createState() => _AutoTaggingScreenState();
}

class _AutoTaggingScreenState extends State<AutoTaggingScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _detectedTags = [];
  String _detectionMode = 'auto'; // 'auto', 'manual', 'custom'
  bool _includeContentAnalysis = true;
  bool _includeMetadataAnalysis = true;
  bool _includeFileNameAnalysis = true;
  double _confidenceThreshold = 0.7;
  List<Map<String, dynamic>> _taggedFiles = [];

  final Map<String, String> _modeOptions = {
    'auto': 'Automatic Detection',
    'manual': 'Manual Review',
    'custom': 'Custom Rules',
  };

  @override
  void initState() {
    super.initState();
    _loadMockTaggedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto Tagging"),
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
            if (_selectedFile != null) _buildDetectionSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_detectedTags.isNotEmpty) _buildDetectionResults(),
            const SizedBox(height: 24),
            _buildTaggedFilesList(),
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
            AppColors.primaryOrange.withOpacity(0.1),
            AppColors.primaryPurple.withOpacity(0.05),
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
              Icons.label,
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
                  "Auto Tagging",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Detect document type and auto-assign tags",
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
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: AppColors.primaryOrange,
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
                        _detectedTags.clear();
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: AppColors.primaryOrange,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetectionSettings() {
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
            "Detection Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _detectionMode,
            decoration: InputDecoration(
              labelText: "Detection Mode",
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
                _detectionMode = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Confidence Threshold: ${(_confidenceThreshold * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _confidenceThreshold,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _confidenceThreshold = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Analysis Options",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          SwitchListTile(
            title: const Text("Content Analysis"),
            subtitle: const Text("Analyze document content for keywords"),
            value: _includeContentAnalysis,
            onChanged: (value) {
              setState(() {
                _includeContentAnalysis = value;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          
          SwitchListTile(
            title: const Text("Metadata Analysis"),
            subtitle: const Text("Analyze PDF metadata and properties"),
            value: _includeMetadataAnalysis,
            onChanged: (value) {
              setState(() {
                _includeMetadataAnalysis = value;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          
          SwitchListTile(
            title: const Text("Filename Analysis"),
            subtitle: const Text("Analyze filename for patterns"),
            value: _includeFileNameAnalysis,
            onChanged: (value) {
              setState(() {
                _includeFileNameAnalysis = value;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _detectTags,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.label),
        label: Text(_isProcessing ? "Detecting..." : "Detect Tags"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionResults() {
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
                "Detected Tags (${_detectedTags.length})",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _detectedTags.map((tag) {
              final confidence = tag['confidence'] as double;
              final color = confidence >= 0.8 
                  ? AppColors.primaryGreen 
                  : confidence >= 0.6 
                      ? AppColors.primaryOrange 
                      : AppColors.primaryRed;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTagIcon(tag['type']),
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag['name'],
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${(confidence * 100).toInt()}%",
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _applyAllTags,
                  icon: const Icon(Icons.check),
                  label: const Text("Apply All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveTaggedFile,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
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

  Widget _buildTaggedFilesList() {
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
            "Recently Tagged Files (${_taggedFiles.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          if (_taggedFiles.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.label_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No tagged files",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start tagging files to see them here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _taggedFiles.length,
              itemBuilder: (context, index) {
                final file = _taggedFiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      file['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file['path'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (file['tags'] as List).take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          file['size'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleTaggedFileAction(value, file),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new, size: 16),
                                  SizedBox(width: 8),
                                  Text("Open"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit_tags',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text("Edit Tags"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle, size: 16),
                                  SizedBox(width: 8),
                                  Text("Remove"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _loadMockTaggedFiles() {
    _taggedFiles = [
      {
        'id': '1',
        'name': 'Business Report 2024.pdf',
        'path': '/Documents/Business/',
        'size': '2.4 MB',
        'tags': ['business', 'report', '2024', 'financial'],
        'taggedDate': '2024-01-15',
      },
      {
        'id': '2',
        'name': 'Technical Documentation.pdf',
        'path': '/Documents/Technical/',
        'size': '5.2 MB',
        'tags': ['technical', 'documentation', 'guide', 'manual'],
        'taggedDate': '2024-01-14',
      },
      {
        'id': '3',
        'name': 'Meeting Notes.pdf',
        'path': '/Documents/Meetings/',
        'size': '1.8 MB',
        'tags': ['meeting', 'notes', 'minutes', 'agenda'],
        'taggedDate': '2024-01-13',
      },
    ];
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
          _detectedTags.clear();
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

  Future<void> _detectTags() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate tag detection process
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock detected tags based on filename
      final fileName = _selectedFile!.path.split('/').last.toLowerCase();
      _detectedTags = [];
      
      if (fileName.contains('report')) {
        _detectedTags.add({
          'name': 'report',
          'type': 'document_type',
          'confidence': 0.95,
        });
        _detectedTags.add({
          'name': 'business',
          'type': 'category',
          'confidence': 0.85,
        });
      }
      
      if (fileName.contains('2024')) {
        _detectedTags.add({
          'name': '2024',
          'type': 'year',
          'confidence': 0.90,
        });
      }
      
      if (fileName.contains('financial') || fileName.contains('business')) {
        _detectedTags.add({
          'name': 'financial',
          'type': 'category',
          'confidence': 0.75,
        });
      }
      
      // Add some generic tags
      _detectedTags.add({
        'name': 'pdf',
        'type': 'format',
        'confidence': 1.0,
      });
      
      _detectedTags.add({
        'name': 'document',
        'type': 'document_type',
        'confidence': 0.80,
      });

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag detection completed! ${_detectedTags.length} tags found.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detecting tags: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _applyAllTags() {
    // In a real implementation, this would apply all detected tags to the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${_detectedTags.length} tags to the file'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _saveTaggedFile() {
    // In a real implementation, this would save the tagged file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tagged file saved successfully'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _handleTaggedFileAction(String action, Map<String, dynamic> file) {
    switch (action) {
      case 'open':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening file: ${file['name']}'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
        break;
      case 'edit_tags':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Editing tags for: ${file['name']}'),
            backgroundColor: AppColors.primaryOrange,
          ),
        );
        break;
      case 'remove':
        setState(() {
          _taggedFiles.removeWhere((f) => f['id'] == file['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed file: ${file['name']}'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        break;
    }
  }

  IconData _getTagIcon(String type) {
    switch (type) {
      case 'document_type':
        return Icons.description;
      case 'category':
        return Icons.category;
      case 'year':
        return Icons.calendar_today;
      case 'format':
        return Icons.file_present;
      default:
        return Icons.label;
    }
  }
}
