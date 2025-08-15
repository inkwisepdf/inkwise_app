import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/pdf_service.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class PDFGrayscaleScreen extends StatefulWidget {
  const PDFGrayscaleScreen({super.key});

  @override
  State<PDFGrayscaleScreen> createState() => _PDFGrayscaleScreenState();
}

class _PDFGrayscaleScreenState extends State<PDFGrayscaleScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  double _threshold = 0.5;
  String _conversionMode =
      'all_pages'; // 'all_pages', 'specific_pages', 'page_range'
  final List<int> _selectedPages = [];
  int? _startPage;
  int? _endPage;
  int _totalPages = 0;
  bool _preserveText = true;
  bool _enhanceContrast = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grayscale PDF"),
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
            if (_selectedFile != null) _buildConversionOptions(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildGrayscaleSettings(),
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
            AppColors.primaryOrange.withValues(alpha: 0.1),
            AppColors.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.2),
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
              Icons.filter_alt,
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
                  "Grayscale PDF",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Convert documents to black and white with advanced threshold control",
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
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
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
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
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
                          "Size: ${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB • Pages: $_totalPages",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
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
                        _outputPath = null;
                        _totalPages = 0;
                        _selectedPages.clear();
                        _startPage = null;
                        _endPage = null;
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

  Widget _buildConversionOptions() {
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
            "Conversion Options",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text("Convert all pages"),
            subtitle: const Text("Convert every page to grayscale"),
            value: 'all_pages',
            groupValue: _conversionMode,
            onChanged: (value) {
              setState(() {
                _conversionMode = value!;
                _selectedPages.clear();
                _startPage = null;
                _endPage = null;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          RadioListTile<String>(
            title: const Text("Convert specific pages"),
            subtitle: const Text("Select individual pages to convert"),
            value: 'specific_pages',
            groupValue: _conversionMode,
            onChanged: (value) {
              setState(() {
                _conversionMode = value!;
                _startPage = null;
                _endPage = null;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          RadioListTile<String>(
            title: const Text("Convert page range"),
            subtitle: const Text("Convert a range of pages"),
            value: 'page_range',
            groupValue: _conversionMode,
            onChanged: (value) {
              setState(() {
                _conversionMode = value!;
                _selectedPages.clear();
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          if (_conversionMode == 'specific_pages') ...[
            const SizedBox(height: 16),
            Text(
              "Select Pages",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_totalPages, (index) {
                final pageNumber = index + 1;
                final isSelected = _selectedPages.contains(pageNumber);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedPages.remove(pageNumber);
                      } else {
                        _selectedPages.add(pageNumber);
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primaryOrange : Colors.grey,
                      ),
                    ),
                    child: Text(
                      pageNumber.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          if (_conversionMode == 'page_range') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Start Page",
                      hintText: "1",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _startPage = int.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "End Page",
                      hintText: _totalPages.toString(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _endPage = int.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrayscaleSettings() {
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
            "Grayscale Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            "Threshold: ${(_threshold * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _threshold,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _threshold = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Preserve Text Quality"),
            subtitle: const Text("Maintain text readability during conversion"),
            value: _preserveText,
            onChanged: (value) {
              setState(() {
                _preserveText = value;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          SwitchListTile(
            title: const Text("Enhance Contrast"),
            subtitle: const Text("Improve contrast for better readability"),
            value: _enhanceContrast,
            onChanged: (value) {
              setState(() {
                _enhanceContrast = value;
              });
            },
            activeColor: AppColors.primaryOrange,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryOrange,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Threshold controls the brightness level at which colors are converted to black or white. Lower values create darker images, higher values create lighter images.",
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    bool canProcess = _selectedFile != null &&
        (_conversionMode == 'all_pages' ||
            (_conversionMode == 'specific_pages' &&
                _selectedPages.isNotEmpty) ||
            (_conversionMode == 'page_range' &&
                _startPage != null &&
                _endPage != null &&
                _startPage! <= _endPage!));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing || !canProcess ? null : _convertToGrayscale,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.filter_alt),
        label: Text(_isProcessing ? "Converting..." : "Convert to Grayscale"),
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
                "Conversion Complete",
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
                  Icons.filter_alt,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Grayscale PDF",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Threshold: ${(_threshold * 100).toInt()}% • Preserve Text: ${_preserveText ? 'Yes' : 'No'}",
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
                  onPressed: () async {
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
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open File"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                  },
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
          _outputPath = null;
          _selectedPages.clear();
          _startPage = null;
          _endPage = null;
        });

        // Get total pages
        await _getTotalPages();
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

  Future<void> _getTotalPages() async {
    try {
      final pdfService = PDFService();
      final info = await pdfService.getPDFInfo(_selectedFile!);
      setState(() {
        _totalPages = info['pageCount'] ?? 0;
      });
    } catch (e) {
      setState(() {
        _totalPages = 0;
      });
    }
  }

  Future<void> _convertToGrayscale() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfService = PDFService();
      File grayscaleFile;

      if (_conversionMode == 'all_pages') {
        grayscaleFile = await pdfService.convertToGrayscale(
          _selectedFile!,
          threshold: _threshold,
          preserveText: _preserveText,
          enhanceContrast: _enhanceContrast,
        );
      } else if (_conversionMode == 'specific_pages') {
        grayscaleFile = await pdfService.convertToGrayscale(
          _selectedFile!,
          threshold: _threshold,
          preserveText: _preserveText,
          enhanceContrast: _enhanceContrast,
          pageNumbers: _selectedPages,
        );
      } else {
        // page_range mode
        if (_startPage == null || _endPage == null) {
          throw Exception('Please specify start and end pages');
        }

        final pageNumbers = List.generate(
          _endPage! - _startPage! + 1,
          (index) => _startPage! + index,
        );

        grayscaleFile = await pdfService.convertToGrayscale(
          _selectedFile!,
          threshold: _threshold,
          preserveText: _preserveText,
          enhanceContrast: _enhanceContrast,
          pageNumbers: pageNumbers,
        );
      }

      setState(() {
        _outputPath = grayscaleFile.path;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF converted to grayscale successfully!'),
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
            content: Text('Error converting to grayscale: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }
}
