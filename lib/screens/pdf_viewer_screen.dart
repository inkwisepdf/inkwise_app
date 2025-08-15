import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/file_service.dart';
import 'package:inkwise_pdf/services/pdf_text_service.dart';
import 'package:inkwise_pdf/screens/pdf_edit_screen.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  File? _pdfFile;
  PdfControllerPinch? _pdfController;
  PdfDocument? _pdfDocument;
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _showThumbnails = false;
  bool _showBookmarks = false;
  bool _isDarkMode = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  
  // Search functionality
  List<TextSearchResult> _searchResults = [];
  int _currentSearchIndex = -1;
  bool _isSearching = false;
  
  // Text selection
  String? _selectedText;
  
  // Text service
  final PDFTextService _textService = PDFTextService();
  
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
    _pdfController?.dispose();
    _pdfDocument?.close();
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
                value: 'copy_page_text',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy Page Text'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_all_text',
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 8),
                    Text('Copy All Text'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit_text',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Text'),
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
              if (_pdfController != null)
                PdfViewPinch(
                  controller: _pdfController!,
                  onDocumentLoaded: (document) {
                    setState(() {
                      _totalPages = document.pagesCount;
                      _isLoading = false;
                      _pageController.text = _currentPage.toString();
                    });
                  },
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                      _pageController.text = _currentPage.toString();
                    });
                  },
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    documentLoaderBuilder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    pageLoaderBuilder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              // Search results overlay
              if (_searchResults.isNotEmpty) _buildSearchOverlay(),
              // Text selection overlay
              if (_selectedText != null) _buildTextSelectionOverlay(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                _currentSearchIndex >= 0 
                  ? '${_currentSearchIndex + 1} of ${_searchResults.length} matches - Page ${_searchResults[_currentSearchIndex].pageNumber}'
                  : '${_searchResults.length} matches found',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: _currentSearchIndex > 0 ? _previousSearchResult : null,
              icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ),
            IconButton(
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: _currentSearchIndex < _searchResults.length - 1 
                ? _nextSearchResult : null,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
            IconButton(
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: _clearSearch,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSelectionOverlay() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedText!.length > 100 
                  ? '${_selectedText!.substring(0, 100)}...'
                  : _selectedText!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _copySelectedText,
              icon: const Icon(Icons.copy, color: Colors.white),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedText = null),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
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
                  onTap: () => _goToPage(index + 1),
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
                  onTap: () => _goToPage(1),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Chapter 1'),
                  subtitle: const Text('Page 5'),
                  onTap: () => _goToPage(5),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Chapter 2'),
                  subtitle: const Text('Page 12'),
                  onTap: () => _goToPage(12),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Conclusion'),
                  subtitle: const Text('Page 25'),
                  onTap: () => _goToPage(25),
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
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 16),
          if (_pdfController != null)
            IconButton(
              onPressed: () {
                // Simple zoom out implementation
                setState(() {
                  // Zoom functionality will be implemented when the correct API is confirmed
                });
              },
              icon: const Icon(Icons.zoom_out),
            ),
          if (_pdfController != null)
            IconButton(
              onPressed: () {
                // Simple zoom in implementation
                setState(() {
                  // Zoom functionality will be implemented when the correct API is confirmed
                });
              },
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
      _initializePdfController();
    }
  }

  Future<void> _initializePdfController() async {
    if (_pdfFile == null) return;

    try {
      _pdfDocument = await PdfDocument.openFile(_pdfFile!.path);
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(_pdfFile!.path),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
      setState(() {
        _isLoading = false;
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
          _searchResults.clear();
          _currentSearchIndex = -1;
          _selectedText = null;
        });
        
        _pdfController?.dispose();
        _pdfDocument?.close();
        await _initializePdfController();
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
    if (_pdfController != null && page >= 1 && page <= _totalPages) {
      _pdfController!.animateToPage(
        pageNumber: page,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search text',
                hintText: 'Enter text to search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _searchText = value,
              autofocus: true,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context);
                  _performSearch(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search will find matches across all pages',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSearching ? null : () {
              if (_searchText.isNotEmpty) {
                Navigator.pop(context);
                _performSearch(_searchText);
              }
            },
            child: _isSearching 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String searchTerm) async {
    if (_pdfFile == null) return;

    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _currentSearchIndex = -1;
    });

    try {
      // Use the text service to search for the term
      final results = await _textService.searchText(_pdfFile!, searchTerm);
      
      setState(() {
        _searchResults = results;
      });

      if (_searchResults.isNotEmpty) {
        _currentSearchIndex = 0;
        _goToSearchResult(_currentSearchIndex);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${_searchResults.length} matches for "$searchTerm"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No results found for "$searchTerm"')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }

    setState(() {
      _isSearching = false;
    });
  }

  void _goToSearchResult(int index) {
    if (index >= 0 && index < _searchResults.length) {
      final result = _searchResults[index];
      _goToPage(result.pageNumber);
      setState(() {
        _currentSearchIndex = index;
      });
    }
  }

  void _nextSearchResult() {
    if (_currentSearchIndex < _searchResults.length - 1) {
      _goToSearchResult(_currentSearchIndex + 1);
    }
  }

  void _previousSearchResult() {
    if (_currentSearchIndex > 0) {
      _goToSearchResult(_currentSearchIndex - 1);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchResults.clear();
      _currentSearchIndex = -1;
      _searchText = '';
    });
    _searchController.clear();
  }

  Future<void> _extractAndSelectText(int pageNumber) async {
    if (_pdfFile == null) return;

    try {
      setState(() {
        _isLoading = true;
      });
      
      // Extract text from the current page
      final pageText = await _textService.extractPageText(_pdfFile!, pageNumber);
      
      setState(() {
        _selectedText = pageText.isNotEmpty 
          ? pageText 
          : 'No text found on page $pageNumber';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pageText.isNotEmpty 
              ? 'Text extracted from page $pageNumber' 
              : 'No text found on page $pageNumber'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting text: $e')),
        );
      }
    }
  }

  void _copySelectedText() {
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _selectedText!));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedText!.length} characters copied to clipboard'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Copy all text from PDF
  Future<void> _copyAllText() async {
    if (_pdfFile == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final allText = await _textService.extractAllText(_pdfFile!);
      
      await Clipboard.setData(ClipboardData(text: allText));
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All PDF text (${allText.length} characters) copied to clipboard'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error copying text: $e')),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        FileService.shareFile(_pdfFile!);
        break;
      case 'info':
        _showFileInfo();
        break;
      case 'copy_page_text':
        _extractAndSelectText(_currentPage);
        break;
      case 'copy_all_text':
        _copyAllText();
        break;
      case 'edit_text':
        _openEditMode();
        break;
    }
  }

  void _openEditMode() {
    if (_pdfFile == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFEditScreen(
          pdfFile: _pdfFile!,
          initialPage: _currentPage,
        ),
      ),
    );
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
}
