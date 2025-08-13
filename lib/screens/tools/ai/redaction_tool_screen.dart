import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';

class RedactionToolScreen extends StatefulWidget {
  const RedactionToolScreen({super.key});

  @override
  State<RedactionToolScreen> createState() => _RedactionToolScreenState();
}

class _RedactionToolScreenState extends State<RedactionToolScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  List<String> _redactionKeywords = [];
  final TextEditingController _keywordController = TextEditingController();
  String _redactionMode = 'text'; // 'text', 'pattern', 'area'
  String _redactionColor = 'black'; // 'black', 'white', 'custom'
  Color _customColor = Colors.black;
  bool _caseSensitive = false;
  bool _useRegex = false;
  double _confidence = 0.8;
  List<Map<String, dynamic>> _detectedItems = [];

  final Map<String, String> _modeOptions = {
    'text': 'Text Redaction',
    'pattern': 'Pattern Redaction',
    'area': 'Area Redaction',
  };

  final Map<String, String> _colorOptions = {
    'black': 'Black Box',
    'white': 'White Box',
    'custom': 'Custom Color',
  };

  @override
  void initState() {
    super.initState();
    _redactionKeywords = [
      'confidential',
      'secret',
      'private',
      'internal',
      'sensitive',
    ];
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redaction Tool"),
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
            if (_selectedFile != null) _buildRedactionSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildKeywordsSection(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_detectedItems.isNotEmpty) _buildDetectionResults(),
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
            AppColors.primaryRed.withOpacity(0.1),
            AppColors.primaryOrange.withOpacity(0.05),
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
              Icons.security,
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
                  "Redaction Tool",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Permanently remove sensitive information from documents",
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
                    color: AppColors.primaryRed.withOpacity(0.3),
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
                      "Tap to select PDF file",
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: AppColors.primaryRed,
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
                        _detectedItems.clear();
                        _outputPath = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: AppColors.primaryRed,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRedactionSettings() {
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
            "Redaction Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _redactionMode,
            decoration: InputDecoration(
              labelText: "Redaction Mode",
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
                _redactionMode = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _redactionColor,
            decoration: InputDecoration(
              labelText: "Redaction Color",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _colorOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _redactionColor = value!;
              });
            },
          ),

          if (_redactionColor == 'custom') ...[
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Custom Color"),
              subtitle: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: _customColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              trailing: IconButton(
                onPressed: _pickCustomColor,
                icon: const Icon(Icons.color_lens),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Text(
            "Detection Confidence: ${(_confidence * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _confidence,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _confidence = value;
              });
            },
          ),

          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text("Case Sensitive"),
            subtitle: const Text("Match exact case when searching"),
            value: _caseSensitive,
            onChanged: (value) {
              setState(() {
                _caseSensitive = value;
              });
            },
            activeColor: AppColors.primaryRed,
          ),

          SwitchListTile(
            title: const Text("Use Regular Expressions"),
            subtitle: const Text("Advanced pattern matching"),
            value: _useRegex,
            onChanged: (value) {
              setState(() {
                _useRegex = value;
              });
            },
            activeColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection() {
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
            "Redaction Keywords",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Add keywords or patterns to redact from the document",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    hintText: "Enter keyword or pattern",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      onPressed: _addKeyword,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  onSubmitted: (_) => _addKeyword(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_redactionKeywords.isNotEmpty) ...[
            Text(
              "Current Keywords (${_redactionKeywords.length})",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _redactionKeywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeKeyword(keyword),
                  backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                  deleteIconColor: AppColors.primaryRed,
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addCommonKeywords,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Add Common Keywords"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearKeywords,
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
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _detectAndRedact,
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
        label: Text(_isProcessing ? "Processing..." : "Detect & Redact"),
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

  Widget _buildDetectionResults() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.2),
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
                  color: AppColors.primaryOrange.withOpacity(0.1),
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
                "Detected Items",
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
              color: AppColors.primaryOrange.withOpacity(0.1),
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
                        "${_detectedItems.length} items found",
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Review and confirm before redaction",
                        style: TextStyle(
                          color: AppColors.primaryOrange.withOpacity(0.8),
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
            itemCount: _detectedItems.length,
            itemBuilder: (context, index) {
              final item = _detectedItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getItemTypeIcon(item['type']),
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['text'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Page ${item['page']} • ${item['type']} • Confidence: ${(item['confidence'] * 100).toInt()}%",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                    value: item['selected'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        _detectedItems[index]['selected'] = value;
                      });
                    },
                    activeColor: AppColors.primaryRed,
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
                  onPressed: _selectAll,
                  icon: const Icon(Icons.select_all),
                  label: const Text("Select All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: BorderSide(color: AppColors.primaryOrange),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyRedaction,
                  icon: const Icon(Icons.security),
                  label: const Text("Apply Redaction"),
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
                "Redaction Complete",
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
                        "Redacted PDF saved successfully",
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
                  onPressed: _openRedactedFile,
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
                  onPressed: _shareRedactedFile,
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
          _detectedItems.clear();
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

  void _addKeyword() {
    if (_keywordController.text.trim().isNotEmpty) {
      setState(() {
        _redactionKeywords.add(_keywordController.text.trim());
        _keywordController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _redactionKeywords.remove(keyword);
    });
  }

  void _addCommonKeywords() {
    setState(() {
      _redactionKeywords.addAll([
        'ssn',
        'credit card',
        'password',
        'email',
        'phone',
        'address',
        'date of birth',
        'social security',
        'account number',
        'routing number',
      ]);
    });
  }

  void _clearKeywords() {
    setState(() {
      _redactionKeywords.clear();
    });
  }

  Future<void> _pickCustomColor() async {
    // In a real implementation, you would use a color picker
    setState(() {
      _customColor = Colors.red;
    });
  }

  Future<void> _detectAndRedact() async {
    if (_selectedFile == null || _redactionKeywords.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate detection process
      await Future.delayed(const Duration(seconds: 3));

      // Mock detected items
      final mockItems = [
        {
          'type': 'text',
          'text': 'confidential information',
          'page': 1,
          'confidence': 0.95,
          'selected': true,
        },
        {
          'type': 'text',
          'text': 'secret document',
          'page': 2,
          'confidence': 0.88,
          'selected': true,
        },
        {
          'type': 'pattern',
          'text': '123-45-6789',
          'page': 1,
          'confidence': 0.92,
          'selected': true,
        },
        {
          'type': 'text',
          'text': 'internal use only',
          'page': 3,
          'confidence': 0.85,
          'selected': true,
        },
      ];

      setState(() {
        _detectedItems = mockItems;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${mockItems.length} items to redact'),
          backgroundColor: AppColors.primaryOrange,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detecting items: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _selectAll() {
    setState(() {
      for (var item in _detectedItems) {
        item['selected'] = true;
      }
    });
  }

  Future<void> _applyRedaction() async {
    final selectedItems = _detectedItems.where((item) => item['selected'] == true).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No items selected for redaction'),
          backgroundColor: AppColors.primaryOrange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate redaction process
      await Future.delayed(const Duration(seconds: 2));

      final outputPath = await _getOutputPath('redacted_${DateTime.now().millisecondsSinceEpoch}.pdf');

      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully redacted ${selectedItems.length} items!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying redaction: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _openRedactedFile() async {
    if (_outputPath == null) return;

    try {
      final file = File(_outputPath!);
      await FileService.openFile(file);  // Changed from instance to static method call
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _shareRedactedFile() async {
    if (_outputPath == null) return;

    try {
      final file = File(_outputPath!);
      await FileService.shareFile(file);  // Changed from instance to static method call
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
    final directory = await FileService.getAppDirectoryPath();  // Changed from instance to static method call
    return '$directory/$filename';
  }

  IconData _getItemTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'pattern':
        return Icons.pattern;
      case 'area':
        return Icons.crop_square;
      default:
        return Icons.help;
    }
  }
}