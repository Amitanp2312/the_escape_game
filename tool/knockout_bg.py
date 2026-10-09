"""Flood-fill studio gray/white from the image edges so sprites are truly transparent."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / "assets" / "images"
STILLS = [
    "airplane.png",
    "coin.png",
    "gem.png",
    "meteor.png",
    "drone.png",
    "mine.png",
    "barrier.png",
    "missile.png",
    "boss_1.png",
    "boss_2.png",
    "boss_3.png",
    "boss_4.png",
    "boss_5.png",
]


def is_studio_bg(r: int, g: int, b: int, seed: tuple[float, float, float]) -> bool:
    saturation = max(r, g, b) - min(r, g, b)
    if saturation > 38:
        return False
    if max(r, g, b) < 155:
        return False
    dist = ((r - seed[0]) ** 2 + (g - seed[1]) ** 2 + (b - seed[2]) ** 2) ** 0.5
    return dist < 90


def knockout(path: Path) -> None:
    image = Image.open(path).convert("RGBA")
    width, height = image.size
    pixels = image.load()
    corners = [
        pixels[0, 0][:3],
        pixels[width - 1, 0][:3],
        pixels[0, height - 1][:3],
        pixels[width - 1, height - 1][:3],
    ]
    seed = (
        sum(c[0] for c in corners) / 4,
        sum(c[1] for c in corners) / 4,
        sum(c[2] for c in corners) / 4,
    )

    seen = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def push(x: int, y: int) -> None:
        index = y * width + x
        if seen[index]:
            return
        red, green, blue, alpha = pixels[x, y]
        if alpha == 0 or not is_studio_bg(red, green, blue, seed):
            return
        seen[index] = 1
        queue.append((x, y))

    for x in range(width):
        push(x, 0)
        push(x, height - 1)
    for y in range(height):
        push(0, y)
        push(width - 1, y)

    removed = 0
    while queue:
        x, y = queue.popleft()
        pixels[x, y] = (0, 0, 0, 0)
        removed += 1
        if x > 0:
            push(x - 1, y)
        if x + 1 < width:
            push(x + 1, y)
        if y > 0:
            push(x, y - 1)
        if y + 1 < height:
            push(x, y + 1)
        if x > 0 and y > 0:
            push(x - 1, y - 1)
        if x + 1 < width and y > 0:
            push(x + 1, y - 1)
        if x > 0 and y + 1 < height:
            push(x - 1, y + 1)
        if x + 1 < width and y + 1 < height:
            push(x + 1, y + 1)

    # Soften the fringe so leftover halo does not read as a white box.
    fringe = []
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0:
                continue
            if not is_studio_bg(red, green, blue, seed):
                continue
            edge = False
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < width and 0 <= ny < height and pixels[nx, ny][3] == 0:
                    edge = True
                    break
            if edge:
                fringe.append((x, y))
    for x, y in fringe:
        red, green, blue, alpha = pixels[x, y]
        pixels[x, y] = (red, green, blue, min(alpha, 40))

    image.save(path)
    print(f"{path.name}: removed {removed} px, seed={tuple(round(v) for v in seed)}")


def main() -> None:
    for name in STILLS:
        path = ROOT / name
        if path.exists():
            knockout(path)


if __name__ == "__main__":
    main()
