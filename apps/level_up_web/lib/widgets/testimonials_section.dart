import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Success Stories',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              TestimonialCard(
                name: 'Sarah J.',
                quote: 'LevelUp transformed my fitness routine...',
                videoUrl: 'https://youtube.com/embed/VIDEO_ID_1',
              ),
              SizedBox(width: 20),
              TestimonialCard(
                name: 'Mike T.',
                quote: 'Best investment I made in my health...',
                videoUrl: 'https://youtube.com/embed/VIDEO_ID_2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TestimonialCard extends StatefulWidget {
  final String name;
  final String quote;
  final String videoUrl;

  const TestimonialCard({
    super.key,
    required this.name,
    required this.quote,
    required this.videoUrl,
  });

  @override
  State<TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<TestimonialCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/promotional-videos/o/Nick1.mp4?alt=media&token=ae1b3690-80b2-4441-a146-cc516aa3e019',
        ),
      )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 400,
        child: Column(
          children: [
            SizedBox(height: 200, child: VideoPlayer(_controller)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.quote),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
