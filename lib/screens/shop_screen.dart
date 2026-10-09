import 'package:flutter/material.dart';

import '../app/app.dart';
import '../models/player_skin.dart';
import '../models/shop_rules.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_scaffold.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return NeonScaffold(
      title: 'Vehicle Shop',
      trailing: CoinDisplay(coins: controller.totalCoins, compact: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: PlayerSkinCatalog.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final skin = PlayerSkinCatalog.all[index];
          final owned = controller.isSkinOwned(skin.id);
          final selected = controller.selectedSkinId == skin.id;
          final canBuy = ShopRules.canPurchase(
            coins: controller.totalCoins,
            price: skin.price,
            alreadyOwned: owned,
          );
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeonColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (selected ? skin.primary : NeonColors.purple).withValues(
                  alpha: 0.85,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: skin.glow, width: 2),
                    color: skin.primary.withValues(alpha: 0.18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skin.name,
                        style: const TextStyle(
                          color: NeonColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skin.isFree ? 'Free' : '${skin.price} coins',
                        style: const TextStyle(color: NeonColors.mutedText),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Text(
                    'SELECTED',
                    style: TextStyle(
                      color: NeonColors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  )
                else if (owned)
                  NeonButton(
                    label: 'Select',
                    expanded: false,
                    color: skin.primary,
                    onPressed: () => controller.selectSkin(skin.id),
                  )
                else
                  NeonButton(
                    label: 'Unlock',
                    expanded: false,
                    color: NeonColors.gold,
                    onPressed: canBuy
                        ? () => controller.purchaseSkin(skin.id)
                        : null,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
