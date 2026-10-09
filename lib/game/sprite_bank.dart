import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

import '../utils/sprite_assets.dart';

class SpriteBank {
  SpriteBank(this._game);

  final FlameGame _game;
  final Map<String, Sprite> _sprites = {};
  final Map<String, SpriteAnimation> _animations = {};

  Future<void> loadAll() async {
    for (final name in SpriteAssets.stills) {
      try {
        final image = await _game.images.load(name);
        _sprites[name] = Sprite(image);
      } catch (_) {}
    }
    for (final entry in SpriteAssets.sheets.entries) {
      final spec = entry.value;
      try {
        final image = await _game.images.load(spec.file);
        final frameWidth = image.width / spec.frames;
        if (frameWidth <= 0) {
          continue;
        }
        _animations[entry.key] = SpriteAnimation.fromFrameData(
          image,
          SpriteAnimationData.sequenced(
            amount: spec.frames,
            stepTime: spec.stepTime,
            textureSize: Vector2(frameWidth, image.height.toDouble()),
          ),
        );
      } catch (_) {}
    }
  }

  Sprite? get(String name) => _sprites[name];

  bool has(String name) => _sprites.containsKey(name);

  SpriteAnimationTicker? ticker(String name) {
    final animation = _animations[name];
    if (animation == null) {
      return null;
    }
    return animation.createTicker();
  }
}

void renderSprite(
  Canvas canvas,
  Sprite sprite, {
  required Vector2 size,
  double opacity = 1,
  ColorFilter? tint,
}) {
  final paint = Paint()
    ..color = Color.fromRGBO(255, 255, 255, opacity)
    ..blendMode = BlendMode.srcOver
    ..filterQuality = FilterQuality.medium;
  if (tint != null) {
    paint.colorFilter = tint;
  }
  sprite.render(canvas, size: size, overridePaint: paint);
}
