import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/models/shop_rules.dart';

void main() {
  test('purchase requires enough coins and an unowned skin', () {
    expect(
      ShopRules.canPurchase(coins: 500, price: 500, alreadyOwned: false),
      isTrue,
    );
    expect(
      ShopRules.canPurchase(coins: 499, price: 500, alreadyOwned: false),
      isFalse,
    );
    expect(
      ShopRules.canPurchase(coins: 5000, price: 500, alreadyOwned: true),
      isFalse,
    );
    expect(
      ShopRules.canPurchase(coins: 100, price: 0, alreadyOwned: false),
      isFalse,
    );
  });
}
