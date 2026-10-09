import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/routes.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import '../widgets/neon_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).audio.startMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF140824), NeonColors.background],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 20,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: CoinDisplay(coins: controller.totalCoins),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        AppInfo.shortTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NeonColors.cyan,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        AppInfo.subtitle,
                        style: TextStyle(
                          color: NeonColors.magenta,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 36),
                      NeonButton(
                        label: 'Play',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.levels),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'Missions',
                        color: NeonColors.purple,
                        icon: Icons.flag_rounded,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.missions),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'Character / Vehicle Shop',
                        color: NeonColors.gold,
                        icon: Icons.directions_car_filled_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.shop),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'High Score',
                        color: NeonColors.green,
                        icon: Icons.emoji_events_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.highScore),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'How to Play',
                        color: NeonColors.pink,
                        icon: Icons.help_outline,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.howToPlay),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'Settings',
                        color: NeonColors.cyan,
                        icon: Icons.settings_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'About',
                        color: NeonColors.purple,
                        icon: Icons.info_outline,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.about),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
