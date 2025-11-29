import 'package:flutter/material.dart';
import 'package:frontend/core/themes/font_size.dart';

import '../../../../core/themes/font_weight.dart';

class AiTypingText extends StatefulWidget {
  const AiTypingText({super.key});

  @override
  State<AiTypingText> createState() => AiTypingTextState();
}

class AiTypingTextState extends State<AiTypingText> {
  final List<String> texts = [
    "Waiting for AI analyzing...",
    "Analyzing plant condition...",
    "Scanning soil moisture...",
    "Calculating growth health...",
    "Generating smart recommendation...",
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  void _startLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        index = (index + 1) % texts.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: Text(
        texts[index],
        key: ValueKey(index),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: AppFontWeight.semiBold,
          fontSize: AppFontSize.m,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}