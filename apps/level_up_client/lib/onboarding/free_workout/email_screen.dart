import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            // Centered TextField
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  autofocus: true,
                  autocorrect: false,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email here',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Next Button in bottom right
            Positioned(
              right: 24.0,
              bottom: 24.0,
              child: ElevatedButton(
                onPressed: () {
                  final text = _textController.text;

                  context.push('/terms-screen');
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
