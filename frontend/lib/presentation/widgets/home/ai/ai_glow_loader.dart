import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AiGlowLoader extends StatefulWidget {
  const AiGlowLoader({super.key});

  @override
  State<AiGlowLoader> createState() => AiGlowLoaderState();
}

class AiGlowLoaderState extends State<AiGlowLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Colors.blueAccent,
              Colors.cyan,
              Colors.deepPurpleAccent,
              Colors.blueAccent,
            ],
          ),
          boxShadow: [
            BoxShadow(color: Colors.cyan.withOpacity(0.6), blurRadius: 25),
          ],
        ),
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedAppleIntelligence,
            size: 38,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
