import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'google.dart';
import 'l10n/app_localizations.dart';
import 'store.dart';
import 'theme.dart';

/// Shared building blocks matching the mockup's CSS classes (.lbl, .row, .sec, .btn, .sw, .mk, .hero...).

AppLocalizations l10n(BuildContext c) => AppLocalizations.of(c)!;
String loc(BuildContext c) => Localizations.localeOf(c).toString();
String hm(BuildContext c, DateTime t) => DateFormat.Hm(loc(c)).format(t);

/// Uppercase small mono label (.lbl).
class Lbl extends StatelessWidget {
  const Lbl(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: T.labelSm(color ?? Tok.of(context).secondary), overflow: TextOverflow.ellipsis);
}

/// Calendar marker (.mk and its variants).
class Marker extends StatelessWidget {
  const Marker(this.shape, {super.key});
  final Shape shape;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(10, 10), painter: _MarkerPainter(shape, Tok.of(context).display));
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter(this.shape, this.color);
  final Shape shape;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final c = size.center(Offset.zero);
    switch (shape) {
      case Shape.dot:
        canvas.drawCircle(c, 5, fill);
      case Shape.square:
        canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)), fill);
      case Shape.half:
        canvas.drawCircle(c, 4.25, line);
        canvas.drawArc(Rect.fromCircle(center: c, radius: 4.25), 1.5708, 3.1416, true, fill);
      case Shape.diamond:
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(0.7854);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 8, height: 8), const Radius.circular(1)), fill);
        canvas.restore();
      case Shape.ring:
        canvas.drawCircle(c, 4.25, line);
      case Shape.dash:
        for (var i = 0; i < 8; i++) {
          canvas.drawArc(Rect.fromCircle(center: c, radius: 4.25), i * 0.7854, 0.45, false, line);
        }
    }
  }

  @override
  bool shouldRepaint(_MarkerPainter old) => old.shape != shape || old.color != color;
}

/// List row with a bottom hairline (.row).
class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.children, this.onTap, this.border = true});
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool border;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
              border: border ? Border(bottom: BorderSide(color: Tok.of(context).borderSubtle)) : null),
          child: Row(spacing: 16, children: children),
        ),
      );
}

/// Section with header row (.sec + .sec-h).
class Section extends StatelessWidget {
  const Section({super.key, required this.left, this.right, this.trailing, required this.children, this.leftColor});
  final String left;
  final String? right;
  final Widget? trailing;
  final Color? leftColor;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Tok.of(context).borderSubtle))),
            child: Row(children: [
              Expanded(child: Lbl(left, color: leftColor)),
              if (right != null) Lbl(right!),
              ?trailing,
            ]),
          ),
          ...children,
        ]),
      );
}

/// Pill switch (.sw).
class Toggle extends StatelessWidget {
  const Toggle({super.key, required this.value, required this.onChanged, required this.label});
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.2, 0, 0, 1),
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? t.display : null,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: value ? t.display : t.borderControl),
          ),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: value ? t.bg : t.secondary, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

/// Pill button (.btn-p primary, .btn-t text).
class Btn extends StatelessWidget {
  const Btn(this.text, {super.key, required this.onTap, this.primary = true, this.busy = false});
  final String text;
  final VoidCallback? onTap;
  final bool primary, busy;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final fg = primary ? t.bg : t.primary;
    return Material(
      color: primary ? t.display : Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: busy ? null : onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: busy
                ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: fg))
                : Text(text.toUpperCase(), style: T.labelMd(fg), maxLines: 1),
          ),
        ),
      ),
    );
  }
}

/// 44px round icon button (.ib).
class IconBtn extends StatelessWidget {
  const IconBtn(this.icon, {super.key, required this.onTap, required this.label});
  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        tooltip: label,
        icon: Icon(icon, size: 24, color: Tok.of(context).primary),
        padding: EdgeInsets.zero,
        // Material 3 pads icon buttons to 48px; the mockup's .ib is 44px.
        style: IconButton.styleFrom(minimumSize: const Size(44, 44), fixedSize: const Size(44, 44), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      );
}

/// "Back" link at the top of sub screens (.back).
class BackBar extends StatelessWidget {
  const BackBar({super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(mainAxisSize: MainAxisSize.min, spacing: 2, children: [
                Icon(Icons.chevron_left, size: 20, color: Tok.of(context).secondary),
                Lbl(l10n(context).back),
              ]),
            ),
          ),
        ),
      );
}

/// Big number + label/caption with prev/next arrows (.hero).
class Hero2 extends StatelessWidget {
  const Hero2({super.key, required this.big, required this.title, required this.caption, required this.onMove, this.xl = false});
  final String big, title, caption;
  final ValueChanged<int> onMove;
  final bool xl;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        height: 56,
        child: Row(children: [
          Text(big, style: xl ? T.displayXl(t.display) : T.displayLg(t.display)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [
              Semantics(header: true, child: Lbl(title, color: t.display)),
              Text(caption, style: T.caption(t.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          // margin-right: -10px from the mockup: the arrows' touch area runs into the gutter, leaving room for the caption.
          SizedBox(
            width: 78,
            child: OverflowBox(
              maxWidth: 88,
              alignment: Alignment.centerLeft,
              child: Row(children: [
              IconBtn(Icons.chevron_left, onTap: () => onMove(-1), label: l10n(context).previous),
              IconBtn(Icons.chevron_right, onTap: () => onMove(1), label: l10n(context).following),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// One event line: time, marker, title, location or "in N min" (.row in day/month lists).
class EventRow extends StatelessWidget {
  const EventRow(this.e, this.store, {super.key, this.now, this.border = true, this.red = true});
  final Ev e;
  final Store store;
  final DateTime? now;
  final bool border;
  final bool red; // the mockup allows one red mark per screen; the day view spends it on the now line
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final n = now ?? DateTime.now();
    final past = !e.allDay && !e.end.isAfter(n);
    final soon = (e.start.difference(n).inSeconds + 59) ~/ 60;
    final cal = store.cal(e.calId);
    return RowItem(border: border, children: [
      SizedBox(
        width: 48,
        // Like the mockup's span, the time never wraps; it may run a hair past the 48px column.
        child: e.allDay
            ? null
            : Text(hm(context, e.start), softWrap: false, overflow: TextOverflow.visible, style: T.labelMd(past ? t.secondary : t.display)),
      ),
      Marker(cal?.shape ?? Shape.dot),
      Expanded(
        child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.body(past ? t.secondary : t.primary)),
      ),
      if (!e.allDay && e.start.isAfter(n) && soon <= 60)
        Lbl(l10n(context).inMin(soon), color: red ? t.accentText : t.primary)
      else if ((e.location ?? cal?.name) case final s? when s.isNotEmpty)
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 110), child: Lbl(s)),
    ]);
  }
}

/// Splits a day's events into all-day and timed lists.
(List<Ev>, List<Ev>) splitAllDay(List<Ev> evs) =>
    (evs.where((e) => e.allDay).toList(), evs.where((e) => !e.allDay).toList());
