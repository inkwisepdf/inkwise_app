import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../theme.dart';
import '../../../services/file_service.dart';
import '../../../services/ai_summarizer_service.dart';

class KeywordAnalyticsScreen extends StatefulWidget {
  const KeywordAnalyticsScreen({super.key});

  @override
  State<KeywordAnalyticsScreen> createState() => _KeywordAnalyticsScreenState();
}

class _KeywordAnalyticsScreenState extends State<KeywordAnalyticsScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  Map<String, dynamic>? _analyticsData;
  String _analysisType = 'keyword_density'; // 'keyword_density', 'tf_idf', 'reading_time'
  bool _includeStopWords = false;
  int _minWordLength = 3;
  int _topKeywords = 20;
  String _selectedLanguage = 'en';

  final Map<String, String> _analysisOptions = {
    'keyword_density': 'Keyword Density',
    'tf_idf': 'TF-IDF Analysis',
    'reading_time': 'Reading Time & Complexity',
  };

  final Map<String, String> _languageOptions = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keyword Analytics"),
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
            if (_selectedFile != null) _buildAnalysisSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_analyticsData != null) _buildAnalyticsResults(),
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
            AppColors.primaryPurple.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
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
              Icons.analytics,
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
                  "Keyword Analytics",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Analyze word frequency and document insights",
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
                    color: AppColors.primaryPurple.withOpacity(0.3),
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
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.3),
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
                        _analyticsData = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: AppColors.primaryPurple,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSettings() {
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
            "Analysis Settings",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _analysisType,
            decoration: InputDecoration(
              labelText: "Analysis Type",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _analysisOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _analysisType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: InputDecoration(
              labelText: "Document Language",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _languageOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Top Keywords: $_topKeywords",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _topKeywords.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _topKeywords = value.round();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Minimum Word Length: $_minWordLength",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _minWordLength.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _minWordLength = value.round();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Include Stop Words"),
            subtitle: const Text("Include common words like 'the', 'and', 'is'"),
            value: _includeStopWords,
            onChanged: (value) {
              setState(() {
                _includeStopWords = value;
              });
            },
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _analyzeDocument,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.analytics),
        label: Text(_isProcessing ? "Analyzing..." : "Analyze Document"),
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

  Widget _buildAnalyticsResults() {
    if (_analyticsData == null) return const SizedBox.shrink();

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
                "Analysis Complete",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Document Statistics
          _buildDocumentStats(),
          const SizedBox(height: 24),
          
          // Keyword Analysis
          _buildKeywordAnalysis(),
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDocumentStats() {
    final stats = _analyticsData!['document_stats'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Document Statistics",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Words",
                  "${stats['total_words']}",
                  Icons.text_fields,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Unique Words",
                  "${stats['unique_words']}",
                  Icons.analytics,
                  AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Reading Time",
                  "${stats['reading_time']} min",
                  Icons.timer,
                  AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Complexity",
                  stats['complexity_level'],
                  Icons.school,
                  AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordAnalysis() {
    final keywords = _analyticsData!['keywords'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Top Keywords",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ListView.builder(
            itemCount: keywords.length,
            itemBuilder: (context, index) {
              final keyword = keywords[index] as Map<String, dynamic>;
              final frequency = keyword['frequency'] as double;
              final percentage = keyword['percentage'] as double;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  keyword['word'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "Frequency: ${frequency.toInt()} times",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _exportAnalytics,
            icon: const Icon(Icons.download),
            label: const Text("Export Report"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: BorderSide(color: AppColors.primaryPurple),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareAnalytics,
            icon: const Icon(Icons.share),
            label: const Text("Share"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
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
          _analyticsData = null;
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

  Future<void> _analyzeDocument() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Extract text from PDF
      final aiService = AISummarizerService();
      final extractedText = await aiService.extractTextFromPDF(_selectedFile!);
      
      // Simulate analysis process
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock analytics data
      final mockAnalytics = {
        'document_stats': {
          'total_words': 2847,
          'unique_words': 892,
          'reading_time': 12,
          'complexity_level': 'Intermediate',
          'sentences': 156,
          'paragraphs': 23,
        },
        'keywords': [
          {'word': 'document', 'frequency': 45, 'percentage': 1.6},
          {'word': 'analysis', 'frequency': 38, 'percentage': 1.3},
          {'word': 'content', 'frequency': 32, 'percentage': 1.1},
          {'word': 'information', 'frequency': 28, 'percentage': 1.0},
          {'word': 'process', 'frequency': 25, 'percentage': 0.9},
          {'word': 'system', 'frequency': 22, 'percentage': 0.8},
          {'word': 'data', 'frequency': 20, 'percentage': 0.7},
          {'word': 'report', 'frequency': 18, 'percentage': 0.6},
          {'word': 'review', 'frequency': 16, 'percentage': 0.6},
          {'word': 'management', 'frequency': 15, 'percentage': 0.5},
        ],
        'analysis_type': _analysisType,
        'language': _selectedLanguage,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _analyticsData = mockAnalytics;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis completed successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing document: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _exportAnalytics() async {
    if (_analyticsData == null) return;
    
    try {
      final report = _generateAnalyticsReport();
      final filename = 'analytics_report_${DateTime.now().millisecondsSinceEpoch}.txt';
      await FileService().saveTextAsFile(report, filename);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analytics report exported as $filename'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting report: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _shareAnalytics() async {
    if (_analyticsData == null) return;
    
    try {
      final report = _generateAnalyticsReport();
      await FileService().copyToClipboard(report);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analytics report copied to clipboard'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing analytics: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  String _generateAnalyticsReport() {
    final stats = _analyticsData!['document_stats'] as Map<String, dynamic>;
    final keywords = _analyticsData!['keywords'] as List<dynamic>;
    
    StringBuffer report = StringBuffer();
    report.writeln('KEYWORD ANALYTICS REPORT');
    report.writeln('========================');
    report.writeln('Generated: ${DateTime.now().toString()}');
    report.writeln('Document: ${_selectedFile!.path.split('/').last}');
    report.writeln('');
    
    report.writeln('DOCUMENT STATISTICS');
    report.writeln('-------------------');
    report.writeln('Total Words: ${stats['total_words']}');
    report.writeln('Unique Words: ${stats['unique_words']}');
    report.writeln('Reading Time: ${stats['reading_time']} minutes');
    report.writeln('Complexity Level: ${stats['complexity_level']}');
    report.writeln('');
    
    report.writeln('TOP KEYWORDS');
    report.writeln('------------');
    for (int i = 0; i < keywords.length; i++) {
      final keyword = keywords[i] as Map<String, dynamic>;
      report.writeln('${i + 1}. ${keyword['word']} - ${keyword['frequency']} times (${keyword['percentage']}%)');
    }
    
    return report.toString();
  }
}