import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'notify.dart';
import 'screens/home.dart';
import 'screens/lock.dart';
import 'screens/onboarding.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final store = Store()..notifier = Notifier();
  runApp(App(store));
  await store.start();
  // After start: permission prompt and a notification that launched the app need the UI and the Home screen.
  // Each step on its own, so a failing one (e.g. a refused permission) does not stop the background sync being set up.
  for (final step in [
    () async => store.notifier!.init(await store.timeZone()),
    store.reschedule,
    store.scheduleBackground,
  ]) {
    try {
      await step();
    } catch (_) {}
  }
}

/// Run by Android's JobScheduler (SyncJob.kt) without the app on screen: fetch the current year, then reminders,
/// invitation notifications and widgets follow from the same sync code. Always reports back so the job ends.
@pragma('vm:entry-point')
Future<void> backgroundSync() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final store = Store()..notifier = Notifier();
  try {
    await store.start(background: true);
    if (store.signedIn) {
      await store.notifier!.init(await store.timeZone(), background: true);
      await store.syncNow();
    }
    // The result shows in Settings → Accounts, since this run has no screen.
    await store.noteBackground(store.error ?? (store.signedIn ? 'ok' : 'signed out'));
  } catch (e) {
    // offline or no silent access: the next run or opening the app tries again
    try {
      await store.noteBackground('$e');
    } catch (_) {}
  }
  await const MethodChannel('calendar/device').invokeMethod<void>('done');
}

class App extends StatelessWidget {
  const App(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) {
        store.applyLook();
        return MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (c) => AppLocalizations.of(c)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: store.ready && store.language != 'system' ? Locale(store.language) : null,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        builder: (context, child) => Lock(store, child: child!),
        themeMode: !store.ready ? ThemeMode.system : switch (store.theme) { 'dark' => ThemeMode.dark, 'light' => ThemeMode.light, _ => ThemeMode.system },
        home: !store.ready
            ? const Scaffold()
            : store.onboarded
                ? Home(store)
                : Language(store),
      );
      });
}
