// lib/screens/upload_screen.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ebook_provider.dart';
import '../theme/app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController  = TextEditingController();
  final _authorController = TextEditingController();
  final _descController   = TextEditingController();

  File? _selectedFile;
  File? _selectedCover;
  String? _selectedFileName;
  String? _selectedCoverName;
  bool  _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Add New Book'),
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<EbookProvider>(
        builder: (_, provider, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilePicker(),
                  const SizedBox(height: 24),
                  _buildMetadataFields(),
                  const SizedBox(height: 24),
                  _buildCoverPicker(),
                  const SizedBox(height: 32),
                  // Upload progress
                  if (provider.isUploading) ...[
                    const Text(
                      'Uploading...',
                      style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:           provider.uploadProgress,
                        color:           AppTheme.primary,
                        backgroundColor: AppTheme.surfaceVariant,
                        minHeight:       6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.primary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Upload button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isUploading ? null : _upload,
                      child: provider.isUploading
                          ? const SizedBox(
                              height: 20,
                              width:  20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('Upload Book'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── File Picker ───────────────────────────────────────────────────────────

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ebook File *',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 13, color: AppTheme.onSurface),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:        AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(
                color: _selectedFile != null ? AppTheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: _selectedFile != null
                ? Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: AppTheme.primary, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName ?? '',
                              style: const TextStyle(
                                fontFamily:  'Georgia',
                                color:       AppTheme.onBackground,
                                fontWeight:  FontWeight.bold,
                                fontSize:    13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getFileSize(_selectedFile!),
                              style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon:      const Icon(Icons.close, color: AppTheme.onSurface, size: 18),
                        onPressed: () => setState(() { _selectedFile = null; _selectedFileName = null; }),
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      Icon(Icons.upload_file, color: AppTheme.primary, size: 48),
                      SizedBox(height: 10),
                      Text(
                        'Tap to select PDF or EPUB',
                        style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Maximum 50MB',
                        style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Metadata Fields ───────────────────────────────────────────────────────

  Widget _buildMetadataFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book Details',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onBackground),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText:   'Title *',
            hintText:    'Enter book title',
            prefixIcon:  Icon(Icons.title),
          ),
          style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground),
          validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _authorController,
          decoration: const InputDecoration(
            labelText:  'Author',
            hintText:   'Enter author name (optional)',
            prefixIcon: Icon(Icons.person_outline),
          ),
          style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText:   'Description',
            hintText:    'Brief description (optional)',
            prefixIcon:  Icon(Icons.notes),
          ),
          style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  // ── Cover Picker ──────────────────────────────────────────────────────────

  Widget _buildCoverPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Image (Optional)',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 13, color: AppTheme.onSurface),
        ),
        const Text(
          'If not provided, cover will be auto-generated from PDF',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 11, color: AppTheme.onSurface),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _pickCover,
              child: Container(
                width:   80,
                height:  110,
                decoration: BoxDecoration(
                  color:        AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedCover != null ? AppTheme.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: _selectedCover != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(_selectedCover!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: AppTheme.onSurface, size: 28),
                          SizedBox(height: 4),
                          Text('Cover', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 10)),
                        ],
                      ),
              ),
            ),
            if (_selectedCover != null) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCoverName ?? '',
                    style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () => setState(() { _selectedCover = null; _selectedCoverName = null; }),
                    child: const Text('Remove', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.error, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type:       FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final name = result.files.single.name;

      // Auto-fill title from filename
      if (_titleController.text.isEmpty) {
        final baseName = name.replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '');
        _titleController.text = baseName.replaceAll('_', ' ').replaceAll('-', ' ');
      }

      setState(() {
        _selectedFile     = file;
        _selectedFileName = name;
      });
    }
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type:         FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedCover     = File(result.files.single.path!);
        _selectedCoverName = result.files.single.name;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      _showSnack('Please select an ebook file', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final result = await context.read<EbookProvider>().uploadEbook(
      file:        _selectedFile!,
      title:       _titleController.text.trim(),
      author:      _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
      description: _descController.text.trim().isEmpty  ? null : _descController.text.trim(),
      coverImage:  _selectedCover,
    );

    if (mounted) {
      if (result != null) {
        _showSnack('"${result.title}" uploaded successfully!');
        Navigator.pop(context, true);
      } else {
        _showSnack(
          context.read<EbookProvider>().errorMessage ?? 'Upload failed',
          isError: true,
        );
      }
    }
  }

  String _getFileSize(File file) {
    final size = file.lengthSync();
    if (size >= 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (size >= 1024)        return '${(size / 1024).toStringAsFixed(1)} KB';
    return '$size B';
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg, style: const TextStyle(fontFamily: 'Georgia')),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
