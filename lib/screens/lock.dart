import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../store.dart';
import '../theme.dart';
import '../ui.dart';

/// 05.5 app lock: when on, the app asks for the phone's fingerprint, face or screen lock code when it opens and when it
/// comes back after more than a minute away (short trips to a file picker or Google sign-in do not lock it).
class Lock extends StatefulWidget {
  const Lock(this.store, {super.key, required this.child});
  final Store store;
  final Widget child;
  @override
  State<Lock> createState() => _LockState();
}

class _LockState extends State<Lock> with WidgetsBindingObserver {
  bool? _locked; // null until the settings are loaded
  DateTime? _away;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden) _away ??= DateTime.now();
    if (s != AppLifecycleState.resumed) return;
    final away = _away;
    _away = null;
    if (widget.store.appLock && away != null && DateTime.now().difference(away) > const Duration(minutes: 1)) {
      setState(() => _locked = true);
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_asking) return;
    _asking = true;
    try {
      if (await askDeviceAuth(l10n(context).unlockReason) && mounted) setState(() => _locked = false);
    } finally {
      _asking = false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          if (_locked == null && widget.store.ready) {
            _locked = widget.store.appLock;
            if (_locked!) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
          }
          final t = Tok.of(context), l = l10n(context);
          return Stack(children: [
            widget.child,
            if (_locked ?? false)
              Positioned.fill(
                child: Material(
                  color: t.bg,
                  child: SafeArea(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, spacing: 16, children: [
                        Icon(Icons.lock_outline, size: 32, color: t.display),
                        Text(l.appLocked, style: T.headlineMd(t.display)),
                        IntrinsicWidth(child: Btn(l.unlock, onTap: _unlock)),
                      ]),
                    ),
                  ),
                ),
              ),
          ]);
        },
      );
}

/// Asks for the fingerprint, face or screen lock code; false when it fails, is cancelled or the phone has no lock.
Future<bool> askDeviceAuth(String reason) async {
  try {
    return await LocalAuthentication().authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
  } catch (_) {
    return false; // no screen lock, too many tries, or tests without the plugin
  }
}

/// Whether the phone has a screen lock the app lock can use.
Future<bool> deviceAuthAvailable() async {
  try {
    return await LocalAuthentication().isDeviceSupported();
  } catch (_) {
    return false;
  }
}
