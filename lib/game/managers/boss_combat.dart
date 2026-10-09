class BossCombat {
  BossCombat({required this.maxHp}) : hp = maxHp;

  final int maxHp;
  int hp;
  bool defeated = false;
  bool invulnerable = false;

  int get phase => hp <= maxHp * 0.5 ? 2 : 1;

  bool applyDamage(int amount) {
    if (defeated || amount <= 0 || invulnerable) {
      return false;
    }
    hp = (hp - amount).clamp(0, maxHp);
    if (hp == 0) {
      defeated = true;
      return true;
    }
    return false;
  }
}
