import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:level_up/auth/auth_service.dart';
import 'package:level_up/utils/locator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  bool _isUploading = false;
  String? _videoPath;
  double _uploadProgress = 0;
  List<CameraDescription> _cameras = <CameraDescription>[];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get available cameras
    _cameras = await availableCameras();
    final firstCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(firstCamera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    try {
      await _initializeControllerFuture;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videoPath = path.join(appDir.path, '${Uuid().v4()}.mp4');

      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _videoPath = videoPath;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoPath == null) return;

    setState(() => _isUploading = true);

    try {
      final File videoFile = File(_videoPath!);
      final String fileName = path.basename(_videoPath!);
      final String userId = locate<AuthService>().currentUserId!;

      final Reference storageRef = FirebaseStorage.instance.ref().child(
        'client_videos/$userId/$fileName',
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
        log('bytesTransferred: ${snapshot.bytesTransferred}');
        log('totalBytes: ${snapshot.totalBytes}');
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask.whenComplete(() => null);

      final String downloadUrl = await storageRef.getDownloadURL();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Video uploaded successfully!')));
      }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload video: $e')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Video'),
        actions: [
          if (_videoPath != null && !_isRecording && !_isUploading)
            IconButton(icon: Icon(Icons.upload), onPressed: _uploadVideo),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                if (_isUploading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(value: _uploadProgress),
                        SizedBox(height: 16),
                        Text(
                          'Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.blue,
        onPressed: _isRecording ? _stopRecording : _startRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.videocam),
      ),
    );
  }
}
