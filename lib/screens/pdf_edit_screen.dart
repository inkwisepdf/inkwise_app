import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/pdf_edit_service.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class PDFEditScreen extends StatefulWidget {
  final File pdfFile;
  final int initialPage;

  const PDFEditScreen({
    super.key,
    required this.pdfFile,
    this.initialPage = 1,
  });

  @override
  State<PDFEditScreen> createState() => _PDFEditScreenState();
}

class _PDFEditScreenState extends State<PDFEditScreen> {
  final PDFEditService _editService = PDFEditService();
  final FileService _fileService = FileService();
  final List<TextEdit> _pendingEdits = [];
  final List<Rect> _textAreas = [];

  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isSelectingArea = false;
  int _currentPage = 1;

  Uint8List? _previewImage;
  Rect? _selectedArea;
  Offset? _dragStart;

  final TextEditingController _editTextController = TextEditingController();
  double _fontSize = 12.0;
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _loadTextAreas();
  }

  @override
  void dispose() {
    _editTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _isEditMode ? _buildEditControls() : null,
      floatingActionButton: _buildFloatingActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Edit PDF - Page $_currentPage'),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        IconButton(
          icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
          onPressed: _toggleEditMode,
          tooltip: _isEditMode ? 'View Mode' : 'Edit Mode',
        ),
        if (_isEditMode && _pendingEdits.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _previewEdits,
            tooltip: 'Preview Changes',
          ),
        if (_isEditMode && _pendingEdits.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEdits,
            tooltip: 'Save Changes',
          ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'detect_areas',
              child: Row(
                children: [
                  Icon(Icons.auto_fix_high),
                  SizedBox(width: 8),
                  Text('Detect Text Areas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_edits',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear All Edits'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help),
                  SizedBox(width: 8),
                  Text('How to Edit'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (_isEditMode) _buildInstructions(),
        Expanded(
          child: _buildEditCanvas(),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryBlue.withValues(alpha: 0.1),
      child: Text(
        _isSelectingArea
            ? 'Drag to select text area to edit'
            : 'Tap "Select Area" to choose text to edit, or tap existing highlighted areas',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEditCanvas() {
    return Stack(
      children: [
        // PDF Page Display
        Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _previewImage != null
                ? Image.memory(
              _previewImage!,
              fit: BoxFit.contain,
            )
                : Container(
              width: 400,
              height: 600,
              color: Colors.white,
              child: const Center(
                child: Text('PDF Page Preview'),
              ),
            ),
          ),
        ),

        // Edit Mode Overlay
        if (_isEditMode)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _isSelectingArea ? _onPanStart : null,
              onPanUpdate: _isSelectingArea ? _onPanUpdate : null,
              onPanEnd: _isSelectingArea ? _onPanEnd : null,
              onTapUp: _onTapUp,
              child: Container(
                color: Colors.transparent,
                child: CustomPaint(
                  painter: EditOverlayPainter(
                    textAreas: _textAreas,
                    pendingEdits: _pendingEdits,
                    selectedArea: _selectedArea,
                  ),
                ),
              ),
            ),
          ),

        // Loading Overlay
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildEditControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSelectingArea ? _cancelSelection : _startAreaSelection,
                  icon: Icon(_isSelectingArea ? Icons.close : Icons.crop_free),
                  label: Text(_isSelectingArea ? 'Cancel' : 'Select Area'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSelectingArea
                        ? Colors.red
                        : AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text('Edits: ${_pendingEdits.length}'),
            ],
          ),
          if (_pendingEdits.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Tap an edit to modify, or add new edits by selecting areas',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_previewImage != null)
          FloatingActionButton.small(
            onPressed: _shareEditedPage,
            heroTag: 'share',
            child: const Icon(Icons.share),
          ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          onPressed: _resetView,
          heroTag: 'refresh',
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _isSelectingArea = false;
        _selectedArea = null;
      }
    });
  }

  void _startAreaSelection() {
    setState(() {
      _isSelectingArea = true;
      _selectedArea = null;
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectingArea = false;
      _selectedArea = null;
    });
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart != null) {
      setState(() {
        _selectedArea = Rect.fromPoints(_dragStart!, details.localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedArea != null && _selectedArea!.width > 20 && _selectedArea!.height > 10) {
      _showEditDialog(_selectedArea!);
    }
    setState(() {
      _isSelectingArea = false;
      _selectedArea = null;
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isSelectingArea && _isEditMode) {
      // Check if tapping on existing edit
      final tapPosition = details.localPosition;
      for (int i = 0; i < _pendingEdits.length; i++) {
        if (_pendingEdits[i].area.contains(tapPosition)) {
          _editExistingText(i);
          return;
        }
      }
    }
  }

  void _showEditDialog(Rect area) {
    final estimatedFontSize = _editService.estimateFontSize(area.height);
    setState(() {
      _fontSize = estimatedFontSize;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editTextController,
              decoration: const InputDecoration(
                labelText: 'New Text',
                hintText: 'Enter replacement text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Font Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8.0,
                    max: 24.0,
                    divisions: 16,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Color: '),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _textColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _editTextController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_editTextController.text.isNotEmpty) {
                _addEdit(area, _editTextController.text);
                _editTextController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add Edit'),
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Text Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorOption(Colors.black, 'Black'),
              _buildColorOption(Colors.blue, 'Blue'),
              _buildColorOption(Colors.red, 'Red'),
              _buildColorOption(Colors.green, 'Green'),
              _buildColorOption(Colors.purple, 'Purple'),
              _buildColorOption(Colors.orange, 'Orange'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, String label) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Text(label),
      onTap: () {
        setState(() {
          _textColor = color;
        });
        Navigator.pop(context);
      },
    );
  }

  void _addEdit(Rect area, String newText) {
    final edit = TextEdit(
      area: area,
      newText: newText,
      position: Offset(area.left + 2, area.top + _fontSize),
      fontSize: _fontSize,
      textColor: _textColor,
    );

    setState(() {
      _pendingEdits.add(edit);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added edit: "$newText"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editExistingText(int index) {
    final edit = _pendingEdits[index];
    _editTextController.text = edit.newText;
    _fontSize = edit.fontSize;
    _textColor = edit.textColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editTextController,
              decoration: const InputDecoration(
                labelText: 'Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Font Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8.0,
                    max: 24.0,
                    divisions: 16,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _pendingEdits.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              _editTextController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_editTextController.text.isNotEmpty) {
                setState(() {
                  _pendingEdits[index] = TextEdit(
                    area: edit.area,
                    newText: _editTextController.text,
                    position: edit.position,
                    fontSize: _fontSize,
                    textColor: _textColor,
                  );
                });
                _editTextController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _previewEdits() async {
    if (_pendingEdits.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final previewBytes = await _editService.previewPageEdit(
        sourceFile: widget.pdfFile,
        pageNumber: _currentPage,
        edits: _pendingEdits,
      );

      setState(() {
        _previewImage = previewBytes;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preview updated with edits'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview error: $e')),
        );
      }
    }
  }

  Future<void> _saveEdits() async {
    if (_pendingEdits.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final editedFile = await _editService.editPdfText(
        sourceFile: widget.pdfFile,
        pageNumber: _currentPage,
        edits: _pendingEdits,
        outputFileName: 'edited_${widget.pdfFile.path.split('/').last}',
      );

      setState(() {
        _isLoading = false;
        _pendingEdits.clear();
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text('Edited PDF saved to:\n${editedFile.path}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fileService.shareFile(editedFile);
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e')),
        );
      }
    }
  }

  Future<void> _loadTextAreas() async {
    try {
      final areas = await _editService.detectTextAreas(
        sourceFile: widget.pdfFile,
        pageNumber: _currentPage,
      );

      setState(() {
        _textAreas.clear();
        _textAreas.addAll(areas);
      });
    } catch (e) {
      // Ignore errors for now
    }
  }

  void _resetView() {
    setState(() {
      _previewImage = null;
      _pendingEdits.clear();
      _isEditMode = false;
      _isSelectingArea = false;
      _selectedArea = null;
    });
  }

  Future<void> _shareEditedPage() async {
    if (_previewImage == null) return;

    try {
      // Save preview image as temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/edited_page_$_currentPage.png');
      await tempFile.writeAsBytes(_previewImage!);

      await _fileService.shareFile(tempFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: $e')),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'detect_areas':
        _loadTextAreas();
        break;
      case 'clear_edits':
        setState(() {
          _pendingEdits.clear();
          _previewImage = null;
        });
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Edit PDF Text'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Turn on Edit Mode', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('   â€¢ Tap the edit icon in the top bar'),
              SizedBox(height: 8),
              Text('2. Select Text Area', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('   â€¢ Tap "Select Area" button'),
              Text('   â€¢ Drag to select the text you want to edit'),
              SizedBox(height: 8),
              Text('3. Enter New Text', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('   â€¢ Type your replacement text'),
              Text('   â€¢ Adjust font size and color'),
              Text('   â€¢ Tap "Add Edit"'),
              SizedBox(height: 8),
              Text('4. Preview & Save', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('   â€¢ Tap preview icon to see changes'),
              Text('   â€¢ Tap save icon to create edited PDF'),
              SizedBox(height: 8),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('   â€¢ Tap existing edits to modify them'),
              Text('   â€¢ Use "Clear All Edits" to start over'),
              Text('   â€¢ Share button shares the edited page'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class EditOverlayPainter extends CustomPainter {
  final List<Rect> textAreas;
  final List<TextEdit> pendingEdits;
  final Rect? selectedArea;

  EditOverlayPainter({
    required this.textAreas,
    required this.pendingEdits,
    this.selectedArea,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw detected text areas
    final detectedAreaPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final detectedBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final area in textAreas) {
      canvas.drawRect(area, detectedAreaPaint);
      canvas.drawRect(area, detectedBorderPaint);
    }

    // Draw pending edits
    final editAreaPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final editBorderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final edit in pendingEdits) {
      canvas.drawRect(edit.area, editAreaPaint);
      canvas.drawRect(edit.area, editBorderPaint);
    }

    // Draw current selection
    if (selectedArea != null) {
      final selectionPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final selectionBorderPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeDashArray = [5, 3];

      canvas.drawRect(selectedArea!, selectionPaint);
      canvas.drawRect(selectedArea!, selectionBorderPaint);
    }
  }

  @override
  bool shouldRepaint(EditOverlayPainter oldDelegate) {
    return oldDelegate.textAreas != textAreas ||
        oldDelegate.pendingEdits != pendingEdits ||
        oldDelegate.selectedArea != selectedArea;
  }
}

// Extension to add strokeDashArray to Paint (simplified)
extension PaintExtension on Paint {
  set strokeDashArray(List<double> dashArray) {
    // Note: Flutter doesn't have built-in dash support
    // This is a placeholder for the interface
  }
}