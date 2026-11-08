"""README images: a banner, framed screenshot rows, the welcome screen in every language, the widgets and the Glyph
matrix countdown. Screenshots come from the app's own tests, rendered in English:

  $env:CAL_LANG='en'; $env:CAL_SHOTS='<shots>'; flutter test test/screens_test.dart
  (and once per language into <shots>/<lang> with --plain-name "screens welcome")
  python tool/readme_images.py <shots>

Writes docs/images/*.png.
"""
import math
import os
import sys
from PIL import Image, ImageDraw, ImageFont

SHOTS = sys.argv[1]
OUT = 'docs/images'
FONTS = 'assets/fonts'
BG = (0, 0, 0)
DOT = (28, 28, 28)
WHITE = (255, 255, 255)
GREY = (153, 153, 153)
RED = (215, 25, 33)
os.makedirs(OUT, exist_ok=True)


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), size)


def dotted(w, h, step=24):
    """Black background with the mockup's faint dot grid."""
    im = Image.new('RGB', (w, h), BG)
    d = ImageDraw.Draw(im)
    for y in range(step // 2, h, step):
        for x in range(step // 2, w, step):
            d.ellipse((x - 1.5, y - 1.5, x + 1.5, y + 1.5), fill=DOT)
    return im


def phone(name, width=390):
    """A screenshot in a thin rounded phone frame."""
    shot = Image.open(os.path.join(SHOTS, name + '.png')).convert('RGB')
    shot = shot.resize((width, round(shot.height * width / shot.width)), Image.LANCZOS)
    pad, r = 10, 44
    w, h = shot.width + pad * 2, shot.height + pad * 2
    frame = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(frame)
    d.rounded_rectangle((0, 0, w - 1, h - 1), r, fill=(10, 10, 10), outline=(58, 58, 58), width=2)
    mask = Image.new('L', shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, shot.width - 1, shot.height - 1), r - pad, fill=255)
    frame.paste(shot, (pad, pad), mask)
    return frame


def row(names, out, gap=36, margin=48, width=390, captions=None):
    """Framed screenshots side by side on the dot grid, with small captions under them."""
    frames = [phone(n, width) for n in names]
    cap_h = 56 if captions else 0
    w = sum(f.width for f in frames) + gap * (len(frames) - 1) + margin * 2
    h = max(f.height for f in frames) + margin * 2 + cap_h
    im = dotted(w, h)
    d = ImageDraw.Draw(im)
    f = font('LetteraMonoLL-Regular.otf', 22)
    x = margin
    for i, fr in enumerate(frames):
        im.paste(fr, (x, margin), fr)
        if captions:
            t = captions[i].upper()
            tw = d.textlength(t, font=f)
            d.text((x + (fr.width - tw) / 2, margin + fr.height + 18), t, font=f, fill=GREY)
        x += fr.width + gap
    im.save(os.path.join(OUT, out), optimize=True)


def banner():
    w, h = 2400, 1100
    im = dotted(w, h, 30)
    d = ImageDraw.Draw(im)
    d.text((140, 250), 'CALENDAR', font=font('Ndot57-Regular.otf', 190), fill=WHITE)
    d.ellipse((140, 520, 172, 552), fill=RED)
    d.text((196, 512), 'Your time, without the noise.', font=font('NType82-Regular.otf', 56), fill=WHITE)
    mono = font('LetteraMonoLL-Regular.otf', 30)
    for i, line in enumerate(['GOOGLE CALENDAR OR FULLY OFFLINE', 'NO SERVER · NO ADS · NO TRACKING',
                              'ANDROID · 8 LANGUAGES · GLYPH']):
        d.text((140, 650 + i * 52), line, font=mono, fill=GREY)
    # Three phones on the right, the middle one raised.
    for name, x, y in [('02_4_day', 1250, 190), ('02_2_month', 1630, 110), ('03_1_event', 2010, 190)]:
        fr = phone(name, 340)
        im.paste(fr, (x, y), fr)
    im = im.crop((0, 0, w, h))
    im.save(os.path.join(OUT, 'banner.png'), optimize=True)


def languages():
    langs = [('pl', 'Polski'), ('en', 'English'), ('de', 'Deutsch'), ('es', 'Español'),
             ('fr', 'Français'), ('it', 'Italiano'), ('pt', 'Português'), ('nl', 'Nederlands')]
    frames = []
    for code, _ in langs:
        shot = Image.open(os.path.join(SHOTS, code, '01_1_welcome.png')).convert('RGB')
        shot.save(os.path.join(SHOTS, f'welcome_{code}.png'))
        frames.append(f'welcome_{code}')
    row(frames[:4], 'languages-1.png', width=300, captions=[n for _, n in langs[:4]])
    row(frames[4:], 'languages-2.png', width=300, captions=[n for _, n in langs[4:]])


def glyph():
    """The approved matrix countdown (DECISIONS: glass, clock A, 3x3 plus) as LEDs, like Lights.matrix."""
    n, led = 25, 14
    states = [('glass', 1, '60 MIN'), ('glass', .75, '45 MIN'), ('glass', .5, '30 MIN'), ('glass', .25, '15 MIN'),
              ('clock', .5, 'CLOCK · 30'), ('plus', -1, 'LATER TODAY')]
    size = n * led
    gap, margin = 56, 60
    im = dotted(margin * 2 + len(states) * size + gap * (len(states) - 1), size + margin * 2 + 60)
    d = ImageDraw.Draw(im)
    f = font('LetteraMonoLL-Regular.otf', 22)
    c, R = (n - 1) / 2, n / 2 - .5
    r = R - 2
    for k, (style, fill, label) in enumerate(states):
        ox = margin + k * (size + gap)
        d.ellipse((ox - 6, margin - 6, ox + size + 6, margin + size + 6), fill=(8, 8, 8))
        for y in range(n):
            for x in range(n):
                dx, dy = x - c, y - c
                if math.hypot(dx, dy) > R + .2:
                    continue
                if fill < 0:
                    on = (dx == 0 and abs(dy) <= 1) or (dy == 0 and abs(dx) <= 1)
                elif math.hypot(dx, dy) > r + .3:
                    on = False
                elif style == 'clock':
                    a = math.atan2(-dx, -dy) % (2 * math.pi)
                    on = a <= fill * 2 * math.pi + 1e-6
                else:
                    on = y >= c - r + (1 - fill) * 2 * r - .01
                px, py = ox + x * led + led / 2, margin + y * led + led / 2
                d.ellipse((px - 5, py - 5, px + 5, py + 5), fill=(242, 242, 242) if on else (38, 38, 38))
        tw = d.textlength(label, font=f)
        d.text((ox + (size - tw) / 2, margin + size + 24), label, font=f, fill=GREY)
    im.save(os.path.join(OUT, 'glyph.png'), optimize=True)


def widgets():
    r = 'android/app/src/main/res/drawable-night-nodpi/widget_preview_'
    rows = [['month', 'today'], ['clock', 'next', 'date', 'day_small'], ['week', 'next_small']]
    gap, margin = 36, 60
    ims = [[Image.open(r + n + '.png').convert('RGBA') for n in rw] for rw in rows]
    w = max(sum(i.width for i in rw) + gap * (len(rw) - 1) for rw in ims) + margin * 2
    h = sum(max(i.height for i in rw) for rw in ims) + gap * (len(ims) - 1) + margin * 2
    im = dotted(w, h).convert('RGBA')
    y = margin
    for rw in ims:
        x = margin
        top = max(i.height for i in rw)
        for i in rw:
            im.alpha_composite(i, (x, y + (top - i.height) // 2))
            x += i.width + gap
        y += top + gap
    im.convert('RGB').save(os.path.join(OUT, 'widgets.png'), optimize=True)


banner()
row(['02_1_year', '02_2_month', '02_3_week', '02_4_day'], 'views.png', captions=['Year', 'Month', 'Week', 'Day'])
row(['03_1_event', '03_2_new_event', '03_3_custom_repeat', '03_5_invitation'], 'events.png',
    captions=['Details', 'New event', 'Repeat', 'Invitation'])
row(['04_1_calendars', '04_2_add_calendar', '04_3_holidays', '04_4_share'], 'calendars.png',
    captions=['Calendars', 'Add calendar', 'Holidays', 'Sharing'])
row(['02_2_month', '02_2_month_light', '02_5_search', '06_3_conflict'], 'more.png',
    captions=['Dark', 'Light', 'Search', 'Edit conflict'])
row(['05_1_settings', '05_2_appearance', '05_3_notifications_glyph', '05_4_accounts'], 'settings.png',
    captions=['Settings', 'Appearance', 'Notifications', 'Accounts'])
languages()
glyph()
widgets()
for old in os.listdir(OUT):  # single screenshots from the first README draft
    if old not in {'banner.png', 'views.png', 'events.png', 'calendars.png', 'more.png', 'settings.png', 'languages-1.png',
                   'languages-2.png', 'glyph.png', 'widgets.png'}:
        os.remove(os.path.join(OUT, old))
print(sorted(os.listdir(OUT)))
