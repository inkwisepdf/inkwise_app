import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/pdf_service.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class PDFSplitScreen extends StatefulWidget {
  const PDFSplitScreen({super.key});

  @override
  State<PDFSplitScreen> createState() => _PDFSplitScreenState();
}

class _PDFSplitScreenState extends State<PDFSplitScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  List<File>? _splitFiles;
  String _splitMode = 'all_pages'; // 'all_pages', 'custom_ranges'
  List<int> _pageRanges = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Split PDF"),
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
            if (_selectedFile != null) _buildSplitOptions(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_splitFiles != null) _buildResult(),
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
              Icons.content_cut,
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
                  "Split PDF",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Divide PDF into separate files by pages or custom ranges",
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
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
                        _splitFiles = null;
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

  Widget _buildSplitOptions() {
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
            "Split Options",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Split Mode Selection
          Text(
            "Split Mode",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          RadioListTile<String>(
            title: const Text("Split each page"),
            subtitle: const Text("Create separate file for each page"),
            value: 'all_pages',
            groupValue: _splitMode,
            onChanged: (value) {
              setState(() {
                _splitMode = value!;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          RadioListTile<String>(
            title: const Text("Custom ranges"),
            subtitle: const Text("Split by specific page ranges"),
            value: 'custom_ranges',
            groupValue: _splitMode,
            onChanged: (value) {
              setState(() {
                _splitMode = value!;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          
          if (_splitMode == 'custom_ranges') ...[
            const SizedBox(height: 16),
            Text(
              "Page Ranges (e.g., 1-3, 5, 7-9)",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter page ranges separated by commas",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Parse page ranges
                _parsePageRanges(value);
              },
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
        onPressed: _isProcessing ? null : _splitPDF,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.content_cut),
        label: Text(_isProcessing ? "Splitting..." : "Split PDF"),
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
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Split Complete",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            "Created ${_splitFiles!.length} file(s):",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _splitFiles!.length,
            itemBuilder: (context, index) {
              final file = _splitFiles![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      "${index + 1}.",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.path.split('/').last,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      "${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final appDir = await FileService.getAppDirectoryPath();
                      await FileService.openFile(File(appDir));
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error opening folder: $e'),
                            backgroundColor: AppColors.primaryRed,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Open Folder"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // Share the first file as an example
                      if (_splitFiles!.isNotEmpty) {
                        await FileService.shareFile(_splitFiles!.first);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sharing files: $e'),
                            backgroundColor: AppColors.primaryRed,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text("Share All"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
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

  void _parsePageRanges(String input) {
    // Simple page range parsing
    // This is a basic implementation - could be enhanced
    final ranges = input.split(',');
    _pageRanges.clear();
    
    for (final range in ranges) {
      final trimmed = range.trim();
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 2) {
          final start = int.tryParse(parts[0]);
          final end = int.tryParse(parts[1]);
          if (start != null && end != null && start <= end) {
            for (int i = start; i <= end; i++) {
              _pageRanges.add(i);
            }
          }
        }
      } else {
        final page = int.tryParse(trimmed);
        if (page != null) {
          _pageRanges.add(page);
        }
      }
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
          _splitFiles = null;
        });
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

  Future<void> _splitPDF() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfService = PDFService();
      List<File> splitFiles;
      
      if (_splitMode == 'all_pages') {
        splitFiles = await pdfService.splitPDF(_selectedFile!);
      } else {
        splitFiles = await pdfService.splitPDF(_selectedFile!, pageRanges: _pageRanges);
      }

      setState(() {
        _splitFiles = splitFiles;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF split successfully into ${splitFiles.length} files!'),
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
            content: Text('Error splitting PDF: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }
}

