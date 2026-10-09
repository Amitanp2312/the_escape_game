import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../utils/constants.dart';
import '../utils/game_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    Future<void>.delayed(
      Duration(milliseconds: (GameConfig.splashDurationSeconds * 1000).round()),
      () {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final glow = 0.35 + 0.65 * _controller.value;
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050510), Color(0xFF1A0830)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: math.sin(_controller.value * math.pi) * 0.03,
                    child: Text(
                      AppInfo.shortTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: NeonColors.cyan,
                        shadows: [
                          Shadow(
                            color: NeonColors.cyan.withValues(alpha: glow),
                            blurRadius: 22,
                          ),
                          Shadow(
                            color: NeonColors.magenta.withValues(alpha: glow),
                            blurRadius: 36,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppInfo.subtitle,
                    style: TextStyle(
                      color: NeonColors.magenta.withValues(
                        alpha: 0.5 + glow * 0.5,
                      ),
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
