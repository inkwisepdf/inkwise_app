import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/pdf_service.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class PDFImagesScreen extends StatefulWidget {
  const PDFImagesScreen({super.key});

  @override
  State<PDFImagesScreen> createState() => _PDFImagesScreenState();
}

class _PDFImagesScreenState extends State<PDFImagesScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  List<File>? _convertedImages;
  String _imageFormat = 'png'; // 'png', 'jpg', 'jpeg'
  double _quality = 0.8;
  double _scale = 2.0;
  String _conversionMode = 'all_pages'; // 'all_pages', 'specific_pages', 'page_range'
  List<int> _selectedPages = [];
  int? _startPage;
  int? _endPage;
  int _totalPages = 0;

  final Map<String, String> _formatOptions = {
    'png': 'PNG (Lossless)',
    'jpg': 'JPEG (Compressed)',
    'jpeg': 'JPEG (High Quality)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF to Images"),
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
            if (_selectedFile != null) _buildImageSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_convertedImages != null) _buildResult(),
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
              Icons.image,
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
                  "PDF to Images",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Convert PDF pages to high-quality image files",
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
                          "Size: ${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB • Pages: $_totalPages",
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
                        _convertedImages = null;
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
            subtitle: const Text("Convert every page to image"),
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
            activeColor: AppColors.primaryGreen,
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
            activeColor: AppColors.primaryGreen,
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
            activeColor: AppColors.primaryGreen,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreen : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : Colors.grey,
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

  Widget _buildImageSettings() {
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
            "Image Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _imageFormat,
            decoration: InputDecoration(
              labelText: "Image Format",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _formatOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _imageFormat = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Quality: ${(_quality * 100).toInt()}%",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _quality,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _quality = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Scale: ${_scale.toStringAsFixed(1)}x",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _scale,
            min: 0.5,
            max: 4.0,
            divisions: 35,
            onChanged: (value) {
              setState(() {
                _scale = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: const Text(
                    "Higher scale produces larger, higher quality images but increases file size.",
                    style: TextStyle(
                      color: AppColors.primaryGreen,
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
         (_conversionMode == 'specific_pages' && _selectedPages.isNotEmpty) ||
         (_conversionMode == 'page_range' && _startPage != null && _endPage != null && _startPage! <= _endPage!));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing || !canProcess ? null : _convertToImages,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.image),
        label: Text(_isProcessing ? "Converting..." : "Convert to Images"),
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
    if (_convertedImages == null || _convertedImages!.isEmpty) return const SizedBox.shrink();

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
                  Icons.image,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_convertedImages!.length} Images Created",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Format: ${_formatOptions[_imageFormat]} • Quality: ${(_quality * 100).toInt()}%",
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
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // Share the first image as an example
                      if (_convertedImages!.isNotEmpty) {
                        await FileService.shareFile(_convertedImages!.first);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sharing images: $e'),
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
          _convertedImages = null;
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

  Future<void> _convertToImages() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfService = PDFService();
      List<File> convertedImages;

      if (_conversionMode == 'all_pages') {
        convertedImages = await pdfService.convertPDFToImages(
          _selectedFile!,
          format: _imageFormat,
          quality: _quality,
          scale: _scale,
        );
      } else if (_conversionMode == 'specific_pages') {
        convertedImages = await pdfService.convertPDFToImages(
          _selectedFile!,
          format: _imageFormat,
          quality: _quality,
          scale: _scale,
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
        
        convertedImages = await pdfService.convertPDFToImages(
          _selectedFile!,
          format: _imageFormat,
          quality: _quality,
          scale: _scale,
          pageNumbers: pageNumbers,
        );
      }

      setState(() {
        _convertedImages = convertedImages;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully converted ${convertedImages.length} pages to images!'),
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
            content: Text('Error converting PDF to images: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }
}

