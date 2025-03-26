import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/auth/auth_service.dart';
import 'package:level_up/utils/locator.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
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
                    hintText: 'Enter your name here',
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

                  locate<AuthService>().update(name: text);

                  context.push('/email-screen');
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
