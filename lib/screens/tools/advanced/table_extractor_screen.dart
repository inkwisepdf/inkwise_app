import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/pdf_service.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class TableExtractorScreen extends StatefulWidget {
  const TableExtractorScreen({super.key});

  @override
  State<TableExtractorScreen> createState() => _TableExtractorScreenState();
}

class _TableExtractorScreenState extends State<TableExtractorScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  List<Map<String, dynamic>>? _extractedTables;
  String _outputFormat = 'csv'; // 'csv', 'excel', 'json'
  bool _includeHeaders = true;
  bool _detectTableStructure = true;
  double _confidence = 0.8;
  int _totalPages = 0;

  final Map<String, String> _formatOptions = {
    'csv': 'CSV (Comma Separated Values)',
    'excel': 'Excel (XLSX)',
    'json': 'JSON (Structured Data)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Table Extractor"),
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
            if (_selectedFile != null) _buildExtractionSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_extractedTables != null) _buildResults(),
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
            AppColors.primaryPurple.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.table_chart,
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
                  "Table Extractor",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Extract tables from documents using AI-powered detection",
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
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
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
                      color: AppColors.primaryPurple,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap to select PDF file",
                      style: TextStyle(
                        color: AppColors.primaryPurple,
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
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: AppColors.primaryPurple,
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
                        _extractedTables = null;
                        _totalPages = 0;
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

  Widget _buildExtractionSettings() {
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
            "Extraction Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _outputFormat,
            decoration: InputDecoration(
              labelText: "Output Format",
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
                _outputFormat = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Include Headers"),
            subtitle: const Text("Extract table headers as column names"),
            value: _includeHeaders,
            onChanged: (value) {
              setState(() {
                _includeHeaders = value;
              });
            },
            activeColor: AppColors.primaryPurple,
          ),
          
          SwitchListTile(
            title: const Text("Auto-detect Structure"),
            subtitle: const Text("Use AI to detect table boundaries and structure"),
            value: _detectTableStructure,
            onChanged: (value) {
              setState(() {
                _detectTableStructure = value;
              });
            },
            activeColor: AppColors.primaryPurple,
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
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryPurple,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: const Text(
                    "Higher confidence requires more precise table structure. Lower confidence may detect more tables but with less accuracy.",
                    style: TextStyle(
                      color: AppColors.primaryPurple,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _extractTables,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.table_chart),
        label: Text(_isProcessing ? "Extracting Tables..." : "Extract Tables"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
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
    if (_extractedTables == null || _extractedTables!.isEmpty) {
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
          children: [
            const Icon(
              Icons.warning,
              color: AppColors.primaryOrange,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Tables Found",
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "No tables were detected in the PDF. Try adjusting the confidence level or check if the PDF contains tabular data.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryOrange.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

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
              const Text(
                "Tables Extracted",
                style: TextStyle(
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
                  Icons.table_chart,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_extractedTables!.length} Tables Found",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Format: ${_formatOptions[_outputFormat]} • Confidence: ${(_confidence * 100).toInt()}%",
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
          
          // Table preview
          if (_extractedTables!.isNotEmpty) ...[
            Text(
              "Table Preview",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: _extractedTables!.first['headers']?.map<DataColumn>((header) {
                    return DataColumn(label: Text(header.toString()));
                  }).toList() ?? [],
                  rows: _extractedTables!.first['data']?.take(5).map<DataRow>((row) {
                    return DataRow(
                      cells: row.map<DataCell>((cell) {
                        return DataCell(Text(cell.toString()));
                      }).toList(),
                    );
                  }).toList() ?? [],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final data = _extractedTables!.map((table) {
                        return {
                          'headers': table['headers'],
                          'data': table['data'],
                          'page': table['page'],
                        };
                      }).toList();
                      
                      final filename = 'tables_${DateTime.now().millisecondsSinceEpoch}.json';
                      final jsonString = data.toString(); // Simplified for demo
                      await FileService.saveTextAsFile(jsonString, filename);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tables saved as $filename'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving tables: $e'),
                            backgroundColor: AppColors.primaryRed,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Save Data"),
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
                      // Share the first table as an example
                      if (_extractedTables!.isNotEmpty) {
                        final tableData = _extractedTables!.first;
                        final csvData = _convertToCSV(tableData);
                        final filename = 'table_1_${DateTime.now().millisecondsSinceEpoch}.csv';
                        await FileService.saveTextAsFile(csvData, filename);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Table exported as $filename'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      }
                                          } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error exporting table: $e'),
                              backgroundColor: AppColors.primaryRed,
                            ),
                          );
                        }
                      }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text("Export"),
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
          _extractedTables = null;
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

  Future<void> _extractTables() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate table extraction with AI
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock extracted tables data
      final mockTables = [
        {
          'page': 1,
          'headers': ['Name', 'Age', 'City', 'Occupation'],
          'data': [
            ['John Doe', '30', 'New York', 'Engineer'],
            ['Jane Smith', '25', 'Los Angeles', 'Designer'],
            ['Bob Johnson', '35', 'Chicago', 'Manager'],
            ['Alice Brown', '28', 'Houston', 'Developer'],
          ],
        },
        {
          'page': 2,
          'headers': ['Product', 'Price', 'Category', 'Stock'],
          'data': [
            ['Laptop', '\$999', 'Electronics', '50'],
            ['Phone', '\$699', 'Electronics', '100'],
            ['Tablet', '\$399', 'Electronics', '75'],
          ],
        },
      ];

      setState(() {
        _extractedTables = mockTables;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully extracted ${mockTables.length} tables!'),
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
            content: Text('Error extracting tables: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  String _convertToCSV(Map<String, dynamic> tableData) {
    final headers = tableData['headers'] as List? ?? [];
    final data = tableData['data'] as List? ?? [];
    
    final csvRows = <String>[];
    
    // Add headers
    if (headers.isNotEmpty) {
      csvRows.add(headers.join(','));
    }
    
    // Add data rows
    for (final row in data) {
      if (row is List) {
        csvRows.add(row.join(','));
      }
    }
    
    return csvRows.join('\n');
  }
}

