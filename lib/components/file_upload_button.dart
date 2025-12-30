import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiliride/providers/theme.provider.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class FileUploadButtonComp extends ConsumerWidget {
  // Change to ConsumerWidget

  final String label;
  final String? existingFileUrl;
  final ValueChanged<File?> onFilePicked;
  final File? localFile;

  const FileUploadButtonComp({
    super.key,
    required this.label,
    required this.onFilePicked,
    this.existingFileUrl,
    this.localFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    final hasExistingFile =
        existingFileUrl != null && existingFileUrl!.isNotEmpty;
    final hasNewFile = localFile != null;
    String displayText = label;

    if (hasNewFile) {
      displayText = path.basename(localFile!.path);
    } else if (hasExistingFile) {
      displayText =
          label; // Show the descriptive label instead of "File already uploaded"
    }

    // You can now use `isDarkMode` to apply different styles
    final containerColor = isDarkMode
        ? Colors.blue[900]
        : const Color.fromRGBO(230, 242, 255, 1);
    final borderColor = isDarkMode
        ? Colors.blue[600]
        : const Color.fromRGBO(46, 123, 248, 1);
    final iconColor = isDarkMode
        ? Colors.blue[300]
        : const Color.fromRGBO(46, 123, 248, 1);
    final textColor = isDarkMode ? Colors.white70 : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyle.appGap),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          border: Border.all(color: borderColor!, width: 1),
          borderRadius: BorderRadius.circular(AppStyle.appRadius),
        ),
        height: AppStyle.buttonHeight + 5,
        child: GestureDetector(
          onTap: () {
            _showImageSourceDialog(onFilePicked, context, isDarkMode);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.appPadding,
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: iconColor),
                const SizedBox(width: AppStyle.appGap),
                Expanded(
                  child: Text(
                    displayText.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor),
                  ),
                ), // Apply text color
                Icon(
                  hasNewFile || hasExistingFile
                      ? Icons.check_circle
                      : Icons.cloud_upload_outlined,
                  color: hasNewFile || hasExistingFile
                      ? AppStyle.primaryColor(
                          context,
                        ) // Consider making this theme-aware too
                      : iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pass isDarkMode to the dialog method to apply styles there
  void _showImageSourceDialog(
    ValueChanged<File?> onFilePicked,
    context,
    bool isDarkMode,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: isDarkMode
          ? Colors.grey[900]
          : Colors.white, // Apply background color
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/gallery.svg",
                  colorFilter: ColorFilter.mode(
                    isDarkMode
                        ? Colors.white70
                        : AppStyle.secondaryColor(context),
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  'Gallery'.tr,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white70
                        : AppStyle.secondaryColor(context),
                    fontSize: AppStyle.appFontSize,
                  ),
                ),
                onTap: () async {
                  final pickedFile = await _pickImage(ImageSource.gallery);
                  onFilePicked(pickedFile);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/camera.svg",
                  colorFilter: ColorFilter.mode(
                    isDarkMode
                        ? Colors.white70
                        : AppStyle.secondaryColor(context),
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  'Camera'.tr,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white70
                        : AppStyle.secondaryColor(context),
                    fontSize: AppStyle.appFontSize,
                  ),
                ),
                onTap: () async {
                  final pickedFile = await _pickImage(ImageSource.camera);
                  onFilePicked(pickedFile);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 75,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
