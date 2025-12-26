import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiliride/components/fetch_image_modal.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CustomAvatar extends StatefulWidget {
  final DocumentSnapshot? userData;
  final String? userId;
  final String? imageURL;
  final String? imageAsset;
  final bool isEditable;
  final double size;
  final Color? ringColor;
  final File? imageFile;
  final ValueChanged<File>? onPickImage;
  final String? username;
  final String? fullName;
  final VoidCallback? onTap;
  final bool isPreview;
  final bool showRing;

  const CustomAvatar({
    super.key,
    this.imageURL,
    this.imageAsset,
    this.isEditable = false,
    this.size = 69.0,
    this.ringColor,
    this.imageFile,
    this.onPickImage,
    this.username,
    this.fullName,
    this.onTap,
    this.isPreview = false,
    this.userData,
    this.userId,
    this.showRing = false,
  });

  @override
  State<CustomAvatar> createState() => _CustomAvatarState();
}

class _CustomAvatarState extends State<CustomAvatar> {
  // ... (No changes to _getBackgroundColor, _getForegroundColor, _extractInitials, _showImagePicker, or _showAvatarPreview)

  Color _getBackgroundColor() {
    if (widget.username == null || widget.username!.isEmpty) {
      return Colors.grey.shade400;
    }
    final int hash = widget.username!.hashCode;
    final Random random = Random(hash);
    return Color.fromRGBO(
      random.nextInt(200) + 56,
      random.nextInt(200) + 56,
      random.nextInt(200) + 56,
      1,
    );
  }

  Color _getForegroundColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }

  String _extractInitials() {
    if (widget.fullName?.trim().isNotEmpty ?? false) {
      final names = widget.fullName!
          .split(' ')
          .where((s) => s.isNotEmpty)
          .toList();
      if (names.length > 1) {
        return (names.first[0] + names.last[0]).toUpperCase();
      } else if (names.isNotEmpty) {
        return names.first[0].toUpperCase();
      }
    }
    if (widget.username?.isNotEmpty ?? false) {
      return widget.username![0].toUpperCase();
    }
    return "NN";
  }

  void _showImagePicker() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppStyle.appRadiusLLG),
        ),
      ),
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      backgroundColor: AppStyle.appColor(context),
      builder: (context) {
        return FetchImageModal(
          onPickImage: (file) {
            widget.onPickImage?.call(file);
          },
        );
      },
    );
  }

  void _showAvatarPreview() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: CustomAvatar(
                userData: widget.userData,
                userId: widget.userId,
                imageURL: widget.imageURL,
                imageAsset: widget.imageAsset,
                imageFile: widget.imageFile,
                username: widget.username,
                fullName: widget.fullName,
                size: MediaQuery.of(context).size.width * 0.85,
                isPreview: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // This widget now returns a Container that is already circular.
  Widget _buildInitials({required Key key}) {
    final Color backgroundColor = _getBackgroundColor();
    final Color foregroundColor = _getForegroundColor(backgroundColor);

    return Container(
      key: key,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Text(
        _extractInitials(),
        style: TextStyle(
          fontSize: widget.size * 0.4,
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //This widget is now guaranteed to be circular.
  Widget _buildImage({required Key key}) {
    if (widget.imageURL?.isNotEmpty ?? false) {
      return CachedNetworkImage(
        key: key,
        imageUrl: widget.imageURL!,
        // This builder renders the image inside a circular container.
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        // The placeholder is also made circular for a consistent look.
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
        ),
        // The error widget falls back to the initials, which are already circular.
        errorWidget: (context, url, error) =>
            _buildInitials(key: const ValueKey('error_initials')),
      );
    }

    // This handles local file and asset images.
    ImageProvider imageProvider;
    if (widget.imageFile != null) {
      imageProvider = FileImage(widget.imageFile!);
    } else {
      imageProvider = AssetImage(widget.imageAsset!);
    }

    // It is also wrapped in a circular container.
    return Container(
      key: key,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImageSource =
        widget.imageFile != null ||
        (widget.imageURL?.isNotEmpty ?? false) ||
        widget.imageAsset != null;
    final heroTag =
        'avatar-${widget.imageURL ?? widget.fullName ?? widget.username}';

    final Widget avatarContent = Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(widget.showRing ? (widget.ringColor != null ? 2.0 : 4) : 0),
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/gifs/sas_mobile3.gif"),
              //   fit: BoxFit.cover,
              //   colorFilter: ColorFilter.mode(
              //     Colors.black.withValues(alpha: 0.001),
              //     BlendMode.darken,
              //   ),
              // ),
              shape: BoxShape.circle,
            ),
            child: Container(
              height: widget.size,
              width: widget.size,
              // This outer container now only draws the border.
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: widget.showRing ? widget.ringColor != null
                    ? Border.all(color: widget.ringColor!, width: 2.0)
                    : Border.all(color: Colors.white, width: 2.8) : null,
              ),
              // The redundant ClipOval is removed.
              // Clipping is now handled by the children themselves.
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: hasImageSource
                    ? _buildImage(key: const ValueKey('image'))
                    : _buildInitials(key: const ValueKey('initials')),
              ),
            ),
          ),
          if (widget.isEditable)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  width: widget.size * 0.4,
                  height: widget.size * 0.4,
                  decoration: BoxDecoration(
                    color: AppStyle.appColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppStyle.secondaryColor(context),
                    size: widget.size * 0.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.isPreview) {
      return avatarContent;
    }

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          if(widget.userId == null || widget.userData == null) {
            return;
          }
          if(widget.userData?.id == widget.userId) {
            return;
          }
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) {
          //       return ProfilePage(
          //         userId: widget.userId,
          //         userData: widget.userData!,
          //       );
          //     },
          //   ),
          // ); // REPLACE WITH BACKEND PROFILE LOGIC
          // _showAvatarPreview();
        }
      },
      onLongPress: _showAvatarPreview,
      child: avatarContent,
    );
  }
}
