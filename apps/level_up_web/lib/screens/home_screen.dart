import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:level_up_web/widgets/faq_section.dart';
import 'package:level_up_web/widgets/lmowledge_sign_up_section.dart';
import 'package:level_up_web/widgets/pricing_section.dart';
import 'package:level_up_web/widgets/program_section.dart';
import 'package:level_up_web/widgets/testimonials_section.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _introKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _programsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _knowledgeKey = GlobalKey();

  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _videoInitialized = false;

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
    );
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
    );

    _videoController.setVolume(0);
    _videoInitialized = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _scrollTo(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelUp Coaching'),
        actions: [
          if (locate<AuthService>().currentUserId == null) ...[
            TextButton(
              onPressed: () => context.push('/signin'),
              child: const Text(
                'Sign In',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => context.push('/signup'),
              child: const Text('Sign Up'),
            ),
          ],
          if (locate<AuthService>().currentUserId == null)
            ElevatedButton(
              onPressed: () => context.push('/account'),
              child: const Text('Account'),
            ),
          PopupMenuButton<String>(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'intro',
                    child: Text('Video Intro'),
                  ),
                  const PopupMenuItem(value: 'pricing', child: Text('Pricing')),
                  const PopupMenuItem(
                    value: 'programs',
                    child: Text('Programs'),
                  ),
                  const PopupMenuItem(value: 'faq', child: Text('FAQs')),
                  const PopupMenuItem(
                    value: 'testimonials',
                    child: Text('Testimonials'),
                  ),
                  const PopupMenuItem(
                    value: 'knowledge',
                    child: Text('Free Knowledge'),
                  ),
                ],
            onSelected: (value) {
              switch (value) {
                case 'intro':
                  _scrollTo(_introKey);
                  break;
                case 'pricing':
                  _scrollTo(_pricingKey);
                  break;
                case 'programs':
                  _scrollTo(_programsKey);
                  break;
                case 'faq':
                  _scrollTo(_faqKey);
                  break;
                case 'testimonials':
                  _scrollTo(_testimonialsKey);
                  break;
                case 'knowledge':
                  _scrollTo(_knowledgeKey);
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Video Intro Section
            Container(
              key: _introKey,
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Text(
                    'Transform Your Fitness Journey',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 800,
                    height: 450,
                    child:
                        _videoInitialized
                            ? Chewie(controller: _chewieController)
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text('Loading'),
                              ],
                            ),
                  ),
                ],
              ),
            ),

            // Pricing Section
            Container(
              key: _pricingKey,
              padding: const EdgeInsets.all(40),
              color: Colors.grey[100],
              child: const PricingSection(),
            ),

            // Programs Section
            Container(
              key: _programsKey,
              padding: const EdgeInsets.all(40),
              child: const ProgramsSection(),
            ),

            // FAQs Section
            Container(
              key: _faqKey,
              padding: const EdgeInsets.all(40),
              color: Colors.grey[100],
              child: const FAQSection(),
            ),

            // Testimonials Section
            Container(
              key: _testimonialsKey,
              padding: const EdgeInsets.all(40),
              child: const TestimonialsSection(),
            ),

            // Free Knowledge Signup
            Container(
              key: _knowledgeKey,
              padding: const EdgeInsets.all(40),
              color: Colors.grey[100],
              child: const KnowledgeSignupSection(),
            ),
          ],
        ),
      ),
    );
  }
}
