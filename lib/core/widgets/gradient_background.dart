import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;
  const GradientBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A), // Dark Blue/Black
                Color(0xFF1E293B),
              ],
            ),
          ),
        ),
        // Animated Blobs
        if (showBlobs) ...[
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF06B6D4), // Cyan
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(
                    begin: 0,
                    end: 50,
                    duration: 4.seconds,
                    curve: Curves.easeInOut)
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 5.seconds),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6366F1), // Indigo/Purple
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(
                    begin: 0,
                    end: -50,
                    duration: 5.seconds,
                    curve: Curves.easeInOut)
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 6.seconds),
          ),
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
        // Content
        SafeArea(child: child),
      ],
    );
  }
}
