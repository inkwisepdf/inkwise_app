import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:inkwise_pdf/theme.dart';


class SecureVaultScreen extends StatefulWidget {
  const SecureVaultScreen({super.key});

  @override
  State<SecureVaultScreen> createState() => _SecureVaultScreenState();
}

class _SecureVaultScreenState extends State<SecureVaultScreen> {
  bool _isUnlocked = false;
  String _masterPassword = '';
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  List<Map<String, dynamic>> _vaultFiles = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadVaultFiles();
  }

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
        title: const Text("Secure Vault"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (_isUnlocked)
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: _lockVault,
              tooltip: "Lock Vault",
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (!_isUnlocked) _buildUnlockSection(),
            if (_isUnlocked) ...[
              _buildVaultStats(),
              const SizedBox(height: 24),
              _buildAddFileSection(),
              const SizedBox(height: 24),
              _buildVaultFiles(),
            ],
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
            AppColors.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
                  border: Border.all(
            color: AppColors.primaryRed.withValues(alpha: 0.2),
            width: 1,
          ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isUnlocked ? Icons.lock_open : Icons.lock,
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
                  _isUnlocked ? "Secure Vault (Unlocked)" : "Secure Vault (Locked)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isUnlocked 
                      ? "Your files are securely encrypted and protected"
                      : "Enter master password to access your secure files",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockSection() {
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
            "Unlock Vault",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: "Master Password",
              hintText: "Enter your master password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _unlockVault,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.lock_open),
              label: Text(_isProcessing ? "Unlocking..." : "Unlock Vault"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: AppColors.primaryRed,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Your master password is used to encrypt/decrypt all files in the vault. Keep it safe and never share it.",
                    style: TextStyle(
                      color: AppColors.primaryRed,
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

  Widget _buildVaultStats() {
    final totalSize = _vaultFiles.fold<double>(0, (sum, file) => sum + (file['size'] ?? 0));
    final totalFiles = _vaultFiles.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.folder,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  totalFiles.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Files",
                  style: TextStyle(
                    color: AppColors.primaryGreen.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.storage,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  "${(totalSize / 1024 / 1024).toStringAsFixed(1)} MB",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Total Size",
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
    );
  }

  Widget _buildAddFileSection() {
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
            "Add Files to Vault",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addFileToVault,
                  icon: const Icon(Icons.add),
                  label: const Text("Add File"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addMultipleFilesToVault,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Add Multiple"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaultFiles() {
    if (_vaultFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.primaryRed,
            ),
            const SizedBox(height: 16),
            Text(
              "No Files in Vault",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add files to your secure vault to keep them encrypted and protected",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Vault Files (${_vaultFiles.length})",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vaultFiles.length,
            itemBuilder: (context, index) {
              final file = _vaultFiles[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: AppColors.primaryRed,
                    size: 20,
                  ),
                ),
                title: Text(
                  file['name'] ?? 'Unknown File',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "${(file['size'] / 1024 / 1024).toStringAsFixed(2)} MB • Added ${file['date']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleFileAction(value, index),
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
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 16),
                          SizedBox(width: 8),
                          Text("Share"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16),
                          SizedBox(width: 8),
                          Text("Remove from Vault"),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadVaultFiles() async {
    // Simulate loading vault files
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _vaultFiles = [
        {
          'name': 'confidential_report.pdf',
          'size': 2.5 * 1024 * 1024, // 2.5 MB
          'date': '2024-01-15',
          'path': '/vault/confidential_report.pdf',
        },
        {
          'name': 'financial_data.xlsx',
          'size': 1.8 * 1024 * 1024, // 1.8 MB
          'date': '2024-01-10',
          'path': '/vault/financial_data.xlsx',
        },
        {
          'name': 'contract_draft.docx',
          'size': 0.9 * 1024 * 1024, // 0.9 MB
          'date': '2024-01-08',
          'path': '/vault/contract_draft.docx',
        },
      ];
    });
  }

  Future<void> _unlockVault() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your master password'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate vault unlocking
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would verify the password against stored hash
      if (_passwordController.text == 'vault123') { // Demo password
        setState(() {
          _isUnlocked = true;
          _masterPassword = _passwordController.text;
          _isProcessing = false;
        });
        
        _passwordController.clear();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vault unlocked successfully!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } else {
        throw Exception('Incorrect master password');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlock vault: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  void _lockVault() {
    setState(() {
      _isUnlocked = false;
      _masterPassword = '';
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vault locked'),
          backgroundColor: AppColors.primaryOrange,
        ),
      );
    }
  }

  Future<void> _addFileToVault() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        await _encryptAndAddFile(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding file: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _addMultipleFilesToVault() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.path != null) {
            await _encryptAndAddFile(File(file.path!));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding files: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _encryptAndAddFile(File file) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate file encryption
      await Future.delayed(const Duration(seconds: 1));
      
      final newFile = {
        'name': file.path.split('/').last,
        'size': await file.length(),
        'date': DateTime.now().toString().split(' ')[0],
        'path': '/vault/${file.path.split('/').last}',
      };
      
      setState(() {
        _vaultFiles.add(newFile);
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newFile['name']} added to vault'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error encrypting file: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _handleFileAction(String action, int index) async {
    final file = _vaultFiles[index];
    
    try {
      switch (action) {
        case 'open':
          // Simulate opening encrypted file
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${file['name']}...'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
          break;
          
        case 'share':
          // Simulate sharing encrypted file
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${file['name']}...'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          break;
          
        case 'remove':
          // Remove file from vault
          setState(() {
            _vaultFiles.removeAt(index);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${file['name']} removed from vault'),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }
}
