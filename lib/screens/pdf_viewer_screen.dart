import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  File? _pdfFile;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 0;
  double _zoomLevel = 1.0;
  bool _showThumbnails = false;
  bool _showBookmarks = false;
  bool _isDarkMode = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdfFromArguments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pdfFile != null ? _buildPdfViewer() : _buildFileSelector(),
      bottomNavigationBar: _pdfFile != null ? _buildBottomBar() : null,
      floatingActionButton: _pdfFile != null ? _buildFloatingActions() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_pdfFile?.path.split('/').last ?? 'PDF Viewer'),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        if (_pdfFile != null) ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => setState(() => _showBookmarks = !_showBookmarks),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => setState(() => _showThumbnails = !_showThumbnails),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('File Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Print'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFileSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No PDF Selected",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select a PDF file to view and edit",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _pickPdfFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Select PDF File"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Row(
      children: [
        if (_showThumbnails) _buildThumbnailsPanel(),
        if (_showBookmarks) _buildBookmarksPanel(),
        Expanded(
          child: Stack(
            children: [
              SfPdfViewer.file(
                _pdfFile!,
                key: _pdfViewerKey,
                enableDoubleTapZooming: true,
                enableTextSelection: true,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    _totalPages = details.document.pages.count;
                    _isLoading = false;
                  });
                },
                onPageChanged: (PdfPageChangedDetails details) {
                  setState(() {
                    _currentPage = details.newPageNumber;
                    _pageController.text = _currentPage.toString();
                  });
                },
                onZoomLevelChanged: (PdfZoomDetails details) {
                  setState(() {
                    _zoomLevel = details.newZoomLevel;
                  });
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailsPanel() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  "Thumbnails",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showThumbnails = false),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  title: Text('Page ${index + 1}'),
                  selected: _currentPage == index + 1,
                  onTap: () {
                    setState(() {
                      _currentPage = index + 1;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksPanel() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  "Bookmarks",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showBookmarks = false),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Introduction'),
                  subtitle: const Text('Page 1'),
                  onTap: () => setState(() => _currentPage = 1),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Chapter 1'),
                  subtitle: const Text('Page 5'),
                  onTap: () => setState(() => _currentPage = 5),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Chapter 2'),
                  subtitle: const Text('Page 12'),
                  onTap: () => setState(() => _currentPage = 12),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Conclusion'),
                  subtitle: const Text('Page 25'),
                  onTap: () => setState(() => _currentPage = 25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _pageController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    onSubmitted: (value) {
                      int? page = int.tryParse(value);
                      if (page != null && page >= 1 && page <= _totalPages) {
                        _goToPage(page);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'of $_totalPages',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 16),
          Text(
            '${(_zoomLevel * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => setState(
                () => _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 3.0)),
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () => setState(
                () => _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 3.0)),
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          onPressed: _showSearchDialog,
          heroTag: 'search',
          child: const Icon(Icons.search),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          onPressed: () => FileService.shareFile(_pdfFile!),
          heroTag: 'share',
          child: const Icon(Icons.share),
        ),
      ],
    );
  }

  void _loadPdfFromArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      setState(() {
        _pdfFile = File(arguments);
        _isLoading = true;
      });
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
          _isLoading = true;
          _currentPage = 1;
          _totalPages = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search PDF'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search text',
            hintText: 'Enter text to search',
          ),
          onChanged: (value) => _searchText = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_searchText.isNotEmpty) {
                // Search functionality will be implemented in a future update
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Searching for: $_searchText')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        FileService.shareFile(_pdfFile!);
        break;
      case 'info':
        _showFileInfo();
        break;
      case 'print':
        _showPrintDialog();
        break;
    }
  }

  void _showFileInfo() {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String>(
        future: FileService.getFileSize(_pdfFile!),
        builder: (context, snapshot) {
          return AlertDialog(
            title: const Text('File Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${_pdfFile!.path.split('/').last}'),
                Text('Size: ${snapshot.data ?? 'Loading...'}'),
                Text('Pages: $_totalPages'),
                Text('Path: ${_pdfFile!.path}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print PDF'),
        content: const Text(
            'Print functionality will be implemented in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
