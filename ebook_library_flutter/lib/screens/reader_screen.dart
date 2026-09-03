// lib/screens/reader_screen.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:epub_view/epub_view.dart';
import 'package:dio/dio.dart';

import '../models/ebook.dart';
import '../providers/ebook_provider.dart';
import '../theme/app_theme.dart';

class ReaderScreen extends StatefulWidget {
  final Ebook ebook;

  const ReaderScreen({super.key, required this.ebook});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  // PDF controller
  final PdfViewerController _pdfController = PdfViewerController();

  // EPUB controller
  EpubController? _epubController;

  // State
  bool    _isLoading        = true;
  String? _error;
  bool    _isFullscreen     = false;
  bool    _showControls     = true;
  Timer?  _controlsTimer;
  Uint8List? _fileBytes;
  int     _currentPage      = 0;
  int     _totalPages       = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.ebook.readPosition;
    _downloadAndOpen();
    _startControlsTimer();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _epubController?.dispose();
    _controlsTimer?.cancel();
    // Save position on exit
    if (_currentPage > 0) {
      context.read<EbookProvider>().updateReadPosition(widget.ebook.id, _currentPage);
    }
    super.dispose();
  }

  Future<void> _downloadAndOpen() async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        widget.ebook.fullFileUrl!,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
      );
      
      final bytes = Uint8List.fromList(response.data!);

      if (mounted) {
        setState(() {
          _fileBytes = bytes;
          _isLoading = false;
        });

        // Init EPUB controller after file is ready
        if (widget.ebook.isEpub) {
          _epubController = EpubController(
            document: EpubDocument.openData(bytes),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error     = 'Failed to load ebook: $e';
        });
      }
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startControlsTimer();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Reader content
            _buildReaderContent(),

            // Top controls overlay
            if (_showControls) _buildTopBar(context),

            // Bottom controls overlay
            if (_showControls && widget.ebook.isPdf) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 16),
            Text('Loading book...', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_fileBytes == null) return const SizedBox.shrink();

    // PDF Viewer
    if (widget.ebook.isPdf) {
      return SfPdfViewer.memory(
        _fileBytes!,
        controller:       _pdfController,
        initialPageNumber: _currentPage > 0 ? _currentPage : 1,
        enableDoubleTapZooming: true,
        enableTextSelection:    true,
        onPageChanged: (details) {
          setState(() {
            _currentPage = details.newPageNumber;
            _totalPages  = details.newPageNumber; // updated via document loaded
          });
        },
        onDocumentLoaded: (details) {
          setState(() => _totalPages = details.document.pages.count);
          // Jump to last read position
          if (widget.ebook.readPosition > 0) {
            _pdfController.jumpToPage(widget.ebook.readPosition);
          }
        },
      );
    }

    // EPUB Viewer
    if (widget.ebook.isEpub && _epubController != null) {
      return EpubView(
        controller: _epubController!,
        builders:   EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(color: AppTheme.surfaceVariant, height: 1),
        ),
      );
    }

    return const Center(
      child: Text('Unsupported format', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface)),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top:   0,
      left:  0,
      right: 0,
      child: AnimatedOpacity(
        opacity:  _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.topCenter,
              end:    Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon:    const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.ebook.title,
                    style: const TextStyle(fontFamily: 'Georgia', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon:    Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                  onPressed: _toggleFullscreen,
                  tooltip: 'Fullscreen',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left:   0,
      right:  0,
      child: AnimatedOpacity(
        opacity:  _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.bottomCenter,
              end:    Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page progress slider
              if (_totalPages > 0)
                Row(
                  children: [
                    Text(
                      'Page $_currentPage',
                      style: const TextStyle(fontFamily: 'Georgia', color: Colors.white70, fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value:    _currentPage.toDouble(),
                        min:      1,
                        max:      _totalPages.toDouble(),
                        onChanged: (value) {
                          _pdfController.jumpToPage(value.round());
                        },
                        activeColor:   AppTheme.primary,
                        inactiveColor: Colors.white24,
                      ),
                    ),
                    Text(
                      '$_totalPages',
                      style: const TextStyle(fontFamily: 'Georgia', color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:    const Icon(Icons.navigate_before, color: Colors.white),
                    onPressed: () => _pdfController.previousPage(),
                    tooltip: 'Previous page',
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon:    const Icon(Icons.navigate_next, color: Colors.white),
                    onPressed: () => _pdfController.nextPage(),
                    tooltip: 'Next page',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
