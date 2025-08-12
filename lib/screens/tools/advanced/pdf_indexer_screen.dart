import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inkwise_pdf/theme.dart';

class PDFIndexerScreen extends StatefulWidget {
  const PDFIndexerScreen({super.key});

  @override
  State<PDFIndexerScreen> createState() => _PDFIndexerScreenState();
}

class _PDFIndexerScreenState extends State<PDFIndexerScreen> {
  bool _isIndexing = false;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _indexedFiles = [];
  List<Map<String, dynamic>> _searchResults = [];
  String _searchFilter = 'all'; // 'all', 'title', 'content', 'tags'
  bool _showAdvancedSearch = false;
  int _totalFiles = 0;
  int _indexedFilesCount = 0;
  double _indexingProgress = 0.0;

  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _filterOptions = {
    'all': 'All Content',
    'title': 'File Names',
    'content': 'Document Content',
    'tags': 'Tags Only',
  };

  @override
  void initState() {
    super.initState();
    _loadMockIndexedFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Indexer"),
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
            _buildIndexingStatus(),
            const SizedBox(height: 24),
            _buildSearchSection(),
            const SizedBox(height: 24),
            if (_searchResults.isNotEmpty) _buildSearchResults(),
            const SizedBox(height: 24),
            _buildIndexedFilesList(),
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
            AppColors.primaryBlue.withValues(alpha: 0.1),
            AppColors.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search,
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
                  "PDF Indexer",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Local document indexing and instant search across all files",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexingStatus() {
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
                "Indexing Status",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (!_isIndexing)
                ElevatedButton.icon(
                  onPressed: _startIndexing,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reindex"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Files",
                  "$_totalFiles",
                  Icons.folder,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Indexed",
                  "$_indexedFilesCount",
                  Icons.check_circle,
                  AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Progress",
                  "${(_indexingProgress * 100).toInt()}%",
                  Icons.pie_chart,
                  AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          
          if (_isIndexing) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _indexingProgress,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            const Text(
              "Indexing files... Please wait",
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
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
            "Search Documents",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search in indexed documents",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (_) => _performSearch(),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _searchFilter,
                  decoration: InputDecoration(
                    labelText: "Search Filter",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _filterOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _searchFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _performSearch,
                icon: _isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isSearching ? "Searching..." : "Search"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Advanced Search"),
            subtitle: const Text("Show additional search options"),
            value: _showAdvancedSearch,
            onChanged: (value) {
              setState(() {
                _showAdvancedSearch = value;
              });
            },
            activeColor: AppColors.primaryBlue,
          ),
          
          if (_showAdvancedSearch) ...[
            const SizedBox(height: 16),
            _buildAdvancedSearchOptions(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSearchOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Advanced Search Options",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text("Case Sensitive"),
                  value: false,
                  onChanged: (value) {},
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text("Whole Words"),
                  value: false,
                  onChanged: (value) {},
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text("Include Tags"),
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text("Include Metadata"),
                  value: false,
                  onChanged: (value) {},
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
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
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Search Results (${_searchResults.length})",
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
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    result['name'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['path'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (result['snippet'] != null)
                        Text(
                          result['snippet'],
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        result['size'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _openFile(result),
                        icon: const Icon(Icons.open_in_new, size: 20),
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

  Widget _buildIndexedFilesList() {
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
            "Indexed Files (${_indexedFiles.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          if (_indexedFiles.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No indexed files",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start indexing to enable search functionality",
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
              itemCount: _indexedFiles.length,
              itemBuilder: (context, index) {
                final file = _indexedFiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: AppColors.primaryBlue,
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
                        Text(
                          "Indexed: ${file['indexedDate']} • Pages: ${file['pages']}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
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
                          onSelected: (value) => _handleFileAction(value, file),
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
                              value: 'reindex',
                              child: Row(
                                children: [
                                  Icon(Icons.refresh, size: 16),
                                  SizedBox(width: 8),
                                  Text("Reindex"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle, size: 16),
                                  SizedBox(width: 8),
                                  Text("Remove from Index"),
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

  void _loadMockIndexedFiles() {
    _indexedFiles = [
      {
        'id': '1',
        'name': 'Business Report 2024.pdf',
        'path': '/Documents/Business/',
        'size': '2.4 MB',
        'pages': 15,
        'indexedDate': '2024-01-15',
        'tags': ['business', 'report', '2024'],
      },
      {
        'id': '2',
        'name': 'Technical Documentation.pdf',
        'path': '/Documents/Technical/',
        'size': '5.2 MB',
        'pages': 42,
        'indexedDate': '2024-01-14',
        'tags': ['technical', 'documentation', 'guide'],
      },
      {
        'id': '3',
        'name': 'Meeting Notes.pdf',
        'path': '/Documents/Meetings/',
        'size': '1.8 MB',
        'pages': 8,
        'indexedDate': '2024-01-13',
        'tags': ['meeting', 'notes', 'minutes'],
      },
      {
        'id': '4',
        'name': 'Project Proposal.pdf',
        'path': '/Documents/Projects/',
        'size': '3.1 MB',
        'pages': 25,
        'indexedDate': '2024-01-12',
        'tags': ['project', 'proposal', 'planning'],
      },
    ];
    
    _totalFiles = 4;
    _indexedFilesCount = 4;
    _indexingProgress = 1.0;
  }

  Future<void> _startIndexing() async {
    setState(() {
      _isIndexing = true;
      _indexingProgress = 0.0;
    });

    // Simulate indexing process
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _indexingProgress = i / 100;
      });
    }

    setState(() {
      _isIndexing = false;
      _indexingProgress = 1.0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Indexing completed! $_totalFiles files indexed.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Simulate search process
    await Future.delayed(const Duration(seconds: 1));

    // Mock search results
    _searchResults = _indexedFiles.where((file) {
      return file['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             file['tags'].any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).map((file) {
      return {
        ...file,
        'snippet': 'Found "$_searchQuery" in ${file['name']}',
      };
    }).toList();

    setState(() {
      _isSearching = false;
    });

    if (_searchResults.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No results found for "$_searchQuery"'),
            backgroundColor: AppColors.primaryOrange,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults.clear();
    });
  }

  void _openFile(Map<String, dynamic> file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening file: ${file['name']}'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _handleFileAction(String action, Map<String, dynamic> file) {
    switch (action) {
      case 'open':
        _openFile(file);
        break;
      case 'reindex':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reindexing file: ${file['name']}'),
            backgroundColor: AppColors.primaryOrange,
          ),
        );
        break;
      case 'remove':
        setState(() {
          _indexedFiles.removeWhere((f) => f['id'] == file['id']);
          _indexedFilesCount = _indexedFiles.length;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from index: ${file['name']}'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        break;
    }
  }
}
