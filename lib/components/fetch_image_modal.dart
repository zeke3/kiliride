import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiliride/components/circle_button.wdg.dart';
import 'package:kiliride/shared/styles.shared.dart';


class FetchImageModal extends StatefulWidget {
  final Function onPickImage;
  const FetchImageModal({super.key, required this.onPickImage});

  @override
  State<FetchImageModal> createState() => _FetchImageModalState();
}

class _FetchImageModalState extends State<FetchImageModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            leading: const CircleButtonWDG(iconSrc: "assets/icons/camera2.svg"),
            title: Text(
              "Camera".tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSize,
                color: AppStyle.textColored(context),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppStyle.textColored(context),
            ),
          ),
          Divider(color: AppStyle.borderColor(context)),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            leading: const CircleButtonWDG(iconSrc: "assets/icons/gallery.svg"),
            title: Text(
              "Gallery".tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSize,
                color: AppStyle.textColored(context),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppStyle.textColored(context),
            ),
          ),
          const SizedBox(height: AppStyle.appPadding),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        widget.onPickImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}
