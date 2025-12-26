import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class FullImageView extends StatefulWidget {
  final List<String> imageUrls;
  final String thumbnailUrl;
  final int initialIndex;
  final List<String>? titles;
  final List<String?>? descriptions;

  const FullImageView({
    Key? key,
    required this.imageUrls,
    required this.thumbnailUrl,
    required this.initialIndex,
    this.titles,
    this.descriptions,
  }) : super(key: key);

  @override
  _FullImageViewState createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    // Combine imageUrls and thumbnailUrl
    final List<String> images = widget.imageUrls.isEmpty
        ? [widget.thumbnailUrl]
        : widget.imageUrls;

    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              size: AppStyle.appFontSizeLG,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '${_currentPage + 1}/${images.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppStyle.appFontSize,
            ),
          ),
        ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl = images[index];

                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: InteractiveViewer(
                    child: Center(
                      child: _isNetworkImage(imageUrl)
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              ),
                            )
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                );
              },
            ),
            // Image details overlay
            if (widget.titles != null && widget.titles!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentPage < widget.titles!.length) ...[
                          Text(
                            widget.titles![_currentPage],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.descriptions != null &&
                              _currentPage < widget.descriptions!.length &&
                              widget.descriptions![_currentPage] != null &&
                              widget
                                  .descriptions![_currentPage]!
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.descriptions![_currentPage]!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isNetworkImage(String imageUrl) {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }
}
