import 'package:flutter/material.dart';
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
