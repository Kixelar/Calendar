/// View settings from 05.2, read by widgets that have no Store at hand (time format, fonts, week layout).
/// shortcut: plain globals, refreshed by App from the Store on every change; fine while the app has one window.
class Look {
  static bool use24h = true, dotDigits = true, dimPast = true, weekNumbers = false, weekends = true;
  static int weekStart = DateTime.monday; // 1 = Monday, 7 = Sunday

  /// Weekdays (1 = Monday) in display order; Saturday and Sunday left out when weekends are hidden.
  static List<int> get days => [
        for (var i = 0; i < 7; i++)
          if (weekends || (weekStart - 1 + i) % 7 + 1 < 6) (weekStart - 1 + i) % 7 + 1,
      ];

  /// First day of the week that contains [d].
  static DateTime weekOf(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - weekStart + 7) % 7);

  /// Column of [weekday] in a full 7-day week starting at [weekStart].
  static int col(int weekday) => (weekday - weekStart + 7) % 7;
}
