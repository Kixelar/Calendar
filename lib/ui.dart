import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'google.dart';
import 'l10n/app_localizations.dart';
import 'screens/event.dart';
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
  const Marker(this.shape, {super.key, this.color});
  final Shape shape;
  final Color? color; // defaults to the display colour; inverted inside a pressed chip
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(10, 10), painter: _MarkerPainter(shape, color ?? Tok.of(context).display));
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

/// Pill button styles: .btn-p primary, .btn-s outlined, .btn-d destructive red, .btn-t text only.
enum BtnKind { primary, secondary, danger, text }

/// Pill button (.btn).
class Btn extends StatelessWidget {
  const Btn(this.text, {super.key, required this.onTap, this.kind = BtnKind.primary, this.busy = false, this.icon});
  final String text;
  final VoidCallback? onTap;
  final BtnKind kind;
  final bool busy;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final (bg, fg) = switch (kind) {
      BtnKind.primary => (t.display, t.bg),
      BtnKind.secondary => (Colors.transparent, t.display),
      BtnKind.danger => (t.accent, Colors.white),
      BtnKind.text => (Colors.transparent, t.primary),
    };
    return Material(
      color: bg,
      shape: StadiumBorder(side: kind == BtnKind.secondary ? BorderSide(color: t.borderControl) : BorderSide.none),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: busy ? null : onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: busy
              ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: fg))
              : Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
                  if (icon != null) Icon(icon, size: 20, color: fg),
                  // Shrinks a label that is a few pixels too wide (Lettera Mono is broad) instead of cutting it.
                  Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(text.toUpperCase(), style: T.labelMd(fg), maxLines: 1))),
                ]),
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
  const BackBar({super.key, this.label, this.actions = const []});
  final String? label; // defaults to "Back"
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: SizedBox(
          height: 44,
          child: Row(children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(mainAxisSize: MainAxisSize.min, spacing: 2, children: [
                Icon(Icons.chevron_left, size: 20, color: Tok.of(context).secondary),
                Lbl(label ?? l10n(context).back),
              ]),
            ),
            const Spacer(),
            ...actions,
          ]),
        ),
      );
}

/// Block of rows with a top hairline, 32px below the previous block (.grp).
class Group extends StatelessWidget {
  const Group({super.key, required this.children, this.gap = 32});
  final List<Widget> children;
  final double gap; // 0 inside dialogs, where the parent already spaces its blocks
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(top: gap),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Tok.of(context).borderSubtle))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}

/// Settings-style row: label on the left, value and optional chevron on the right.
class ValueRow extends StatelessWidget {
  const ValueRow(this.label, {super.key, this.value, this.valueColor, this.trailing, this.onTap});
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => RowItem(onTap: onTap, children: [
        Expanded(child: Text(label)),
        if (value != null) ConstrainedBox(constraints: const BoxConstraints(maxWidth: 170), child: Lbl(value!, color: valueColor)),
        ?trailing,
        if (onTap != null) Icon(Icons.chevron_right, size: 20, color: Tok.of(context).secondary),
      ]);
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
    return RowItem(border: border, onTap: () => openEvent(context, e, store), children: [
      SizedBox(
        width: 48,
        // Like the mockup's span, the time never wraps; it may run a hair past the 48px column.
        child: e.allDay
            ? Center(
                child: Icon(Icons.wb_sunny_outlined, size: 18, color: t.secondary, semanticLabel: l10n(context).allDay),
              )
            : Text(hm(context, e.start), softWrap: false, overflow: TextOverflow.visible, style: T.labelMd(past ? t.secondary : t.display)),
      ),
      Marker(cal?.shape ?? Shape.dot),
      Expanded(
        child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.body(past ? t.secondary : t.primary)),
      ),
      if (!e.allDay && e.start.isAfter(n) && soon <= 60)
        Lbl(l10n(context).inMin(soon), color: red ? t.accentText : t.primary)
      else if ((cal?.holiday ?? false ? l10n(context).holiday : e.location ?? cal?.name) case final s? when s.isNotEmpty)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Marquee(s.toUpperCase(), style: T.labelSm(t.secondary)),
        ),
    ]);
  }
}

/// One-line text that, when too long, scrolls to its end, pauses, jumps back and repeats.
/// Plain ellipsis when the system asks to reduce motion.
class Marquee extends StatefulWidget {
  const Marquee(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;
  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  static const _pause = 1.5, _speed = 30.0; // seconds at each end, pixels per second
  late final _c = AnimationController(vsync: this);
  double _over = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Started after the frame: changing the controller during build would rebuild listeners mid-build.
  void _run(double over) {
    if (over == _over) return;
    _over = over;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (over <= 0) {
        _c.stop();
        return;
      }
      _c.duration = Duration(milliseconds: ((2 * _pause + over / _speed) * 1000).round());
      _c.repeat();
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final over = tp.width - box.maxWidth;
        final still = over <= 0 || MediaQuery.disableAnimationsOf(context);
        _run(still ? 0 : over);
        if (still) return Text(widget.text, style: widget.style, maxLines: 1, overflow: TextOverflow.ellipsis);
        final scroll = over / _speed, total = 2 * _pause + scroll;
        return SizedBox(
          width: box.maxWidth,
          height: tp.height,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, child) {
                final s = (_c.value * total - _pause).clamp(0, scroll);
                return Transform.translate(offset: Offset(-over * s / scroll, 0), child: child);
              },
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
              ),
            ),
          ),
        );
      });
}

void openEvent(BuildContext c, Ev e, Store store) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => EventDetails(e, store)));

/// Splits a day's events into all-day and timed lists.
(List<Ev>, List<Ev>) splitAllDay(List<Ev> evs) =>
    (evs.where((e) => e.allDay).toList(), evs.where((e) => !e.allDay).toList());

/// Filter chip (.chip): pill with optional leading widget, filled when pressed.
class Chip2 extends StatelessWidget {
  const Chip2(this.label, {super.key, this.pressed = false, required this.onTap, this.leading});
  final String label;
  final bool pressed;
  final VoidCallback onTap;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Semantics(
      button: true,
      selected: pressed,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            color: pressed ? t.display : null,
            shape: StadiumBorder(side: BorderSide(color: pressed ? t.display : t.borderControl)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
            ?leading,
            Text(label.toUpperCase(), style: T.labelSm(pressed ? t.bg : t.primary)),
          ]),
        ),
      ),
    );
  }
}

/// Person initials in a circle (.av); [filled] for people already chosen (.av-f), [dashed] for "invite more".
class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.filled = false, this.icon});
  final String name;
  final bool filled;
  final IconData? icon; // shown instead of initials
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final words = name.split(RegExp(r'[\s@.]+')).where((w) => w.isNotEmpty).take(2);
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? t.display : null, border: Border.all(color: filled ? t.display : t.borderControl)),
      child: icon != null
          ? Icon(icon, size: 18, color: t.display)
          : Text(words.map((w) => w[0]).join().toUpperCase(), style: T.labelSm(filled ? t.bg : t.display)),
    );
  }
}

/// Full-screen single choice list (repeat, reminder, calendar). Pops `(value,)` so a null value differs from "back".
class Pick<V> extends StatelessWidget {
  const Pick({super.key, required this.title, required this.options, required this.selected, this.leading});
  final String title;
  final List<(V, String)> options;
  final V selected;
  final Widget Function(V)? leading;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const BackBar(),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Text(title, style: T.headlineLg(t.display)),
              Group(children: [
                for (final (v, label) in options)
                  RowItem(onTap: () => Navigator.pop(context, (v,)), children: [
                    ?leading?.call(v),
                    Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (v == selected) Icon(Icons.check, size: 20, color: t.display),
                  ]),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

Future<(V,)?> pick<V>(BuildContext c, Pick<V> page) => Navigator.push<(V,)>(c, MaterialPageRoute(builder: (_) => page));
