class SpriteSheetSpec {
  const SpriteSheetSpec({
    required this.file,
    this.frames = 4,
    this.stepTime = 0.1,
  });

  final String file;
  final int frames;
  final double stepTime;
}

class SpriteAssets {
  static const String airplane = 'airplane.png';
  static const String coin = 'coin.png';
  static const String gem = 'gem.png';
  static const String meteor = 'meteor.png';
  static const String drone = 'drone.png';
  static const String mine = 'mine.png';
  static const String barrier = 'barrier.png';
  static const String missile = 'missile.png';
  static const String boss1 = 'boss_1.png';
  static const String boss2 = 'boss_2.png';
  static const String boss3 = 'boss_3.png';
  static const String boss4 = 'boss_4.png';
  static const String boss5 = 'boss_5.png';
  static const String bg1 = 'bg_1.jpg';
  static const String bg2 = 'bg_2.jpg';
  static const String bg3 = 'bg_3.jpg';
  static const String bg4 = 'bg_4.jpg';
  static const String bg5 = 'bg_5.jpg';

  static const List<String> stills = [
    airplane,
    coin,
    gem,
    meteor,
    drone,
    mine,
    barrier,
    missile,
    boss1,
    boss2,
    boss3,
    boss4,
    boss5,
    bg1,
    bg2,
    bg3,
    bg4,
    bg5,
  ];

  static const Map<String, SpriteSheetSpec> sheets = {
    airplane: SpriteSheetSpec(file: 'airplane_sheet.png', stepTime: 0.08),
    coin: SpriteSheetSpec(file: 'coin_sheet.png', stepTime: 0.09),
    gem: SpriteSheetSpec(file: 'gem_sheet.png', stepTime: 0.09),
    meteor: SpriteSheetSpec(file: 'meteor_sheet.png', stepTime: 0.11),
    drone: SpriteSheetSpec(file: 'drone_sheet.png', stepTime: 0.1),
    mine: SpriteSheetSpec(file: 'mine_sheet.png', stepTime: 0.12),
    barrier: SpriteSheetSpec(file: 'barrier_sheet.png', stepTime: 0.14),
    missile: SpriteSheetSpec(file: 'missile_sheet.png', stepTime: 0.08),
    boss1: SpriteSheetSpec(file: 'boss_1_sheet.png', stepTime: 0.12),
    boss2: SpriteSheetSpec(file: 'boss_2_sheet.png', stepTime: 0.12),
    boss3: SpriteSheetSpec(file: 'boss_3_sheet.png', stepTime: 0.11),
    boss4: SpriteSheetSpec(file: 'boss_4_sheet.png', stepTime: 0.11),
    boss5: SpriteSheetSpec(file: 'boss_5_sheet.png', stepTime: 0.1),
  };

  static List<String> get all => [
    ...stills,
    ...sheets.values.map((spec) => spec.file),
  ];
}
