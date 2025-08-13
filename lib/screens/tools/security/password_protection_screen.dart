import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/file_service.dart';
import 'package:inkwise_pdf/services/pdf_service.dart';

class PasswordProtectionScreen extends StatefulWidget {
  const PasswordProtectionScreen({super.key});

  @override
  State<PasswordProtectionScreen> createState() =>
      _PasswordProtectionScreenState();
}

class _PasswordProtectionScreenState extends State<PasswordProtectionScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  String _protectionMode = 'add'; // 'add', 'remove', 'change'
  String _password = '';
  String _confirmPassword = '';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _requirePasswordToOpen = true;
  bool _requirePasswordToEdit = false;
  bool _allowPrinting = true;
  bool _allowCopying = true;
  String _encryptionLevel = '128'; // '40', '128', '256'

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final Map<String, String> _modeOptions = {
    'add': 'Add Password Protection',
    'remove': 'Remove Password Protection',
    'change': 'Change Password',
  };

  final Map<String, String> _encryptionOptions = {
    '40': '40-bit (Basic)',
    '128': '128-bit (Standard)',
    '256': '256-bit (High Security)',
  };

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Protection"),
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
            if (_selectedFile != null) _buildProtectionMode(),
            const SizedBox(height: 24),
            if (_selectedFile != null && _protectionMode != 'remove')
              _buildPasswordSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null && _protectionMode != 'remove')
              _buildSecurityOptions(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildProcessButton(),
            const SizedBox(height: 24),
            if (_outputPath != null) _buildResult(),
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
            AppColors.primaryRed.withValues(alpha: 0.1),
            AppColors.primaryRed.withValues(alpha: 0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock,
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
                  "Password Protection",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Secure your PDF documents with password protection and encryption",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_present, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  "Select PDF File",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedFile == null)
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text("Choose PDF File"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile!.path.split('/').last,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          FutureBuilder<String>(
                            future: FileService.getFileSize(_selectedFile!),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Loading...',
                                style: const TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedFile = null),
                      icon: const Icon(Icons.close),
                      color: AppColors.primaryRed,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionMode() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: AppColors.primaryBlue),
                SizedBox(width: 12),
                Text(
                  "Protection Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._modeOptions.entries.map((entry) => RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _protectionMode,
                  onChanged: (value) =>
                      setState(() => _protectionMode = value!),
                  activeColor: AppColors.primaryBlue,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.key, color: AppColors.primaryBlue),
                SizedBox(width: 12),
                Text(
                  "Password Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter password",
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => setState(() => _password = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Confirm password",
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => setState(() => _confirmPassword = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _encryptionLevel,
              decoration: InputDecoration(
                labelText: "Encryption Level",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _encryptionOptions.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _encryptionLevel = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: AppColors.primaryBlue),
                SizedBox(width: 12),
                Text(
                  "Security Options",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Require password to open"),
              subtitle:
                  const Text("Users must enter password to view the document"),
              value: _requirePasswordToOpen,
              onChanged: (value) =>
                  setState(() => _requirePasswordToOpen = value),
              activeColor: AppColors.primaryBlue,
            ),
            SwitchListTile(
              title: const Text("Require password to edit"),
              subtitle: const Text(
                  "Users must enter password to modify the document"),
              value: _requirePasswordToEdit,
              onChanged: (value) =>
                  setState(() => _requirePasswordToEdit = value),
              activeColor: AppColors.primaryBlue,
            ),
            SwitchListTile(
              title: const Text("Allow printing"),
              subtitle: const Text("Users can print the document"),
              value: _allowPrinting,
              onChanged: (value) => setState(() => _allowPrinting = value),
              activeColor: AppColors.primaryBlue,
            ),
            SwitchListTile(
              title: const Text("Allow copying"),
              subtitle: const Text("Users can copy text and images"),
              value: _allowCopying,
              onChanged: (value) => setState(() => _allowCopying = value),
              activeColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    bool canProcess = _selectedFile != null &&
        (_protectionMode == 'remove' ||
            (_password.isNotEmpty && _password == _confirmPassword));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            canProcess && !_isProcessing ? _processPasswordProtection : null,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.lock),
        label:
            Text(_isProcessing ? "Processing..." : "Apply Password Protection"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryGreen),
                SizedBox(width: 12),
                Text(
                  "Success!",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Protected PDF saved successfully",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _outputPath!,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
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
                    onPressed: () => FileService.openFile(File(_outputPath!)),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("Open File"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => FileService.shareFile(File(_outputPath!)),
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
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
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _outputPath = null;
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

  Future<void> _processPasswordProtection() async {
    if (_selectedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      String outputPath = '';

      final pdfService = PDFService();

      switch (_protectionMode) {
        case 'add':
          final outputFile =
              await pdfService.addPassword(_selectedFile!, _password);
          outputPath = outputFile.path;
          break;
        case 'remove':
          final outputFile =
              await pdfService.removePassword(_selectedFile!, _password);
          outputPath = outputFile.path;
          break;
        case 'change':
          final outputFile =
              await pdfService.addPassword(_selectedFile!, _password);
          outputPath = outputFile.path;
          break;
      }

      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password protection applied successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }
}
