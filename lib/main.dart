import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'notify.dart';
import 'screens/home.dart';
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
  await store.notifier!.init(await store.timeZone());
  await store.reschedule();
  await store.scheduleBackground();
}

/// Run by Android's JobScheduler (SyncJob.kt) without the app on screen: fetch the current year, then reminders,
/// invitation notifications and widgets follow from the same sync code. Always reports back so the job ends.
@pragma('vm:entry-point')
Future<void> backgroundSync() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  try {
    final store = Store()..notifier = Notifier();
    await store.start(background: true);
    if (store.signedIn) {
      await store.notifier!.init(await store.timeZone(), background: true);
      await store.syncNow();
    }
  } catch (_) {
    // offline or no silent access: the next run or opening the app tries again
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
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: !store.ready ? ThemeMode.system : switch (store.theme) { 'dark' => ThemeMode.dark, 'light' => ThemeMode.light, _ => ThemeMode.system },
        home: !store.ready
            ? const Scaffold()
            : store.onboarded
                ? Home(store)
                : Welcome(store),
      );
      });
}
