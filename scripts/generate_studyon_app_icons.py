#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path("/Users/bagjun-won/studyon")
APP_DIR = ROOT / "apps" / "studyon_client"
IOS_ICON_DIR = APP_DIR / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
ANDROID_RES_DIR = APP_DIR / "android" / "app" / "src" / "main" / "res"
PREVIEW_PATH = APP_DIR / "assets" / "images" / "app_icon_preview.png"

BACKGROUND = "#6E5CF5"
GREEN = "#12C46B"
BLUE = "#45D9FF"
YELLOW = "#FFC64D"
WHITE = "#FFFFFF"


def draw_shadow(size: int) -> Image.Image:
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    center_x = size / 2
    top = size * 0.24
    bar_height = size * 0.14
    gap = size * 0.045
    widths = [size * 0.40, size * 0.375, size * 0.35]

    for i, width in enumerate(widths):
        y0 = top + i * (bar_height + gap)
        x0 = center_x - width / 2
        x1 = x0 + width
        y1 = y0 + bar_height
        radius = bar_height / 2
        shadow_draw.rounded_rectangle(
            [
                x0 + size * 0.01,
                y0 + size * 0.018,
                x1 + size * 0.01,
                y1 + size * 0.018,
            ],
            radius=radius,
            fill=(36, 20, 112, 90),
        )

    return shadow.filter(ImageFilter.GaussianBlur(radius=size * 0.012))


def draw_logo(draw: ImageDraw.ImageDraw, size: int) -> None:
    center_x = size / 2
    top = size * 0.24
    bar_height = size * 0.14
    gap = size * 0.045
    widths = [size * 0.40, size * 0.375, size * 0.35]
    colors = [GREEN, BLUE, YELLOW]

    for i, (width, color) in enumerate(zip(widths, colors)):
        y0 = top + i * (bar_height + gap)
        x0 = center_x - width / 2
        x1 = x0 + width
        y1 = y0 + bar_height
        radius = bar_height / 2

        draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=color)

        capsule_margin = bar_height * 0.12
        capsule_w = bar_height * 1.28
        capsule_h = bar_height * 0.76
        cx1 = x1 - capsule_margin
        cx0 = cx1 - capsule_w
        cy0 = y0 + (bar_height - capsule_h) / 2
        cy1 = cy0 + capsule_h

        draw.rounded_rectangle(
            [cx0, cy0, cx1, cy1],
            radius=capsule_h / 2,
            fill=WHITE,
        )

        line_w = capsule_w * 0.44
        line_h = max(2, size * 0.012)
        lx0 = cx0 + (capsule_w - line_w) / 2
        ly0 = cy0 + (capsule_h - line_h) / 2
        lx1 = lx0 + line_w
        ly1 = ly0 + line_h
        draw.rounded_rectangle(
            [lx0, ly0, lx1, ly1],
            radius=line_h / 2,
            fill=color,
        )


def render_icon(size: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), BACKGROUND)
    shadow = draw_shadow(size)
    image.alpha_composite(shadow)

    draw = ImageDraw.Draw(image)
    draw_logo(draw, size)
    return image


def write_ios_icons(master: Image.Image) -> None:
    for path in IOS_ICON_DIR.glob("*.png"):
        target_size = Image.open(path).size[0]
        master.resize((target_size, target_size), Image.Resampling.LANCZOS).save(path)


def write_android_icons(master: Image.Image) -> None:
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for directory, size in sizes.items():
        path = ANDROID_RES_DIR / directory / "ic_launcher.png"
        master.resize((size, size), Image.Resampling.LANCZOS).save(path)


def main() -> None:
    master = render_icon(1024)
    PREVIEW_PATH.parent.mkdir(parents=True, exist_ok=True)
    master.save(PREVIEW_PATH)
    write_ios_icons(master)
    write_android_icons(master)


if __name__ == "__main__":
    main()
