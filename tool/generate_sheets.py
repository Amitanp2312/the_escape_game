"""Build 4-frame sprite sheets from the still PNGs."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance

ROOT = Path(__file__).resolve().parents[1] / "assets" / "images"
FRAMES = 4


def fit(image: Image.Image, box: tuple[int, int]) -> Image.Image:
    image = image.convert("RGBA")
    image.thumbnail(box, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", box, (0, 0, 0, 0))
    canvas.paste(
        image,
        ((box[0] - image.width) // 2, (box[1] - image.height) // 2),
        image,
    )
    return canvas


def brighten(image: Image.Image, amount: float) -> Image.Image:
    return ImageEnhance.Brightness(image).enhance(amount)


def squash(image: Image.Image, t: float) -> Image.Image:
    width, height = image.size
    scale = 0.18 + 0.82 * abs(1 - 2 * t)
    new_width = max(8, int(width * scale))
    scaled = image.resize((new_width, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    canvas.paste(scaled, ((width - new_width) // 2, 0), scaled)
    return canvas


def blob(image: Image.Image, x: int, y: int, radius: int, color: tuple[int, int, int, int]) -> None:
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    ImageDraw.Draw(overlay).ellipse(
        (x - radius, y - radius, x + radius, y + radius),
        fill=color,
    )
    image.alpha_composite(overlay)


def ring(image: Image.Image, radius: int, color: tuple[int, int, int, int], width: int = 4) -> Image.Image:
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cx, cy = image.width // 2, image.height // 2
    draw.ellipse(
        (cx - radius, cy - radius, cx + radius, cy + radius),
        outline=color,
        width=width,
    )
    return Image.alpha_composite(image, overlay)


def write_sheet(name: str, frames: list[Image.Image]) -> None:
    width, height = frames[0].size
    sheet = Image.new("RGBA", (width * len(frames), height), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.paste(frame, (index * width, 0), frame)
    out = ROOT / name
    sheet.save(out)
    print("wrote", out.name, sheet.size)


def frames_from(source: str, box: tuple[int, int], builder) -> list[Image.Image]:
    base = fit(Image.open(ROOT / source), box)
    return [builder(base.copy(), index / (FRAMES - 1)) for index in range(FRAMES)]


def airplane(base: Image.Image, t: float) -> Image.Image:
    frame = brighten(base, 0.92 + 0.18 * t)
    width, height = frame.size
    strength = 0.45 + 0.55 * t
    radius = max(6, int(height * 0.045 * (0.7 + strength)))
    blob(frame, width // 2 - 18, height - 10, radius, (255, 43, 214, 140))
    blob(frame, width // 2 + 18, height - 10, radius + 1, (0, 245, 255, 150))
    return frame


def coin(base: Image.Image, t: float) -> Image.Image:
    return brighten(squash(base, t), 1.0 + 0.12 * (1 - abs(1 - 2 * t)))


def meteor(base: Image.Image, t: float) -> Image.Image:
    return base.rotate(t * 48, resample=Image.Resampling.BICUBIC, expand=False)


def drone(base: Image.Image, t: float) -> Image.Image:
    radius = int(min(base.size) * (0.28 + 0.16 * t))
    return ring(brighten(base, 0.95 + 0.12 * t), radius, (0, 245, 255, 160), 3)


def mine(base: Image.Image, t: float) -> Image.Image:
    radius = int(min(base.size) * (0.18 + 0.2 * t))
    return ring(brighten(base, 0.9 + 0.25 * t), radius, (255, 59, 92, 180), 4)


def barrier(base: Image.Image, t: float) -> Image.Image:
    return brighten(base, 0.88 + 0.28 * t)


def missile(base: Image.Image, t: float) -> Image.Image:
    frame = brighten(base, 0.94 + 0.12 * t)
    radius = max(8, int(frame.height * 0.06 * (0.6 + t)))
    blob(frame, frame.width // 2, 12, radius, (255, 77, 141, 170))
    blob(frame, frame.width // 2, 18, radius - 2, (255, 180, 60, 120))
    return frame


def boss(base: Image.Image, t: float) -> Image.Image:
    radius = int(min(base.size) * (0.34 + 0.12 * t))
    return ring(brighten(base, 0.92 + 0.16 * t), radius, (255, 77, 141, 150), 5)


def main() -> None:
    write_sheet("airplane_sheet.png", frames_from("airplane.png", (192, 256), airplane))
    write_sheet("coin_sheet.png", frames_from("coin.png", (192, 192), coin))
    write_sheet("gem_sheet.png", frames_from("gem.png", (192, 192), coin))
    write_sheet("meteor_sheet.png", frames_from("meteor.png", (192, 192), meteor))
    write_sheet("drone_sheet.png", frames_from("drone.png", (192, 192), drone))
    write_sheet("mine_sheet.png", frames_from("mine.png", (192, 192), mine))
    write_sheet("barrier_sheet.png", frames_from("barrier.png", (320, 160), barrier))
    write_sheet("missile_sheet.png", frames_from("missile.png", (160, 224), missile))
    for index in range(1, 6):
        write_sheet(
            f"boss_{index}_sheet.png",
            frames_from(f"boss_{index}.png", (224, 224), boss),
        )


if __name__ == "__main__":
    main()
