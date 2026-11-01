"""Widget picker previews (07.1/07.2): draws each widget like Widgets.kt with the app fonts and the mockup's sample
day, in Polish and English, light and dark, into res/drawable-*-nodpi/widget_preview_<name>.png.

Run from the repo root after changing a widget's look:  python tool/widget_previews.py
"""
import os
from PIL import Image, ImageDraw, ImageFont

S = 3  # pixels per dp
RES = 'android/app/src/main/res'
FONTS = 'assets/fonts'

COLORS = {
    False: dict(surface='#FFFFFF', border='#E2E2E2', display='#000000', primary='#1A1A1A', secondary='#666666',
                accent='#D71921', dot_off='#D0D0D0', bg='#F4F4F4', red='#D71921', disabled='#999999', warning='#8A6500',
                raised='#E8E8E8'),
    True: dict(surface='#111111', border='#222222', display='#FFFFFF', primary='#E8E8E8', secondary='#999999',
               accent='#FF4D55', dot_off='#333333', bg='#000000', red='#D71921', disabled='#666666', warning='#D4A843',
               raised='#1A1A1A'),
}
TEXT = {
    'pl': dict(weekday='PIĄTEK', month='PAŹDZIERNIK', month_short='PAŹ', weekdays='PN WT ŚR CZ PT SB ND'.split(),
               more='JESZCZE 3', soon='ZA 12 MIN', soon15='ZA 15 MIN', events=[('14:00', 'Demo sprintu'), ('17:30', 'Trening'), ('20:00', 'Kolacja u rodziców')]),
    'en': dict(weekday='FRIDAY', month='OCTOBER', month_short='OCT', weekdays='MO TU WE TH FR SA SU'.split(),
               more='3 MORE', soon='IN 12 MIN', soon15='IN 15 MIN', events=[('14:00', 'Sprint demo'), ('17:30', 'Workout'), ('20:00', 'Dinner with family')]),
}
TODAY, MONTH_DAYS, FIRST_COL = 30, 31, 3  # Friday 30 October 2026; 1 October is a Thursday


def font(name, size_dp):
    return ImageFont.truetype(os.path.join(FONTS, name), int(size_dp * S))


def dot(size): return font('Ndot57-Regular.otf', size)
def mono(size): return font('LetteraMonoLL-Regular.otf', size)
def sans(size): return font('SpaceGrotesk-Regular.otf', size)  # NType82 lacks Polish letters; previews use its fallback


class Canvas:
    def __init__(self, w_dp, h_dp, dark):
        self.w, self.h = w_dp * S, h_dp * S
        self.c = COLORS[dark]
        self.im = Image.new('RGBA', (self.w, self.h), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)

    def card(self, radius_dp):
        r = min(radius_dp * S, self.h // 2, self.w // 2)
        self.d.rounded_rectangle([0, 0, self.w - 1, self.h - 1], radius=r, fill=self.c['surface'], outline=self.c['border'], width=S)

    @staticmethod
    def cap(f):
        l, t, r, b = f.getbbox('0H', anchor='ls')
        return -t

    def width(self, s, f, track):
        return sum(f.getlength(ch) for ch in s) + track * f.size * max(len(s) - 1, 0)

    def text(self, s, x, base, f, color, align='l', track=0.0, max_w=None):
        """Draws at baseline [base]; [track] is letter spacing in em, as Android's letterSpacing; cut with … past [max_w]."""
        if max_w is not None and self.width(s, f, track) > max_w:
            while s and self.width(s + '…', f, track) > max_w:
                s = s[:-1]
            s += '…'
        w = self.width(s, f, track)
        x = x - w if align == 'r' else x - w / 2 if align == 'm' else x
        for ch in s:
            self.d.text((x, base), ch, font=f, fill=self.c[color], anchor='ls')
            x += f.getlength(ch) + track * f.size

    def top(self, s, x, top, f, color, align='l', track=0.0):
        self.text(s, x, top + self.cap(f), f, color, align, track)

    def mid(self, s, x, cy, f, color, align='l', track=0.0, max_w=None):
        self.text(s, x, cy + self.cap(f) / 2, f, color, align, track, max_w)

    def circle(self, cx, cy, r, color):
        self.d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=self.c[color])


def label(): return mono(11)
LT = 0.08  # label tracking


def month(cv, t):
    cv.card(24)
    pad = 24 * S
    cv.top(t['month'], pad, pad, label(), 'display', track=LT)
    cv.top('2026', cv.w - pad, pad, mono(12), 'secondary', 'r')
    cell = (cv.w - 2 * pad) / 7
    labels_y = pad + 36 * S
    for i, wd in enumerate(t['weekdays']):
        cv.mid(wd, pad + cell * i + cell / 2, labels_y, label(), 'secondary', 'm', LT)
    rows = (FIRST_COL + MONTH_DAYS + 6) // 7
    grid_top = labels_y + 12 * S
    row_h = (cv.h - grid_top - pad * 0.75) / rows
    r = min(16 * S, row_h / 2 - 2 * S, cell / 2 - 2 * S)
    for d in range(1, MONTH_DAYS + 1):
        i = FIRST_COL + d - 1
        cx, cy = pad + cell * (i % 7) + cell / 2, grid_top + row_h * (i // 7) + row_h / 2
        if d == TODAY:
            cv.circle(cx, cy, r, 'display')
        cv.mid(str(d), cx, cy, dot(20), 'surface' if d == TODAY else 'secondary' if d < TODAY else 'display', 'm')


def today(cv, t):
    cv.card(24)
    px, py = 24 * S, 20 * S
    cv.top(t['weekday'], px, py, label(), 'display', track=LT)
    cv.mid(str(TODAY), px, cv.h / 2, dot(56), 'display')
    cv.text(t['month'], px, cv.h - py, mono(12), 'secondary')
    left, right = px + 128 * S, cv.w - px
    cv.top(t['more'], left, py, label(), 'secondary', track=LT)
    cv.top(t['soon'], right, py, label(), 'accent', 'r', LT)
    rows_top = py + 20 * S
    row_h = (cv.h - py - rows_top) / 3
    for i, (time, title) in enumerate(t['events']):
        y = rows_top + row_h * i
        cv.d.line([left, y, right, y], fill=cv.c['border'], width=S)
        cv.mid(time, left, y + row_h / 2, mono(12), 'display' if i == 0 else 'secondary')
        cv.mid(title, left + 48 * S, y + row_h / 2, sans(14), 'display' if i == 0 else 'primary', max_w=right - left - 48 * S)


def week(cv, t):
    cv.card(999)
    pad = 24 * S
    step = (cv.w - 2 * pad) / 7
    block_top = (cv.h - 48 * S) / 2
    for i, wd in enumerate(t['weekdays']):
        n = 26 + i if 26 + i <= 31 else 26 + i - 31
        is_today = n == TODAY
        cx = pad + step * i + step / 2
        cv.mid(wd, cx, block_top + 6 * S, label(), 'display' if is_today else 'secondary', 'm', LT)
        if is_today:
            cv.circle(cx, block_top + 32 * S, min(16 * S, step / 2 - S), 'display')
        cv.mid(str(n), cx, block_top + 32 * S, dot(20), 'surface' if is_today else 'primary', 'm')


def date(cv, t):
    cv.card(24)
    mask = Image.new('L', cv.im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, cv.w - 1, cv.h - 1], radius=24 * S, fill=255)
    dots = Image.new('RGBA', cv.im.size, (0, 0, 0, 0))
    dd = ImageDraw.Draw(dots)
    for y in range(5 * S, cv.h - 2 * S, 10 * S):
        for x in range(5 * S, cv.w - 2 * S, 10 * S):
            dd.ellipse([x - S, y - S, x + S, y + S], fill=cv.c['dot_off'])
    cv.im.paste(dots, (0, 0), Image.composite(dots, Image.new('RGBA', cv.im.size), mask))
    pad = 20 * S
    cv.top(t['weekday'], pad, pad, label(), 'display', track=LT)
    cv.text(str(TODAY), pad, cv.h - pad, dot(56), 'display')
    cv.text(t['month_short'], cv.w - pad, cv.h - pad, mono(12), 'secondary', 'r')


def next_big(cv, t):
    cv.card(24)
    pad = 20 * S
    cv.top(t['soon'], pad, pad, label(), 'accent', track=LT)
    cv.text(t['events'][0][1], pad, cv.h - pad, sans(14), 'primary')
    cv.text(t['events'][0][0], pad, cv.h - pad - 24 * S, dot(40), 'display')


def next_small(cv, t):
    cv.card(999)
    gap = 8 * S
    lf, tf = label(), dot(40)
    top = (cv.h - (cv.cap(lf) + gap + cv.cap(tf))) / 2
    cv.top(t['soon'], cv.w / 2, top, lf, 'accent', 'm', LT)
    cv.top(t['events'][0][0], cv.w / 2, top + cv.cap(lf) + gap, tf, 'display', 'm')


def day_small(cv, t):
    r = min(cv.w, cv.h) / 2
    cv.d.ellipse([cv.w / 2 - r, cv.h / 2 - r, cv.w / 2 + r - 1, cv.h / 2 + r - 1], fill=cv.c['surface'], outline=cv.c['border'], width=S)
    cv.mid(str(TODAY), cv.w / 2, cv.h / 2, dot(40), 'display', 'm')


def clock(cv, t):
    """Day clock (ClockWidget): 24-hour dial at 13:48 on the sample day."""
    import math
    cv.card(24)
    cx, cy = cv.w / 2, cv.h / 2
    outer = cv.w / 2 - 8 * S
    ring = outer - 25 * S
    stroke = 9 * S

    def at(r, deg):
        return cx + r * math.cos(math.radians(deg)), cy + r * math.sin(math.radians(deg))

    def ang(h):
        return h / 24 * 360 - 90

    for hr in range(24):
        x, y = at(outer, hr * 15 - 90)
        main = hr % 6 == 0
        r = (2 if main else 1.2) * S
        cv.d.ellipse([x - r, y - r, x + r, y + r], fill=cv.c['secondary' if main else 'dot_off'])
        if main:
            lx, ly = at(outer - 11 * S, hr * 15 - 90)
            cv.mid('%02d' % hr, lx, ly, mono(10), 'secondary', 'm', LT)
    box = [cx - ring - stroke / 2, cy - ring - stroke / 2, cx + ring + stroke / 2, cy + ring + stroke / 2]
    cv.d.arc(box, 0, 360, fill=cv.c['raised'], width=stroke)
    for a, b, color in [(8.5, 9, 'disabled'), (10, 11.5, 'disabled'), (12.5, 13.25, 'disabled'), (14, 15, 'display'),
                        (14.5, 15.5, 'warning'), (17.5, 18.5, 'display'), (20, 21.5, 'display')]:
        cv.d.arc(box, ang(a) + 0.6, ang(b) - 0.6, fill=cv.c[color], width=stroke)
    now = 13 + 48 / 60
    x1, y1 = at(ring - stroke * 1.6, ang(now))
    x2, y2 = at(ring + stroke * 0.9, ang(now))
    cv.d.line([x1, y1, x2, y2], fill=cv.c['red'], width=int(1.5 * S))
    cv.d.ellipse([x2 - 3 * S, y2 - 3 * S, x2 + 3 * S, y2 + 3 * S], fill=cv.c['red'])
    big, lf, tf = dot(24), mono(10), sans(12)
    g1, g2 = 6 * S, 7 * S
    top = cy - (cv.cap(big) + g1 + cv.cap(lf) + g2 + cv.cap(tf)) / 2
    cv.top(t['events'][0][0], cx, top, big, 'display', 'm')
    top += cv.cap(big) + g1
    cv.top(t['soon15'], cx, top, lf, 'accent', 'm', LT)
    top += cv.cap(lf) + g2
    cv.top(t['events'][0][1], cx, top, tf, 'primary', 'm')


WIDGETS = {'month': (month, 336, 336), 'today': (today, 336, 160), 'week': (week, 336, 72), 'date': (date, 160, 160),
           'next': (next_big, 160, 160), 'next_small': (next_small, 160, 72), 'day_small': (day_small, 72, 72),
           'clock': (clock, 170, 170)}

if __name__ == '__main__':
    for lang, folder_lang in [('en', ''), ('pl', '-pl')]:
        for dark in (False, True):
            folder = f'{RES}/drawable{folder_lang}{"-night" if dark else ""}-nodpi'
            os.makedirs(folder, exist_ok=True)
            for name, (fn, w, h) in WIDGETS.items():
                cv = Canvas(w, h, dark)
                fn(cv, TEXT[lang])
                cv.im.save(f'{folder}/widget_preview_{name}.png', optimize=True)
    print('ok')
