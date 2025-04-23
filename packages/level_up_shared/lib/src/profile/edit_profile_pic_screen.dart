import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:level_up_shared/src/profile/profile_service.dart';
import 'package:level_up_shared/src/utils/enums/pic_size.dart';
import 'package:level_up_shared/src/utils/locator.dart';
import 'package:level_up_shared/src/utils/widgets/async_avatar.dart';
import 'package:level_up_shared/src/utils/widgets/file_avatar.dart';

class EditProfilePicScreen extends StatefulWidget {
  const EditProfilePicScreen({super.key});

  @override
  State<EditProfilePicScreen> createState() => _EditProfilePicScreenState();
}

class _EditProfilePicScreenState extends State<EditProfilePicScreen> {
  String? _croppedFilePath;
  bool _uploading = false;

  Future<void> _onPickPhotoButtonPressed(ImageSource source) async {
    try {
      setState(() {
        _uploading = true;
      });
      XFile? pickedFile = await locate<ProfileService>().pickImage(source);
      if (pickedFile == null) {
        if (mounted) {
          setState(() {
            _uploading = false;
          });
        }
      } else {
        final croppedFilePath = await locate<ProfileService>().cropImage(
          pickedFile,
        );
        if (croppedFilePath == null) {
          if (mounted) {
            setState(() {
              _uploading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _croppedFilePath = croppedFilePath;
            });
          }
          await locate<ProfileService>().saveProfilePic(_croppedFilePath!);

          if (mounted) {
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        log(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_uploading) LinearProgressIndicator(),
            const SizedBox(height: 50),
            Stack(
              children: [
                if (_croppedFilePath != null)
                  FileAvatar(picPath: _croppedFilePath!, size: 100),
                if (_croppedFilePath == null)
                  AsyncAvatar(PicSize.medium, widgetSize: 100),
              ],
            ),
            const SizedBox(height: 50),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: Container()),
                      Flexible(
                        flex: 1,
                        child: IconButton.outlined(
                          onPressed:
                              () => _onPickPhotoButtonPressed(
                                ImageSource.gallery,
                              ),
                          icon: const Icon(Icons.photo),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextButton(
                            onPressed:
                                () => _onPickPhotoButtonPressed(
                                  ImageSource.gallery,
                                ),
                            child: Text('Pick from Gallery'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: Container()),
                      Flexible(
                        flex: 1,
                        child: IconButton.outlined(
                          onPressed:
                              () =>
                                  _onPickPhotoButtonPressed(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextButton(
                            onPressed:
                                () => _onPickPhotoButtonPressed(
                                  ImageSource.camera,
                                ),
                            child: Text('Take a Photo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
