"""Generate looping WAV files for Neon Escape."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    peak = max((abs(sample) for sample in samples), default=1.0)
    norm = 0.92 / peak if peak > 0.92 else 1.0
    with wave.open(str(path), "w") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        frames = b"".join(
            struct.pack(
                "<h",
                max(-32767, min(32767, int(sample * norm * 32767))),
            )
            for sample in samples
        )
        wav.writeframes(frames)


def clamp(sample: float) -> float:
    return max(-1.0, min(1.0, sample))


def env_adsr(index: int, total: int, attack: float = 0.02, release: float = 0.08) -> float:
    t = index / RATE
    duration = total / RATE
    if t < attack:
        return t / attack
    if t > duration - release:
        return max(0.0, (duration - t) / release)
    return 1.0


def osc(frequency: float, t: float) -> float:
    return math.sin(2 * math.pi * frequency * t) + 0.22 * math.sin(
        4 * math.pi * frequency * t
    )


def note(frequency: float, duration: float, volume: float) -> list[float]:
    total = int(RATE * duration)
    samples = []
    for index in range(total):
        t = index / RATE
        samples.append(osc(frequency, t) * volume * env_adsr(index, total))
    return samples


def noise_hit(duration: float, volume: float, decay: float) -> list[float]:
    total = int(RATE * duration)
    samples = []
    for index in range(total):
        t = index / RATE
        samples.append((random.random() * 2 - 1) * volume * math.exp(-t * decay))
    return samples


def kick(duration: float = 0.18, volume: float = 0.45) -> list[float]:
    total = int(RATE * duration)
    samples = []
    for index in range(total):
        t = index / RATE
        freq = 90 * math.exp(-t * 8)
        samples.append(math.sin(2 * math.pi * freq * t) * volume * math.exp(-t * 9))
    return samples


def add(dest: list[float], src: list[float], start: int) -> None:
    for offset, sample in enumerate(src):
        index = start + offset
        if 0 <= index < len(dest):
            dest[index] = clamp(dest[index] + sample)


def loop_theme(
    *,
    bpm: float,
    bars: int,
    melody: list[float | None],
    bass: list[float | None],
    volume: float,
    drive: float,
) -> list[float]:
    beat = 60.0 / bpm
    step = beat / 2
    length = int(RATE * beat * 4 * bars)
    samples = [0.0] * length
    steps_per_bar = 8
    rng = random.Random(7)

    for bar in range(bars):
        for step_index in range(steps_per_bar):
            start = int((bar * steps_per_bar + step_index) * step * RATE)
            if step_index % 2 == 0:
                add(samples, kick(volume=0.32 * drive), start)
            if step_index % 2 == 1:
                add(samples, noise_hit(0.06, 0.08 * drive, 40), start)
            if step_index % 4 == 2:
                add(samples, noise_hit(0.04, 0.12 * drive, 55), start)

            melody_note = melody[(bar * steps_per_bar + step_index) % len(melody)]
            if melody_note:
                add(samples, note(melody_note, step * 0.92, volume), start)
            bass_note = bass[(bar * steps_per_bar + step_index) % len(bass)]
            if bass_note and step_index % 2 == 0:
                add(samples, note(bass_note, step * 1.6, volume * 0.7), start)

            # faint arp sparkle
            if rng.random() < 0.35:
                add(
                    samples,
                    note((melody_note or 440) * 2, step * 0.35, volume * 0.35),
                    start + int(step * 0.25 * RATE),
                )
    return samples


def sfx_tone(frequency: float, duration: float, volume: float = 0.28) -> list[float]:
    return note(frequency, duration, volume)


def main() -> None:
    random.seed(11)
    run = loop_theme(
        bpm=112,
        bars=4,
        melody=[
            392,
            None,
            494,
            392,
            523,
            None,
            494,
            440,
            392,
            None,
            330,
            392,
            440,
            None,
            494,
            392,
        ],
        bass=[196, None, 196, None, 147, None, 165, None] * 2,
        volume=0.16,
        drive=0.7,
    )
    boss = loop_theme(
        bpm=140,
        bars=4,
        melody=[
            523,
            622,
            523,
            None,
            698,
            622,
            523,
            466,
            523,
            698,
            784,
            None,
            698,
            622,
            523,
            415,
        ],
        bass=[131, None, 156, None, 131, None, 175, None] * 2,
        volume=0.18,
        drive=1.15,
    )
    write_wav(ROOT / "bgm.wav", run)
    write_wav(ROOT / "boss_bgm.wav", boss)
    write_wav(ROOT / "coin.wav", sfx_tone(880, 0.1, 0.28) + sfx_tone(1174, 0.08, 0.22))
    write_wav(ROOT / "power_up.wav", sfx_tone(523, 0.08, 0.24) + sfx_tone(784, 0.14, 0.3))
    write_wav(ROOT / "collision.wav", noise_hit(0.18, 0.4, 14) + sfx_tone(110, 0.16, 0.22))
    write_wav(ROOT / "tap.wav", sfx_tone(660, 0.05, 0.2))
    write_wav(ROOT / "game_over.wav", sfx_tone(196, 0.16, 0.26) + sfx_tone(147, 0.28, 0.3))
    write_wav(
        ROOT / "mission.wav",
        sfx_tone(523, 0.09, 0.24) + sfx_tone(659, 0.1, 0.26) + sfx_tone(784, 0.16, 0.3),
    )
    print(f"Wrote audio assets to {ROOT}")


if __name__ == "__main__":
    main()
