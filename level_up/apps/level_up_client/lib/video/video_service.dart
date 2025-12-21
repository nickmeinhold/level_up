import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class VideoService {
  VideoService({
    required FirebaseStorage clientFormVideosStorage,
    required FirebaseAuth auth,
  }) : _clientFormVideosStorage = clientFormVideosStorage,
       _auth = auth;

  final FirebaseStorage _clientFormVideosStorage;
  final FirebaseAuth _auth;

  final uploadProgressStreamController = StreamController<double>.broadcast();
  Stream<double> get uploadProgressStream =>
      uploadProgressStreamController.stream;

  Future<void> uploadVideo(String videoPath) async {
    final File videoFile = File(videoPath);
    final String fileName = path.basename(videoPath);
    final String userId = _auth.currentUser!.uid;

    final Reference storageRef = _clientFormVideosStorage.ref().child(
      '$userId/$fileName',
    );

    final UploadTask uploadTask = storageRef.putFile(
      videoFile,
      SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {
          'uploaded_by': userId,
          'uploaded_at': DateTime.now().toString(),
        },
      ),
    );

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      uploadProgressStreamController.add(
        snapshot.bytesTransferred / snapshot.totalBytes,
      );
    });

    await uploadTask.whenComplete(() => null);

    final String downloadUrl = await storageRef.getDownloadURL();

    // Save the downloadUrl to Firestore as a message
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .add({
          'videoUrl': downloadUrl,
          'authorId': userId,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'type': 'video',
        });
  }
}
