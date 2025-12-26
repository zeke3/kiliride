import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:kiliride/components/custom_mono_appbar.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:kiliride/utils/document_cache_manager.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String documentName;
  final String documentPath; // This can be a URL or a local file path
  final DocumentType documentType; // Enum to indicate document type
  final String? documentId; // Optional ID for caching

  const DocumentPreviewScreen({
    super.key,
    required this.documentName,
    required this.documentPath,
    required this.documentType,
    this.documentId, // Optional ID for caching, if null we'll use documentName
  });

  @override
  _DocumentPreviewScreenState createState() => _DocumentPreviewScreenState();
}

// Enum to represent document types
enum DocumentType { pdf, image, word }

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  String? localPath;
  bool loading = true;
  bool loadError = false;
  String errorMessage = '';
  bool isCached = false;

  // Add controller for PdfX to control the PDF view
  PdfController? pdfController;
  int currentPage = 1;
  int totalPdfPages = 0;

  // Cache manager instance
  late final DocumentCacheManager cacheManager;

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cacheManager = DocumentCacheManager();
    _prepareDocument();
  }

  Future<void> _prepareDocument() async {
    try {
      if (_isUrl(widget.documentPath)) {
        // Check if the document is already cached
        final docId = widget.documentId ?? widget.documentName;
        final fileExtension = _getFileExtension();

        final cachedDocument = await cacheManager.getDocument(
          docId,
          fileExtension,
        );

        if (cachedDocument != null && await cachedDocument.exists()) {
          setState(() {
            localPath = cachedDocument.path;
            isCached = true;
          });
          print('Using cached document: $localPath');

          // Initialize PDF controller if it's a PDF
          if (widget.documentType == DocumentType.pdf) {
            await _initializePdfController(cachedDocument.path);
          }

          setState(() {
            loading = false;
          });
        } else {
          // If not cached, download the document
          await _downloadDocument(widget.documentPath);
        }
      } else {
        setState(() {
          localPath = widget.documentPath;
        });

        // Initialize PDF controller if it's a PDF
        if (widget.documentType == DocumentType.pdf) {
          await _initializePdfController(widget.documentPath);
        }

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        loadError = true;
        errorMessage = e.toString();
      });
      print('Error preparing document: $e');
    }
  }

  Future<void> _initializePdfController(String path) async {
    try {
      pdfController = PdfController(document: PdfDocument.openFile(path));
    } catch (e) {
      print('Error initializing PDF controller: $e');
      setState(() {
        loadError = true;
        errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  bool _isUrl(String path) {
    Uri? uri = Uri.tryParse(path);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _getFileExtension() {
    switch (widget.documentType) {
      case DocumentType.pdf:
        return 'pdf';
      case DocumentType.image:
        return 'jpg';
      case DocumentType.word:
        return 'docx'; // or 'doc' depending on your need
    }
  }

  Future<void> _downloadDocument(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download document: Status code ${response.statusCode}',
        );
      }

      final bytes = response.bodyBytes;
      final docId = widget.documentId ?? widget.documentName;
      final fileExtension = _getFileExtension();

      // Save to cache
      final file = await cacheManager.saveDocument(docId, fileExtension, bytes);

      setState(() {
        localPath = file.path;
        isCached = true;
      });

      print('Document downloaded and cached: ${file.path}');

      // Initialize PDF controller if it's a PDF
      if (widget.documentType == DocumentType.pdf) {
        await _initializePdfController(file.path);
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      print("Error loading document: $e");
      setState(() {
        loading = false;
        loadError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _openWithExternalApp() async {
    if (localPath == null) return;

    final file = File(localPath!);
    if (!await file.exists()) {
      setState(() {
        loadError = true;
        errorMessage = 'File does not exist at path: ${file.path}';
      });
      return;
    }

    try {
      if (Platform.isIOS) {
        // iOS-specific handling: try opening with the file URI first
        final Uri uri = Uri.file(file.path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: try using an encoded file path
          final String encodedPath = Uri.encodeFull(file.path);
          final Uri fallbackUri = Uri.file(encodedPath);
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not open the file on iOS');
          }
        }
      } else {
        // Android handling: use a properly constructed file URI
        final Uri uri = Uri.file(file.path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No app found to open this document type');
        }
      }
    } catch (e) {
      print("Error opening file: $e");
      setState(() {
        loadError = true;
        errorMessage = 'Error opening file: $e';
      });
      // Fallback: try to share the document instead
      await _shareDocument();
    }
  }

  // Updated sharing method with iOS-specific improvements
  Future<void> _shareDocument() async {
    if (localPath == null) return;

    try {
      // For iOS, we need to ensure the file has the correct UTI (Uniform Type Identifier)
      if (Platform.isIOS && widget.documentType == DocumentType.word) {
        // Make sure the file has the right extension visible to iOS
        final String currentPath = localPath!;
        if (!currentPath.toLowerCase().endsWith('.docx') &&
            !currentPath.toLowerCase().endsWith('.doc')) {
          // If the file doesn't have the correct extension, make a copy with the right extension
          final dir = await getApplicationDocumentsDirectory();
          final newPath = '${dir.path}/${widget.documentName}.docx';
          final File newFile = await File(currentPath).copy(newPath);
          localPath = newFile.path;
        }
      }

      await Share.shareXFiles(
        [XFile(localPath!)],
        text: widget.documentName,
        subject: widget.documentName,
      );
    } catch (e) {
      print("Error sharing document: $e");
      setState(() {
        loadError = true;
        errorMessage = 'Error sharing file: $e';
      });
    }
  }

  // Remove the cached document
  Future<void> _removeFromCache() async {
    if (localPath == null) return;

    try {
      final docId = widget.documentId ?? widget.documentName;
      final fileExtension = _getFileExtension();

      final success = await cacheManager.deleteDocument(docId, fileExtension);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document removed from device storage'),
            backgroundColor: Colors.green,
          ),
        );

        // Re-download the document if it was a URL
        if (_isUrl(widget.documentPath)) {
          // Dispose old PDF controller if exists
          pdfController?.dispose();
          pdfController = null;

          setState(() {
            loading = true;
            isCached = false;
          });
          await _downloadDocument(widget.documentPath);
        }
      }
    } catch (e) {
      print("Error removing document from cache: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDocumentViewer() {
    if (localPath == null) {
      return Center(child: Text('No document to display'.tr));
    }

    switch (widget.documentType) {
      case DocumentType.pdf:
        // Check if controller is initialized
        if (pdfController == null) {
          return Center(child: CircularProgressIndicator());
        }

        return PdfView(
          controller: pdfController!,
          onDocumentLoaded: (document) {
            setState(() {
              totalPdfPages = document.pagesCount;
            });
          },
          onPageChanged: (page) {
            setState(() {
              currentPage = page;
            });
          },
          onDocumentError: (error) {
            print('Error viewing PDF: $error');
            setState(() {
              loadError = true;
              errorMessage = error.toString();
            });
          },
        );
      case DocumentType.image:
        // Use a LayoutBuilder to ensure the image fits correctly
        return LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                constrained: true, // Ensure view is constrained to screen
                child: Image.file(
                  File(localPath!),
                  // BoxFit.contain ensures the entire image is visible without zooming
                  fit: BoxFit.contain,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  // Alignment center ensures the image is centered
                  alignment: Alignment.center,
                ),
              ),
            );
          },
        );
      case DocumentType.word:
        // Instead of trying to display Word docs directly, we'll show a preview card
        // with options to open with external app or share
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description,
                        size: 72,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.documentName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Microsoft Word Document'.tr,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      if (isCached)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Saved on device'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _openWithExternalApp,
                            icon: const Icon(Icons.open_in_new),
                            label: Text('Open'.tr),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _shareDocument,
                            icon: const Icon(Icons.share),
                            label: Text('Share'.tr),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCached) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _removeFromCache,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                          ),
                          label: Text(
                            'Remove from device'.tr,
                            style: TextStyle(color: Colors.red[400]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Word documents can be viewed using external applications'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppStyle.appBarHeight),
        child: CustomMonoAppBar(
          isScreen: true,
          title: widget.documentName,
          actions: [
            if (!loading && !loadError && localPath != null) ...[
              if (isCached && widget.documentType != DocumentType.word)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _removeFromCache,
                  tooltip: 'Remove from device'.tr,
                ),
              IconButton(
                icon: Icon(Icons.share, color: AppStyle.textAppColor(context)),
                onPressed: _shareDocument,
                tooltip: 'Share'.tr,
              ),
            ],
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load document'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    if (widget.documentType == DocumentType.word)
                      ElevatedButton.icon(
                        onPressed: _shareDocument,
                        icon: const Icon(Icons.share),
                        label: Text('Share Document'.tr),
                      ),
                  ],
                ),
              ),
            )
          : _buildDocumentViewer(),
      // PDF page controls
      floatingActionButton:
          widget.documentType == DocumentType.pdf &&
              !loading &&
              !loadError &&
              pdfController != null &&
              totalPdfPages > 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "prevPage",
                  mini: true,
                  child: Icon(Icons.navigate_before),
                  onPressed: () {
                    if (currentPage > 1) {
                      pdfController?.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: "nextPage",
                  mini: true,
                  child: Icon(Icons.navigate_next),
                  onPressed: () {
                    if (currentPage < totalPdfPages) {
                      pdfController?.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            )
          : null,
      // LEAVE IT FOR NOW
      // bottomNavigationBar: isCached && widget.documentType == DocumentType.pdf
      //     ? Container(
      //         padding: const EdgeInsets.all(8.0),
      //         color: Colors.grey[100],
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(Icons.download_done, color: Colors.green[600]),
      //             const SizedBox(width: 8),
      //             Text(
      //               'Saved on device'.tr,
      //               style: TextStyle(
      //                 color: Colors.green[600],
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //             const SizedBox(width: 16),
      //             TextButton.icon(
      //               onPressed: _removeFromCache,
      //               icon: Icon(Icons.delete_outline, color: Colors.red[400]),
      //               label: Text(
      //                 'Remove'.tr,
      //                 style: TextStyle(color: Colors.red[400]),
      //               ),
      //             ),
      //           ],
      //         ),
      //       )
      //     : null,
    );
  }
}
