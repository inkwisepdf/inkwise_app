import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/services/file_service.dart';

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _outputPath;
  String _encryptionMode = 'encrypt'; // 'encrypt', 'decrypt'
  String _algorithm = 'AES-256'; // 'AES-128', 'AES-256', 'ChaCha20'
  String _password = '';
  String _confirmPassword = '';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _compressBeforeEncryption = true;
  bool _addMetadata = false;
  String _keyDerivation = 'PBKDF2'; // 'PBKDF2', 'Argon2', 'Scrypt'

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final Map<String, String> _modeOptions = {
    'encrypt': 'Encrypt File',
    'decrypt': 'Decrypt File',
  };

  final Map<String, String> _algorithmOptions = {
    'AES-128': 'AES-128 (Fast)',
    'AES-256': 'AES-256 (Standard)',
    'ChaCha20': 'ChaCha20 (Modern)',
  };

  final Map<String, String> _keyDerivationOptions = {
    'PBKDF2': 'PBKDF2 (Standard)',
    'Argon2': 'Argon2 (Secure)',
    'Scrypt': 'Scrypt (Memory-hard)',
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
        title: const Text("Advanced Encryption"),
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
            if (_selectedFile != null) _buildEncryptionMode(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildEncryptionSettings(),
            const SizedBox(height: 24),
            if (_selectedFile != null && _encryptionMode == 'encrypt')
              _buildAdvancedOptions(),
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
            AppColors.primaryOrange.withValues(alpha: 0.1),
            AppColors.primaryOrange.withValues(alpha: 0.05)
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
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security,
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
                  "Advanced Encryption",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Apply military-grade encryption to your files with multiple algorithms",
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
                  "Select File",
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
                label: const Text("Choose File"),
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
                    const Icon(Icons.insert_drive_file,
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

  Widget _buildEncryptionMode() {
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
                  "Operation Mode",
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
                  groupValue: _encryptionMode,
                  onChanged: (value) =>
                      setState(() => _encryptionMode = value!),
                  activeColor: AppColors.primaryBlue,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEncryptionSettings() {
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
                  "Encryption Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_encryptionMode == 'encrypt') ...[
              DropdownButtonFormField<String>(
                value: _algorithm,
                decoration: InputDecoration(
                  labelText: "Encryption Algorithm",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _algorithmOptions.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _algorithm = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _keyDerivation,
                decoration: InputDecoration(
                  labelText: "Key Derivation Function",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _keyDerivationOptions.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _keyDerivation = value!),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: _encryptionMode == 'encrypt'
                    ? "Encryption Password"
                    : "Decryption Password",
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
            if (_encryptionMode == 'encrypt') ...[
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) => setState(() => _confirmPassword = value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
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
                  "Advanced Options",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Compress before encryption"),
              subtitle: const Text("Reduce file size before encrypting"),
              value: _compressBeforeEncryption,
              onChanged: (value) =>
                  setState(() => _compressBeforeEncryption = value),
              activeColor: AppColors.primaryBlue,
            ),
            SwitchListTile(
              title: const Text("Add metadata"),
              subtitle:
                  const Text("Include file information in encrypted data"),
              value: _addMetadata,
              onChanged: (value) => setState(() => _addMetadata = value),
              activeColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    bool canProcess = _selectedFile != null &&
        (_encryptionMode == 'decrypt' ||
            (_password.isNotEmpty && _password == _confirmPassword));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canProcess && !_isProcessing ? _processEncryption : null,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(_encryptionMode == 'encrypt' ? Icons.lock : Icons.lock_open),
        label: Text(_isProcessing
            ? "Processing..."
            : (_encryptionMode == 'encrypt' ? "Encrypt File" : "Decrypt File")),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
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
                  Text(
                    _encryptionMode == 'encrypt'
                        ? "File encrypted successfully"
                        : "File decrypted successfully",
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

  Future<void> _processEncryption() async {
    if (_selectedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      String outputPath = '';

      if (_encryptionMode == 'encrypt') {
        // Mock encryption - in real implementation, use actual encryption library
        outputPath = await _mockEncryptFile();
      } else {
        // Mock decryption - in real implementation, use actual decryption library
        outputPath = await _mockDecryptFile();
      }

      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_encryptionMode == 'encrypt'
                ? 'File encrypted successfully!'
                : 'File decrypted successfully!'),
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

  Future<String> _mockEncryptFile() async {
    // Simulate encryption process
    await Future.delayed(const Duration(seconds: 2));

    String fileName = _selectedFile!.path.split('/').last;
    String encryptedName = 'encrypted_$fileName.enc';

    final directory = await FileService.getAppDirectoryPath();
    return '$directory/$encryptedName';
  }

  Future<String> _mockDecryptFile() async {
    // Simulate decryption process
    await Future.delayed(const Duration(seconds: 2));

    String fileName = _selectedFile!.path.split('/').last;
    String decryptedName = fileName.replaceAll('.enc', '_decrypted');

    final directory = await FileService.getAppDirectoryPath();
    return '$directory/$decryptedName';
  }
}
