import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';

class FormDetectorScreen extends StatefulWidget {
  const FormDetectorScreen({super.key});

  @override
  State<FormDetectorScreen> createState() => _FormDetectorScreenState();
}

class _FormDetectorScreenState extends State<FormDetectorScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  List<Map<String, dynamic>>? _detectedForms;
  String _detectionMode = 'auto'; // 'auto', 'manual'
  double _confidence = 0.8;
  bool _detectTextFields = true;
  bool _detectCheckboxes = true;
  bool _detectRadioButtons = true;
  bool _detectSignatureFields = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Detector"),
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
            if (_detectedForms != null) _buildResults(),
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
              Icons.description,
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
                  "Form Detector",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Detect and fill form fields in scanned documents",
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
                        _detectedForms = null;
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
          
          RadioListTile<String>(
            title: const Text("Automatic Detection"),
            subtitle: const Text("Use AI to automatically detect form fields"),
            value: 'auto',
            groupValue: _detectionMode,
            onChanged: (value) {
              setState(() {
                _detectionMode = value!;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          RadioListTile<String>(
            title: const Text("Manual Detection"),
            subtitle: const Text("Manually select areas to detect as form fields"),
            value: 'manual',
            groupValue: _detectionMode,
            onChanged: (value) {
              setState(() {
                _detectionMode = value!;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
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
          
          Text(
            "Field Types to Detect",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          SwitchListTile(
            title: const Text("Text Fields"),
            subtitle: const Text("Input boxes, text areas"),
            value: _detectTextFields,
            onChanged: (value) {
              setState(() {
                _detectTextFields = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Checkboxes"),
            subtitle: const Text("Check boxes and tick marks"),
            value: _detectCheckboxes,
            onChanged: (value) {
              setState(() {
                _detectCheckboxes = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Radio Buttons"),
            subtitle: const Text("Radio button groups"),
            value: _detectRadioButtons,
            onChanged: (value) {
              setState(() {
                _detectRadioButtons = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          SwitchListTile(
            title: const Text("Signature Fields"),
            subtitle: const Text("Signature areas and lines"),
            value: _detectSignatureFields,
            onChanged: (value) {
              setState(() {
                _detectSignatureFields = value;
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
        onPressed: _isProcessing ? null : _detectForms,
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
        label: Text(_isProcessing ? "Detecting Forms..." : "Detect Forms"),
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

  Widget _buildResults() {
    if (_detectedForms == null || _detectedForms!.isEmpty) {
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
          children: [
            Icon(
              Icons.warning,
              color: AppColors.primaryOrange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "No Forms Detected",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No form fields were detected in the PDF. Try adjusting the confidence level or check if the PDF contains form elements.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryOrange.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

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
                "Forms Detected",
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
                        "${_detectedForms!.length} Form Fields Found",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Confidence: ${(_confidence * 100).toInt()}% • Mode: ${_detectionMode == 'auto' ? 'Automatic' : 'Manual'}",
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
          
          // Form fields list
          Text(
            "Detected Fields",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _detectedForms!.length,
            itemBuilder: (context, index) {
              final field = _detectedForms![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getFieldTypeColor(field['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFieldTypeIcon(field['type']),
                      color: _getFieldTypeColor(field['type']),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    field['label'] ?? 'Unnamed Field',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Page ${field['page']} • ${field['type']} • Confidence: ${(field['confidence'] * 100).toInt()}%",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _fillField(field),
                    icon: const Icon(Icons.edit),
                    tooltip: "Fill Field",
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
                  onPressed: _exportFormData,
                  icon: const Icon(Icons.download),
                  label: const Text("Export Data"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createFillablePDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Create Fillable PDF"),
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
          _detectedForms = null;
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

  Future<void> _detectForms() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate form detection with AI
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock detected form fields
      final mockForms = [
        {
          'type': 'text',
          'label': 'Full Name',
          'page': 1,
          'confidence': 0.95,
          'position': {'x': 100, 'y': 200, 'width': 200, 'height': 30},
        },
        {
          'type': 'text',
          'label': 'Email Address',
          'page': 1,
          'confidence': 0.92,
          'position': {'x': 100, 'y': 250, 'width': 200, 'height': 30},
        },
        {
          'type': 'checkbox',
          'label': 'I agree to terms',
          'page': 1,
          'confidence': 0.88,
          'position': {'x': 100, 'y': 300, 'width': 20, 'height': 20},
        },
        {
          'type': 'signature',
          'label': 'Signature',
          'page': 1,
          'confidence': 0.85,
          'position': {'x': 100, 'y': 350, 'width': 200, 'height': 50},
        },
        {
          'type': 'radio',
          'label': 'Gender',
          'page': 1,
          'confidence': 0.90,
          'position': {'x': 100, 'y': 420, 'width': 100, 'height': 30},
        },
      ];

      setState(() {
        _detectedForms = mockForms;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully detected ${mockForms.length} form fields!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detecting forms: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _fillField(Map<String, dynamic> field) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Fill ${field['label']}"),
        content: TextField(
          decoration: InputDecoration(
            labelText: "Enter value",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Field "${field['label']}" filled'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: const Text("Fill"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportFormData() async {
    try {
      final data = _detectedForms!.map((field) {
        return {
          'type': field['type'],
          'label': field['label'],
          'page': field['page'],
          'confidence': field['confidence'],
        };
      }).toList();
      
      final filename = 'form_data_${DateTime.now().millisecondsSinceEpoch}.json';
      final jsonString = data.toString(); // Simplified for demo
      await FileService().saveTextAsFile(jsonString, filename);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form data exported as $filename'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting form data: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _createFillablePDF() async {
    try {
      // Simulate creating fillable PDF
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fillable PDF created successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating fillable PDF: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Color _getFieldTypeColor(String type) {
    switch (type) {
      case 'text':
        return AppColors.primaryBlue;
      case 'checkbox':
        return AppColors.primaryGreen;
      case 'radio':
        return AppColors.primaryPurple;
      case 'signature':
        return AppColors.primaryOrange;
      default:
        return AppColors.primaryRed;
    }
  }

  IconData _getFieldTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'checkbox':
        return Icons.check_box;
      case 'radio':
        return Icons.radio_button_checked;
      case 'signature':
        return Icons.draw;
      default:
        return Icons.help;
    }
  }
}