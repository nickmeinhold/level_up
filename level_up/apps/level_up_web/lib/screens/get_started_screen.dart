import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  // Controller for the video player.
  late VideoPlayerController _videoController;

  // The data to be encoded in the QR code.
  // This could be a dynamic link, a custom URL scheme, or a website URL.
  // Example: a custom URL scheme "yourapp://open"
  final String qrCodeData = 'https://flutter.dev';

  @override
  void initState() {
    super.initState();
    // Initialize the video controller with a video from an asset or network.
    _videoController = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        ),
      )
      ..initialize().then((_) {
        // Ensure the first frame is shown and play the video.
        setState(() {});
        _videoController.play();
      });
  }

  @override
  void dispose() {
    // Dispose of the video controller to release resources.
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome! Watch this short video to learn how to use our app.',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // The explainer video widget.
              _videoController.value.isInitialized
                  ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                  : const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 40),

              const Text(
                'Ready to get started? Scan the QR code below to download the app!',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // The QR code widget.
              Center(
                child: QrImageView(
                  data: qrCodeData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Optional: A button to directly open the link.
              ElevatedButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse(qrCodeData);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    // Handle case where the URL cannot be launched.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open $url')),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Or open link directly'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
