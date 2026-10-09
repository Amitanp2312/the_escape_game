class ShopRules {
  static bool canPurchase({
    required int coins,
    required int price,
    required bool alreadyOwned,
  }) {
    return !alreadyOwned && price > 0 && coins >= price;
  }
}
