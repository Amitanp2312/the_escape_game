import 'dart:math' as math;
import 'dart:ui';

import 'game_config.dart';

class LaneLayout {
  const LaneLayout({required this.screenWidth});

  final double screenWidth;

  double get laneWidth => screenWidth / GameConfig.laneCount;

  double laneCenter(int lane) {
    final clamped = lane.clamp(0, GameConfig.laneCount - 1);
    return laneWidth * (clamped + 0.5);
  }

  int laneAt(double x) {
    if (screenWidth <= 0) {
      return 0;
    }
    return (x / laneWidth).floor().clamp(0, GameConfig.laneCount - 1);
  }

  double minPlayerX(double playerWidth) {
    return playerWidth / 2 + GameConfig.edgePadding;
  }

  double maxPlayerX(double playerWidth) {
    return screenWidth - playerWidth / 2 - GameConfig.edgePadding;
  }

  double clampPlayerX(double x, double playerWidth) {
    return x.clamp(minPlayerX(playerWidth), maxPlayerX(playerWidth));
  }
}

double lerpDoubleClamped(double a, double b, double t) {
  return lerpDouble(a, b, t.clamp(0.0, 1.0))!;
}

int randomInt(math.Random random, int minInclusive, int maxInclusive) {
  if (maxInclusive <= minInclusive) {
    return minInclusive;
  }
  return minInclusive + random.nextInt(maxInclusive - minInclusive + 1);
}

String formatScore(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  if (value < 0) {
    buffer.write('-');
  }
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }
  return '${meters.toStringAsFixed(0)} m';
}

String formatDuration(double seconds) {
  final whole = seconds.floor().clamp(0, 99999);
  final minutes = whole ~/ 60;
  final remainder = whole % 60;
  final paddedSeconds = remainder.toString().padLeft(2, '0');
  return '$minutes:$paddedSeconds';
}
