import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

class TimeUpScreen extends StatefulWidget {
  const TimeUpScreen({super.key});

  @override
  State<TimeUpScreen> createState() => _TimeUpScreenState();
}

class _TimeUpScreenState extends State<TimeUpScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playAlarm();
    _vibrate();
  }

  Future<void> _playAlarm() async {
    if (!_isPlaying) {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(
        AssetSource('audio/alarm.mp3'),
      ); // Add your alarm sound file
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the alarm
    }
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000], // Vibrate pattern (ms)
        repeat: 1, // Repeat the pattern once
      );
    }
  }

  Future<void> _stopEffects() async {
    await _audioPlayer.stop();
    Vibration.cancel();
  }

  @override
  void dispose() {
    _stopEffects();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // First button (X) - takes half the screen, returns true
          Expanded(
            child: GestureDetector(
              onTap: () => context.pop(true), // Using go_router's pop
              child: Container(
                color: Colors.redAccent,
                child: const Center(
                  child: Icon(Icons.close, size: 100, color: Colors.white),
                ),
              ),
            ),
          ),
          // Second button (Repeat) - takes half the screen, returns false
          Expanded(
            child: GestureDetector(
              onTap: () => context.pop(false), // Using go_router's pop
              child: Container(
                color: Colors.greenAccent,
                child: const Center(
                  child: Icon(Icons.repeat, size: 100, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
