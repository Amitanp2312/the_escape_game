import 'package:flutter/material.dart';

import '../app/app.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_scaffold.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final missions = controller.missionViews();
    return NeonScaffold(
      title: 'Missions',
      trailing: CoinDisplay(coins: controller.totalCoins, compact: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: missions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final mission = missions[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeonColors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (mission.claimed ? NeonColors.green : NeonColors.purple)
                    .withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.definition.title,
                  style: const TextStyle(
                    color: NeonColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mission.definition.description,
                  style: const TextStyle(color: NeonColors.mutedText),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: mission.fraction,
                    minHeight: 8,
                    color: NeonColors.cyan,
                    backgroundColor: NeonColors.surfaceAlt,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${mission.progress}/${mission.target}',
                      style: const TextStyle(
                        color: NeonColors.cyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '+${mission.definition.coinReward} coins',
                      style: const TextStyle(color: NeonColors.gold),
                    ),
                  ],
                ),
                if (mission.canClaim) ...[
                  const SizedBox(height: 10),
                  NeonButton(
                    label: 'Claim Reward',
                    color: NeonColors.green,
                    onPressed: () =>
                        controller.claimMission(mission.definition.id),
                  ),
                ] else if (mission.claimed)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Reward claimed',
                      style: TextStyle(
                        color: NeonColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
