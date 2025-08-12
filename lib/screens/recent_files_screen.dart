import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';
import '../theme.dart';
import '../services/file_service.dart';

class RecentFilesScreen extends StatefulWidget {
  const RecentFilesScreen({super.key});

  @override
  State<RecentFilesScreen> createState() => _RecentFilesScreenState();
}

class _RecentFilesScreenState extends State<RecentFilesScreen> {
  List<Map<String, dynamic>> _recentFiles = [];
  List<Map<String, dynamic>> _filteredFiles = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'name', 'size', 'type'
  String _filterBy = 'all'; // 'all', 'pdf', 'images', 'documents'
  bool _showGrid = true;
  bool _showFavorites = false;

  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _sortOptions = {
    'date': 'Date Modified',
    'name': 'File Name',
    'size': 'File Size',
    'type': 'File Type',
  };

  final Map<String, String> _filterOptions = {
    'all': 'All Files',
    'pdf': 'PDF Files',
    'images': 'Image Files',
    'documents': 'Document Files',
  };

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
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
        title: const Text("Recent Files"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Sort By'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentFiles.isEmpty
                    ? _buildEmptyState()
                    : _buildFileList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFiles,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search recent files',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterFiles();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterFiles();
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _filterBy == 'all',
              onSelected: (selected) {
                setState(() {
                  _filterBy = 'all';
                  _filterFiles();
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('PDF'),
              selected: _filterBy == 'pdf',
              onSelected: (selected) {
                setState(() {
                  _filterBy = 'pdf';
                  _filterFiles();
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Images'),
              selected: _filterBy == 'images',
              onSelected: (selected) {
                setState(() {
                  _filterBy = 'images';
                  _filterFiles();
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Documents'),
              selected: _filterBy == 'documents',
              onSelected: (selected) {
                setState(() {
                  _filterBy = 'documents';
                  _filterFiles();
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Favorites'),
              selected: _showFavorites,
              onSelected: (selected) {
                setState(() {
                  _showFavorites = selected;
                  _filterFiles();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Recent Files",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your recently opened files will appear here",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addFiles,
            icon: const Icon(Icons.add),
            label: const Text("Add Files"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    if (_showGrid) {
      return StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          final file = _filteredFiles[index];
          return _buildFileCard(file);
        },
        staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          final file = _filteredFiles[index];
          return _buildFileListItem(file);
        },
      );
    }
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openFile(file),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getFileTypeColor(file['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileTypeIcon(file['type']),
                      color: _getFileTypeColor(file['type']),
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  if (file['isFavorite'] == true)
                    Icon(
                      Icons.favorite,
                      color: AppColors.primaryRed,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                file['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                file['size'],
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                file['date'],
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileListItem(Map<String, dynamic> file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getFileTypeColor(file['type']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileTypeIcon(file['type']),
            color: _getFileTypeColor(file['type']),
          ),
        ),
        title: Text(
          file['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file['size']),
            Text(file['date']),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file['isFavorite'] == true)
              Icon(
                Icons.favorite,
                color: AppColors.primaryRed,
                size: 20,
              ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleFileAction(value, file),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new),
                      SizedBox(width: 8),
                      Text('Open'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border),
                      SizedBox(width: 8),
                      Text('Toggle Favorite'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Remove from Recent'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _openFile(file),
      ),
    );
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return AppColors.primaryRed;
      case 'image':
        return AppColors.primaryGreen;
      case 'document':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryPurple;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _loadRecentFiles() {
    setState(() => _isLoading = true);
    
    // Simulate loading recent files
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _recentFiles = [
          {
            'name': 'document.pdf',
            'path': '/path/to/document.pdf',
            'type': 'pdf',
            'size': '2.5 MB',
            'date': '2 hours ago',
            'isFavorite': true,
          },
          {
            'name': 'presentation.pdf',
            'path': '/path/to/presentation.pdf',
            'type': 'pdf',
            'size': '1.8 MB',
            'date': '1 day ago',
            'isFavorite': false,
          },
          {
            'name': 'image.jpg',
            'path': '/path/to/image.jpg',
            'type': 'image',
            'size': '3.2 MB',
            'date': '3 days ago',
            'isFavorite': true,
          },
          {
            'name': 'report.docx',
            'path': '/path/to/report.docx',
            'type': 'document',
            'size': '1.1 MB',
            'date': '1 week ago',
            'isFavorite': false,
          },
          {
            'name': 'contract.pdf',
            'path': '/path/to/contract.pdf',
            'type': 'pdf',
            'size': '4.7 MB',
            'date': '2 weeks ago',
            'isFavorite': true,
          },
        ];
        _filterFiles();
        _isLoading = false;
      });
    });
  }

  void _filterFiles() {
    _filteredFiles = _recentFiles.where((file) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!file['name'].toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Type filter
      if (_filterBy != 'all') {
        if (file['type'] != _filterBy) {
          return false;
        }
      }

      // Favorites filter
      if (_showFavorites && file['isFavorite'] != true) {
        return false;
      }

      return true;
    }).toList();

    // Sort files
    _sortFiles();
  }

  void _sortFiles() {
    switch (_sortBy) {
      case 'date':
        _filteredFiles.sort((a, b) => b['date'].compareTo(a['date']));
        break;
      case 'name':
        _filteredFiles.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'size':
        _filteredFiles.sort((a, b) => b['size'].compareTo(a['size']));
        break;
      case 'type':
        _filteredFiles.sort((a, b) => a['type'].compareTo(b['type']));
        break;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort':
        _showSortDialog();
        break;
      case 'filter':
        _showFilterDialog();
        break;
      case 'refresh':
        _loadRecentFiles();
        break;
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
                _sortFiles();
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: _filterBy,
            onChanged: (value) {
              setState(() {
                _filterBy = value!;
                _filterFiles();
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _addFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null) {
        // Add new files to recent files list
        for (var file in result.files) {
          if (file.path != null) {
            final newFile = {
              'name': file.name,
              'path': file.path!,
              'type': _getFileType(file.name),
              'size': FileService.getFileSize(file.path!),
              'date': 'Just now',
              'isFavorite': false,
            };
            _recentFiles.insert(0, newFile);
          }
        }
        setState(() {
          _filterFiles();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding files: $e')),
      );
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return 'image';
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return 'document';
      default:
        return 'other';
    }
  }

  void _openFile(Map<String, dynamic> file) {
    try {
      FileService.openFile(file['path']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  void _handleFileAction(String action, Map<String, dynamic> file) {
    switch (action) {
      case 'open':
        _openFile(file);
        break;
      case 'share':
        FileService.shareFile(file['path']);
        break;
      case 'favorite':
        setState(() {
          file['isFavorite'] = !(file['isFavorite'] ?? false);
          _filterFiles();
        });
        break;
      case 'delete':
        setState(() {
          _recentFiles.remove(file);
          _filterFiles();
        });
        break;
    }
  }
}

