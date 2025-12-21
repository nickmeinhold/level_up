import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/painting.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:level_up_shared/src/utils/enums/pic_size.dart';

class ProfileService {
  ProfileService({
    required FirebaseStorage profilePicStorage,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _profilePicStorage = profilePicStorage,
       _firestore = firestore,
       _auth = auth;

  final FirebaseStorage _profilePicStorage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxHeight: 1000,
    );
    if (pickedFile == null) return null;
    return pickedFile;
  }

  Future<String?> cropImage(XFile pickedFile) async {
    // We need the dimensions to set rectWidth/rectHeight in the iOSUISettings
    // as this seems to be the only way to start the cropper as a square.
    final imageBytes = await pickedFile.readAsBytes();
    var decodedImage = await decodeImageFromList(imageBytes);
    int width = decodedImage.width;
    int height = decodedImage.height;
    int squareSize = (width > height) ? width : height;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 50,
      uiSettings: [
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioLockEnabled: true,
          rectHeight: squareSize.toDouble(),
          rectWidth: squareSize.toDouble(),
          rectX: 0,
          rectY: 0,
          resetButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
        ),
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
        ),
      ],
    );
    return croppedFile?.path;
  }

  Future<void> saveProfilePic(String filePath) async {
    final storageRef = _profilePicStorage.ref(
      '${_auth.currentUser!.uid}/profile.jpg',
    );
    await storageRef.putFile(File(filePath));
  }

  String getProfilePicUrl(PicSize size) {
    return switch (size) {
      PicSize.small =>
        'https://storage.googleapis.com/lu-profile-pics/${_auth.currentUser!.uid}/profile_small.jpg',
      PicSize.medium =>
        'https://storage.googleapis.com/lu-profile-pics/${_auth.currentUser!.uid}/profile_medium.jpg',
      PicSize.large =>
        'https://storage.googleapis.com/lu-profile-pics/${_auth.currentUser!.uid}/profile_large.jpg',
    };
  }

  String getProfilePicUrlForUser({
    required PicSize size,
    required String userId,
  }) {
    return switch (size) {
      PicSize.small =>
        'https://storage.googleapis.com/lu-profile-pics/$userId/profile_small.jpg',
      PicSize.medium =>
        'https://storage.googleapis.com/lu-profile-pics/$userId/profile_medium.jpg',
      PicSize.large =>
        'https://storage.googleapis.com/lu-profile-pics/$userId/profile_large.jpg',
    };
  }

  Future<void> updateName(String name) {
    return _firestore.collection('profiles').doc(_auth.currentUser!.uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }
}
