import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';


class VersionHistoryScreen extends StatefulWidget {
  const VersionHistoryScreen({super.key});

  @override
  State<VersionHistoryScreen> createState() => _VersionHistoryScreenState();
}

class _VersionHistoryScreenState extends State<VersionHistoryScreen> {
  File? _selectedFile;
  List<Map<String, dynamic>> _versions = [];
  Map<String, dynamic>? _selectedVersion;
  bool _showDeleted = false;
  String _sortBy = 'date'; // 'date', 'size', 'name'
  String _filterBy = 'all'; // 'all', 'auto', 'manual'

  final Map<String, String> _sortOptions = {
    'date': 'Date Modified',
    'size': 'File Size',
    'name': 'File Name',
  };

  final Map<String, String> _filterOptions = {
    'all': 'All Versions',
    'auto': 'Auto-Saved',
    'manual': 'Manual Saves',
  };

  @override
  void initState() {
    super.initState();
    _loadMockVersions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Version History"),
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
            if (_selectedFile != null) _buildControls(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildVersionList(),
            const SizedBox(height: 24),
            if (_selectedVersion != null) _buildVersionDetails(),
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
              Icons.history,
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
                  "Version History",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Keep snapshots of a PDF before/after edits for offline rollback",
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
                        _selectedVersion = null;
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

  Widget _buildControls() {
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
                "Version Controls",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: _createSnapshot,
                icon: const Icon(Icons.add),
                tooltip: "Create Snapshot",
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: "Sort By",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _sortOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterBy,
                  decoration: InputDecoration(
                    labelText: "Filter By",
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
                      _filterBy = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Show Deleted Versions"),
            subtitle: const Text("Display versions marked for deletion"),
            value: _showDeleted,
            onChanged: (value) {
              setState(() {
                _showDeleted = value;
              });
            },
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionList() {
    final filteredVersions = _getFilteredVersions();
    
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
            "Version History (${filteredVersions.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          if (filteredVersions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No versions found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create your first snapshot to start tracking changes",
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
              itemCount: filteredVersions.length,
              itemBuilder: (context, index) {
                final version = filteredVersions[index];
                final isSelected = _selectedVersion?['id'] == version['id'];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getVersionColor(version['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getVersionIcon(version['type']),
                        color: _getVersionColor(version['type']),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      version['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Created: ${version['date']}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Size: ${version['size']} • Type: ${version['type']}",
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
                        if (version['isCurrent'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Current",
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleVersionAction(value, version),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'restore',
                              child: Row(
                                children: [
                                  Icon(Icons.restore, size: 16),
                                  SizedBox(width: 8),
                                  Text("Restore"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'compare',
                              child: Row(
                                children: [
                                  Icon(Icons.compare, size: 16),
                                  SizedBox(width: 8),
                                  Text("Compare"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'download',
                              child: Row(
                                children: [
                                  Icon(Icons.download, size: 16),
                                  SizedBox(width: 8),
                                  Text("Download"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16),
                                  SizedBox(width: 8),
                                  Text("Delete"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedVersion = version;
                      });
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVersionDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
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
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVersionIcon(_selectedVersion!['type']),
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Version Details",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow("Name", _selectedVersion!['name']),
          _buildDetailRow("Type", _selectedVersion!['type']),
          _buildDetailRow("Created", _selectedVersion!['date']),
          _buildDetailRow("Size", _selectedVersion!['size']),
          _buildDetailRow("Pages", "${_selectedVersion!['pages']}"),
          _buildDetailRow("Description", _selectedVersion!['description']),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleVersionAction('restore', _selectedVersion!),
                  icon: const Icon(Icons.restore),
                  label: const Text("Restore"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    side: BorderSide(color: AppColors.primaryPurple),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleVersionAction('download', _selectedVersion!),
                  icon: const Icon(Icons.download),
                  label: const Text("Download"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadMockVersions() {
    _versions = [
      {
        'id': '1',
        'name': 'Original Document',
        'type': 'original',
        'date': '2024-01-15 10:30 AM',
        'size': '2.4 MB',
        'pages': 12,
        'description': 'Initial version of the document',
        'isCurrent': false,
        'isDeleted': false,
      },
      {
        'id': '2',
        'name': 'Auto-save 1',
        'type': 'auto',
        'date': '2024-01-15 11:45 AM',
        'size': '2.4 MB',
        'pages': 12,
        'description': 'Automatic save after editing',
        'isCurrent': false,
        'isDeleted': false,
      },
      {
        'id': '3',
        'name': 'Manual Save - Review',
        'type': 'manual',
        'date': '2024-01-15 02:15 PM',
        'size': '2.5 MB',
        'pages': 13,
        'description': 'Manual save after adding review comments',
        'isCurrent': false,
        'isDeleted': false,
      },
      {
        'id': '4',
        'name': 'Final Version',
        'type': 'manual',
        'date': '2024-01-15 04:30 PM',
        'size': '2.6 MB',
        'pages': 14,
        'description': 'Final version with all changes applied',
        'isCurrent': true,
        'isDeleted': false,
      },
      {
        'id': '5',
        'name': 'Deleted Version',
        'type': 'manual',
        'date': '2024-01-15 03:00 PM',
        'size': '2.5 MB',
        'pages': 13,
        'description': 'Version marked for deletion',
        'isCurrent': false,
        'isDeleted': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredVersions() {
    var filtered = _versions.where((version) {
      if (!_showDeleted && version['isDeleted']) return false;
      if (_filterBy != 'all' && version['type'] != _filterBy) return false;
      return true;
    }).toList();

    // Sort versions
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b['date'].compareTo(a['date']));
        break;
      case 'size':
        filtered.sort((a, b) => b['size'].compareTo(a['size']));
        break;
      case 'name':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
    }

    return filtered;
  }

  Color _getVersionColor(String type) {
    switch (type) {
      case 'original':
        return AppColors.primaryBlue;
      case 'auto':
        return AppColors.primaryOrange;
      case 'manual':
        return AppColors.primaryGreen;
      default:
        return AppColors.primaryPurple;
    }
  }

  IconData _getVersionIcon(String type) {
    switch (type) {
      case 'original':
        return Icons.description;
      case 'auto':
        return Icons.auto_awesome;
      case 'manual':
        return Icons.save;
      default:
        return Icons.history;
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
          _selectedVersion = null;
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

  void _createSnapshot() {
    // In a real implementation, this would create a snapshot of the current file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Snapshot creation feature coming soon!'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  void _handleVersionAction(String action, Map<String, dynamic> version) {
    switch (action) {
      case 'restore':
        _restoreVersion(version);
        break;
      case 'compare':
        _compareVersion(version);
        break;
      case 'download':
        _downloadVersion(version);
        break;
      case 'delete':
        _deleteVersion(version);
        break;
    }
  }

  void _restoreVersion(Map<String, dynamic> version) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restoring version: ${version['name']}'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _compareVersion(Map<String, dynamic> version) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comparing with version: ${version['name']}'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _downloadVersion(Map<String, dynamic> version) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading version: ${version['name']}'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  void _deleteVersion(Map<String, dynamic> version) {
    setState(() {
      version['isDeleted'] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Version deleted: ${version['name']}'),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }
}
