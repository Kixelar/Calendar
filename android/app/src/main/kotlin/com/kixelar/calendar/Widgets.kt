package com.kixelar.calendar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Home screen widgets 07.1 (dark) / 07.2 (light), drawn as bitmaps with the app's own fonts so they match the mockup.
 * Dates are computed here, so date widgets stay right while the app is closed; events come from the app
 * (Store.updateWidgets -> MainActivity "widgets" -> [Widgets.save]) and are refreshed at every sync.
 */
object Widgets {
    private const val PREFS = "widgets"

    data class Ev(val title: String, val start: Long, val end: Long, val allDay: Boolean)

    /** Strings and settings from the app, in its language. */
    class Data(json: JSONObject) {
        val lang: String = json.optString("lang", "en")
        val weekStart: Int = json.optInt("weekStart", 1) // 1 = Monday ... 7 = Sunday
        val weekdays: List<String> = json.optString("weekdays", "MO,TU,WE,TH,FR,SA,SU").split(",")
        val more: String = json.optString("more", "%d more")
        val inMin: String = json.optString("inMin", "In %d min")
        val today: String = json.optString("today", "Today")
        val tomorrow: String = json.optString("tomorrow", "Tomorrow")
        val noEvents: String = json.optString("noEvents", "No events")
        val free: String = json.optString("free", "Free")
        val until: String = json.optString("until", "Now · until %s")
        val use24h: Boolean = json.optBoolean("use24h", true)
        val theme: String = json.optString("theme", "system") // the app's Appearance setting: dark, light or system
        val events: List<Ev> = json.optJSONArray("events")?.let { a ->
            (0 until a.length()).map { i ->
                val e = a.getJSONObject(i)
                Ev(e.getString("t"), e.getLong("s"), e.getLong("e"), e.getBoolean("a"))
            }
        } ?: emptyList()
        val glyph = GlyphPrefs(json.optJSONObject("glyph") ?: JSONObject())
    }

    /** 05.3 Glyph settings and today's reminder times (Lights.kt). */
    class GlyphPrefs(json: JSONObject) {
        val light: Boolean = json.optBoolean("light", false)
        val countdown: Boolean = json.optBoolean("countdown", false)
        val pattern: String = json.optString("pattern", "pulse") // pulse, blink, steady
        val matrix: String = json.optString("matrix", "glass") // glass, clock
        val reminders: List<Long> = json.optJSONArray("reminders")?.let { a -> (0 until a.length()).map { a.getLong(it) } } ?: emptyList()
    }

    /** Countdown shown by widgets: 60, 45, 30 or 15 min before an event (owner, 2026-11-01), null earlier. */
    fun step(start: Long, now: Long): Int? {
        val mins = ((start - now + 59_999) / 60_000).toInt()
        return if (mins in 1..60) (mins + 14) / 15 * 15 else null
    }

    private fun tickIntent(context: Context) = PendingIntent.getBroadcast(context, 33,
        Intent(context, WidgetTick::class.java), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

    /** Sets the next redraw of all widgets: a quarter hour, or 60 / 45 / 30 / 15 min before, the start or the end of an event. */
    fun schedule(context: Context) {
        val now = System.currentTimeMillis()
        val quarter = (now / 900_000L + 1) * 900_000L
        val at = data(context).events.filter { !it.allDay }
            .flatMap { e -> listOf(60, 45, 30, 15, 0).map { e.start - it * 60_000L } + e.end }
            .filter { it > now }.plus(quarter).min()
        // RTC, not RTC_WAKEUP: a sleeping phone is not woken, widgets catch up when the screen comes on.
        context.getSystemService(android.app.AlarmManager::class.java).setExact(android.app.AlarmManager.RTC, at, tickIntent(context))
    }

    fun save(context: Context, json: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("data", json).apply()
        updateAll(context)
        try { Lights.schedule(context) } catch (e: Exception) { CrashLog.write(context, Thread.currentThread(), e) }
    }

    fun data(context: Context): Data =
        Data(JSONObject(context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("data", null) ?: "{}"))

    fun updateAll(context: Context) {
        val m = AppWidgetManager.getInstance(context)
        for (cls in listOf(MonthWidget::class.java, TodayWidget::class.java, WeekWidget::class.java, DateWidget::class.java,
            NextWidget::class.java, NextSmallWidget::class.java, DaySmallWidget::class.java, ClockWidget::class.java)) {
            val ids = m.getAppWidgetIds(ComponentName(context, cls))
            if (ids.isNotEmpty()) context.sendBroadcast(Intent(context, cls).setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids))
        }
    }

    // Design tokens from the mockup (lib/theme.dart).
    class Colors(dark: Boolean) {
        val bg = if (dark) 0xFF000000.toInt() else 0xFFF4F4F4.toInt()
        val surface = if (dark) 0xFF111111.toInt() else 0xFFFFFFFF.toInt()
        val border = if (dark) 0xFF222222.toInt() else 0xFFE2E2E2.toInt()
        val display = if (dark) 0xFFFFFFFF.toInt() else 0xFF000000.toInt()
        val primary = if (dark) 0xFFE8E8E8.toInt() else 0xFF1A1A1A.toInt()
        val secondary = if (dark) 0xFF999999.toInt() else 0xFF666666.toInt()
        val accentText = if (dark) 0xFFFF4D55.toInt() else 0xFFD71921.toInt()
        val dotOff = if (dark) 0xFF333333.toInt() else 0xFFD0D0D0.toInt()
        val accent = 0xFFD71921.toInt()
        val disabled = if (dark) 0xFF666666.toInt() else 0xFF999999.toInt()
        val warning = if (dark) 0xFFD4A843.toInt() else 0xFF8A6500.toInt()
        val raised = if (dark) 0xFF1A1A1A.toInt() else 0xFFE8E8E8.toInt()
    }

    private val fonts = HashMap<String, Typeface>()
    fun font(context: Context, file: String): Typeface = fonts.getOrPut(file) {
        try { Typeface.createFromAsset(context.assets, "flutter_assets/assets/fonts/$file") } catch (_: Exception) { Typeface.DEFAULT }
    }

    /** NType82 with Space Grotesk for the Polish letters it lacks, like the app. */
    fun sans(context: Context): Typeface = fonts.getOrPut("sans") {
        if (Build.VERSION.SDK_INT >= 29) {
            try {
                val a = context.assets
                Typeface.CustomFallbackBuilder(android.graphics.fonts.FontFamily.Builder(
                    android.graphics.fonts.Font.Builder(a, "flutter_assets/assets/fonts/NType82-Regular.otf").build()).build())
                    .addCustomFallback(android.graphics.fonts.FontFamily.Builder(
                        android.graphics.fonts.Font.Builder(a, "flutter_assets/assets/fonts/SpaceGrotesk-Regular.otf").build()).build())
                    .build()
            } catch (_: Exception) { font(context, "SpaceGrotesk-Regular.otf") }
        } else font(context, "SpaceGrotesk-Regular.otf")
    }
}

/** Shared drawing for all widget sizes: a bitmap the size of the widget, opened app on tap. */
abstract class CalendarWidget : AppWidgetProvider() {
    /** Draw into a canvas of [w] x [h] pixels; [dp] converts mockup units. */
    abstract fun draw(p: Painter)

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) render(context, manager, id, manager.getAppWidgetOptions(id))
        if (ids.isNotEmpty()) try { Widgets.schedule(context) } catch (e: Exception) { CrashLog.write(context, Thread.currentThread(), e) }
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        render(context, manager, id, options)
    }

    private fun render(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        // A widget must never take the app down: a failure is recorded for the crash report instead.
        try {
            draw(context, manager, id, options)
        } catch (e: Exception) {
            CrashLog.write(context, Thread.currentThread(), e)
        }
    }

    /** Where a tap goes: the app as it was, or a view named by the "open" extra (MainActivity). */
    open fun tap(context: Context): Intent? = context.packageManager.getLaunchIntentForPackage(context.packageName)

    private fun draw(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        // Two bitmaps (light and dark) travel to the launcher through IPC: keep each under ~1.5 MB.
        val wanted = context.resources.displayMetrics.density
        // Portrait size: min width, max height (what launchers report for the cell area).
        val wDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 160).coerceAtLeast(40)
        val hDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 160).coerceAtLeast(40)
        val density = minOf(wanted, kotlin.math.sqrt(1_500_000f / 4f / (wDp * hDp)))
        val w = (wDp * density).toInt()
        val h = (hDp * density).toInt()
        val data = Widgets.data(context)
        fun bitmap(dark: Boolean) = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).also {
            draw(Painter(context, Canvas(it), w.toFloat(), h.toFloat(), density, Widgets.Colors(dark), data))
        }
        // Both themes are sent; layout/ and layout-night/ show one of them, so the launcher switches with the system theme.
        val views = RemoteViews(context.packageName, R.layout.widget_image)
        // "system" sends both and the layouts pick by night mode; a fixed app theme puts the same look in both slots.
        val light = if (data.theme == "dark") bitmap(true) else bitmap(false)
        val dark = if (data.theme == "light") light else if (data.theme == "dark") light else bitmap(true)
        views.setImageViewBitmap(R.id.widget_light, light)
        views.setImageViewBitmap(R.id.widget_dark, dark)
        views.setOnClickPendingIntent(R.id.widget_root, PendingIntent.getActivity(context, javaClass.name.hashCode(), tap(context),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
        manager.updateAppWidget(id, views)
    }
}

/** Canvas helpers in mockup units (dp) and the mockup's text styles. Text is placed by its glyph bounds, not font
 *  metrics: Ndot's metrics carry large margins, which pushed numbers off centre. */
class Painter(
    val context: Context, val c: Canvas, val w: Float, val h: Float, val density: Float,
    val col: Widgets.Colors, val data: Widgets.Data,
) {
    val locale: Locale = Locale(data.lang)
    val now: Calendar = Calendar.getInstance()
    fun dp(v: Float) = v * density

    private fun paint(face: Typeface, sizeDp: Float, color: Int, tracking: Float = 0f) = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = face; textSize = dp(sizeDp); this.color = color; letterSpacing = tracking
    }
    fun dot(size: Float, color: Int) = paint(Widgets.font(context, "Ndot57-Regular.otf"), size, color)
    fun label(color: Int) = paint(Widgets.font(context, "LetteraMonoLL-Regular.otf"), 11f, color, 0.08f)
    fun caption(color: Int) = paint(Widgets.font(context, "LetteraMonoLL-Regular.otf"), 12f, color)
    fun body(color: Int) = paint(Widgets.sans(context), 14f, color)

    private fun fit(s: String, p: Paint, maxWidth: Float): String {
        if (p.measureText(s) <= maxWidth) return s
        var t = s
        while (t.isNotEmpty() && p.measureText("$t…") > maxWidth) t = t.dropLast(1)
        return "$t…"
    }

    /** Height of capital letters / digits of [p], the visual size used for centring. */
    fun cap(p: Paint): Float {
        val r = android.graphics.Rect()
        p.getTextBounds("0H", 0, 2, r)
        return r.height().toFloat()
    }

    /** Draws [s] with its capital-letter box vertically centred on [cy]. */
    fun mid(s: String, x: Float, cy: Float, p: Paint, align: Paint.Align = Paint.Align.LEFT, maxWidth: Float = Float.MAX_VALUE) {
        p.textAlign = align
        c.drawText(fit(s, p, maxWidth), x, cy + cap(p) / 2, p)
    }

    /** Draws [s] with the top of its capitals at [top]. */
    fun top(s: String, x: Float, top: Float, p: Paint, align: Paint.Align = Paint.Align.LEFT, maxWidth: Float = Float.MAX_VALUE) {
        p.textAlign = align
        c.drawText(fit(s, p, maxWidth), x, top + cap(p), p)
    }

    /** Draws [s] with its baseline at [base]. */
    fun base(s: String, x: Float, base: Float, p: Paint, align: Paint.Align = Paint.Align.LEFT, maxWidth: Float = Float.MAX_VALUE) {
        p.textAlign = align
        c.drawText(fit(s, p, maxWidth), x, base, p)
    }

    fun card(radiusDp: Float, fill: Int = col.surface) {
        val r = RectF(dp(0.5f), dp(0.5f), w - dp(0.5f), h - dp(0.5f))
        val rad = minOf(dp(radiusDp), h / 2, w / 2)
        c.drawRoundRect(r, rad, rad, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = fill })
        if (fill == col.surface) {
            c.drawRoundRect(r, rad, rad, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.border; style = Paint.Style.STROKE; strokeWidth = dp(1f) })
        }
    }

    fun circle(cx: Float, cy: Float, r: Float, color: Int) =
        c.drawCircle(cx, cy, r, Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color })

    fun fmt(pattern: String, d: Date): String = SimpleDateFormat(pattern, locale).format(d)
    fun upper(s: String) = s.uppercase(locale)
    // 12-hour widgets show "2:30" without AM/PM: there is no room for it next to the big digits.
    fun hm(ms: Long) = fmt(if (data.use24h) "HH:mm" else "h:mm", Date(ms))

    fun startOfDay(cal: Calendar): Long = (cal.clone() as Calendar).apply {
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0); set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    /** Timed events still to come today, in order. */
    fun todayLeft(): List<Widgets.Ev> {
        val end = startOfDay(now) + 86_400_000L
        return data.events.filter { !it.allDay && it.end > now.timeInMillis && it.start < end }.sortedBy { it.start }
    }

    /** The next timed event that has not started, its label ("In 15 min", "Today", "Tomorrow", a date) and whether it is soon. */
    fun next(): Triple<Widgets.Ev, String, Boolean>? {
        val e = data.events.filter { !it.allDay && it.start > now.timeInMillis }.minByOrNull { it.start } ?: return null
        val step = Widgets.step(e.start, now.timeInMillis)
        val day = (startOfDay(Calendar.getInstance().apply { timeInMillis = e.start }) - startOfDay(now)) / 86_400_000L
        val label = when {
            step != null -> String.format(locale, data.inMin, step)
            day == 0L -> data.today
            day == 1L -> data.tomorrow
            else -> fmt("EEE d", Date(e.start))
        }
        return Triple(e, upper(label), step != null)
    }

    /** Weekday column of [dow] (Calendar.MONDAY...) for the app's first day of week. */
    fun col(dow: Int): Int {
        val iso = if (dow == Calendar.SUNDAY) 7 else dow - 1
        return (iso - data.weekStart + 7) % 7
    }

    fun weekdayLabels(): List<String> = (0 until 7).map { data.weekdays[(data.weekStart - 1 + it) % 7] }
}

/** 4x4: the current month, today filled, past days dimmed. */
class MonthWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val pad = dp(24f)
        top(upper(fmt("LLLL", now.time)), pad, pad, label(col.display))
        top("${now.get(Calendar.YEAR)}", w - pad, pad, caption(col.secondary), Paint.Align.RIGHT)
        val cell = (w - 2 * pad) / 7
        val labels = weekdayLabels()
        val labelsY = pad + dp(36f)
        for (i in 0 until 7) mid(labels[i], pad + cell * i + cell / 2, labelsY, label(col.secondary), Paint.Align.CENTER)
        val first = (now.clone() as Calendar).apply { set(Calendar.DAY_OF_MONTH, 1) }
        val offset = col(first.get(Calendar.DAY_OF_WEEK))
        val days = now.getActualMaximum(Calendar.DAY_OF_MONTH)
        val rows = (offset + days + 6) / 7
        val gridTop = labelsY + dp(12f)
        val rowH = (h - gridTop - pad * 0.75f) / rows
        val r = minOf(dp(16f), rowH / 2 - dp(2f), cell / 2 - dp(2f))
        val today = now.get(Calendar.DAY_OF_MONTH)
        for (d in 1..days) {
            val i = offset + d - 1
            val cx = pad + cell * (i % 7) + cell / 2
            val cy = gridTop + rowH * (i / 7) + rowH / 2
            if (d == today) circle(cx, cy, r, col.display)
            mid("$d", cx, cy, dot(20f, if (d == today) col.surface else if (d < today) col.secondary else col.display), Paint.Align.CENTER)
        }
    }
}

/** 4x2: the day on the left, the next three events on the right. */
class TodayWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val padX = dp(24f)
        val padY = dp(20f)
        top(upper(fmt("EEEE", now.time)), padX, padY, label(col.display), maxWidth = dp(104f))
        mid("${now.get(Calendar.DAY_OF_MONTH)}", padX, h / 2, dot(56f, col.display))
        base(upper(fmt("LLLL", now.time)), padX, h - padY, caption(col.secondary), maxWidth = dp(104f))
        val left = padX + dp(104f + 24f)
        val right = w - padX
        val evs = todayLeft()
        top(if (evs.isEmpty()) upper(data.noEvents) else upper(String.format(locale, data.more, evs.size)), left, padY, label(col.secondary),
            maxWidth = right - left - dp(72f))
        next()?.let { (e, lbl, soon) -> if (soon && e in evs) top(lbl, right, padY, label(col.accentText), Paint.Align.RIGHT) }
        // Rows share the height under the header evenly, like the mockup's three 32dp rows.
        val rowsTop = padY + dp(20f)
        val rowH = (h - padY - rowsTop) / 3
        val line = Paint().apply { color = col.border; strokeWidth = dp(1f) }
        evs.take(3).forEachIndexed { i, e ->
            val y = rowsTop + rowH * i
            c.drawLine(left, y, right, y, line)
            val first = i == 0
            mid(hm(e.start), left, y + rowH / 2, caption(if (first) col.display else col.secondary))
            mid(e.title, left + dp(48f), y + rowH / 2, body(if (first) col.display else col.primary), maxWidth = right - left - dp(48f))
        }
    }
}

/** 4x1 pill: this week's days with today filled. */
class WeekWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(999f)
        val pad = dp(24f)
        val start = (now.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, -col(now.get(Calendar.DAY_OF_WEEK))) }
        val step = (w - 2 * pad) / 7
        val labels = weekdayLabels()
        // Label (12) + gap (4) + day circle (32), centred as one block.
        val blockTop = (h - dp(48f)) / 2
        val labelY = blockTop + dp(6f)
        val numY = blockTop + dp(32f)
        for (i in 0 until 7) {
            val d = (start.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, i) }
            val isToday = d.get(Calendar.DAY_OF_YEAR) == now.get(Calendar.DAY_OF_YEAR) && d.get(Calendar.YEAR) == now.get(Calendar.YEAR)
            val cx = pad + step * i + step / 2
            mid(labels[i], cx, labelY, label(if (isToday) col.display else col.secondary), Paint.Align.CENTER)
            if (isToday) circle(cx, numY, minOf(dp(16f), step / 2 - dp(1f)), col.display)
            mid("${d.get(Calendar.DAY_OF_MONTH)}", cx, numY, dot(20f, if (isToday) col.surface else col.primary), Paint.Align.CENTER)
        }
    }
}

/** 2x2: weekday and big date on the mockup's dot grid. */
class DateWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val dots = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.dotOff }
        c.save()
        c.clipPath(android.graphics.Path().apply { addRoundRect(RectF(0f, 0f, w, h), dp(24f), dp(24f), android.graphics.Path.Direction.CW) })
        var y = dp(5f)
        while (y < h - dp(2f)) {
            var x = dp(5f)
            while (x < w - dp(2f)) {
                c.drawCircle(x, y, dp(1f), dots)
                x += dp(10f)
            }
            y += dp(10f)
        }
        c.restore()
        val pad = dp(20f)
        top(upper(fmt("EEEE", now.time)), pad, pad, label(col.display), maxWidth = w - 2 * pad)
        base("${now.get(Calendar.DAY_OF_MONTH)}", pad, h - pad, dot(56f, col.display))
        base(upper(fmt("LLL", now.time)).replace(".", ""), w - pad, h - pad, caption(col.secondary), Paint.Align.RIGHT)
    }
}

/** 2x2: the next event, its time and how soon. */
class NextWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val pad = dp(20f)
        val n = next()
        if (n == null) {
            mid(upper(data.noEvents), w / 2, h / 2, label(col.secondary), Paint.Align.CENTER, w - 2 * pad)
            return@with
        }
        val (e, lbl, soon) = n
        top(lbl, pad, pad, label(if (soon) col.accentText else col.secondary), maxWidth = w - 2 * pad)
        base(e.title, pad, h - pad, body(col.primary), maxWidth = w - 2 * pad)
        base(hm(e.start), pad, h - pad - dp(24f), dot(40f, col.display))
    }
}

/** 2x1 pill: how soon and the time of the next event, centred. */
class NextSmallWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(999f)
        val n = next()
        if (n == null) {
            mid(upper(data.noEvents), w / 2, h / 2, label(col.secondary), Paint.Align.CENTER, w - dp(32f))
            return@with
        }
        val (e, lbl, soon) = n
        // Label + gap + time, centred as one block on both axes.
        val lp = label(if (soon) col.accentText else col.secondary)
        val tp = dot(40f, col.display)
        val gap = dp(8f)
        val topY = (h - (cap(lp) + gap + cap(tp))) / 2
        top(lbl, w / 2, topY, lp, Paint.Align.CENTER, w - dp(32f))
        top(hm(e.start), w / 2, topY + cap(lp) + gap, tp, Paint.Align.CENTER)
    }
}

/** 1x1: today's date in a circle in the theme's card colour, like the other widgets (owner's choice over the mockup's inverted fill). */
class DaySmallWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        val r = minOf(w, h) / 2
        circle(w / 2, h / 2, r, col.surface)
        c.drawCircle(w / 2, h / 2, r - dp(0.5f), Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.border; style = Paint.Style.STROKE; strokeWidth = dp(1f) })
        mid("${now.get(Calendar.DAY_OF_MONTH)}", w / 2, h / 2, dot(40f, col.display), Paint.Align.CENTER)
    }
}


/**
 * 2x2 and larger: a 24-hour dial of today's timed events (grey past, white to come, yellow clashes) with a red hand
 * for now; the middle shows the next event's time and title, "in 60 / 45 / 30 / 15 min" before it, "now · until" during it, or
 * "free". Redrawn with the other widgets (Widgets.schedule).
 */
class ClockWidget : CalendarWidget() {
    // Opens today's day view, not an event (owner, 2026-11-01).
    // CLEAR_TOP + SINGLE_TOP hand the extra to a running app through onNewIntent.
    override fun tap(context: Context): Intent? = super.tap(context)?.putExtra("open", "day")
        ?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)

    override fun draw(p: Painter) = with(p) {
        card(24f)
        val s = minOf(w, h)
        val k = s / dp(170f) // drawn for a 170dp square; text and strokes scale with the widget
        val cx = w / 2
        val cy = h / 2
        val outer = s / 2 - dp(8f) * k
        val ring = outer - dp(25f) * k
        val stroke = dp(9f) * k
        val day0 = startOfDay(now)
        val nowMs = now.timeInMillis
        fun angle(ms: Long) = ((ms - day0).coerceIn(0L, 86_400_000L) / 86_400_000f) * 360f - 90f
        fun at(r: Float, deg: Float) = Pair(cx + r * kotlin.math.cos(Math.toRadians(deg.toDouble())).toFloat(),
            cy + r * kotlin.math.sin(Math.toRadians(deg.toDouble())).toFloat())
        fun small(color: Int) = label(color).apply { textSize *= k * 10f / 11f }

        // Hour dots, bigger at 00 / 06 / 12 / 18 with their labels inside.
        val tick = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.dotOff }
        val tickMain = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.secondary }
        for (hr in 0 until 24) {
            val (x, y) = at(outer, hr * 15f - 90f)
            val main = hr % 6 == 0
            c.drawCircle(x, y, dp(if (main) 2f else 1.2f) * k, if (main) tickMain else tick)
            if (main) {
                val (lx, ly) = at(outer - dp(11f) * k, hr * 15f - 90f)
                val text = if (data.use24h) "%02d".format(hr) else "${if (hr % 12 == 0) 12 else hr % 12}${if (hr < 12) "A" else "P"}"
                mid(text, lx, ly, small(col.secondary), Paint.Align.CENTER)
            }
        }

        // Track and today's timed events; an event that starts while another is on is a clash.
        val oval = RectF(cx - ring, cy - ring, cx + ring, cy + ring)
        val arc = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = stroke; color = col.raised }
        c.drawArc(oval, 0f, 360f, false, arc)
        val today = data.events.filter { !it.allDay && it.end > day0 && it.start < day0 + 86_400_000L }.sortedBy { it.start }
        val gap = 1.2f
        for ((i, e) in today.withIndex()) {
            val clash = today.take(i).any { it.end > e.start }
            val past = e.end <= nowMs
            arc.color = when {
                clash && past -> (col.warning and 0x00FFFFFF) or (0x99 shl 24)
                clash -> col.warning
                past -> col.disabled
                else -> col.display
            }
            val a = angle(e.start)
            c.drawArc(oval, a + gap / 2, maxOf(angle(e.end) - a - gap, 2f), false, arc)
        }

        // Red hand for now: from inside the ring to a dot just outside it.
        val red = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.accent; strokeWidth = dp(1.5f) * k }
        val (x1, y1) = at(ring - stroke * 1.6f, angle(nowMs))
        val (x2, y2) = at(ring + stroke * 0.9f, angle(nowMs))
        c.drawLine(x1, y1, x2, y2, red)
        c.drawCircle(x2, y2, dp(3f) * k, red)

        // Middle: the event on now, else the next one today, else "free".
        val inner = (ring - stroke / 2) * 2 * 0.86f
        val onNow = today.lastOrNull { it.start <= nowMs && it.end > nowMs }
        val e = onNow ?: today.firstOrNull { it.start > nowMs }
        if (e == null) {
            mid(upper(data.free), cx, cy, small(col.secondary), Paint.Align.CENTER, inner)
            return@with
        }
        val big = dot(24f * k, col.display)
        val title = body(col.primary).apply { textSize *= k * 12f / 14f }
        val note = if (onNow != null) String.format(locale, data.until, hm(e.end))
            else Widgets.step(e.start, nowMs)?.let { String.format(locale, data.inMin, it) }
        val sub = small(if (onNow != null) col.secondary else col.accentText)
        val g1 = dp(6f) * k
        val g2 = dp(7f) * k
        val blockH = cap(big) + (if (note != null) g1 + cap(sub) else 0f) + g2 + cap(title)
        var y = cy - blockH / 2
        top(hm(e.start), cx, y, big, Paint.Align.CENTER, inner)
        y += cap(big)
        if (note != null) {
            y += g1
            top(upper(note), cx, y, sub, Paint.Align.CENTER, inner)
            y += cap(sub)
        }
        top(e.title, cx, y + g2, title, Paint.Align.CENTER, inner * 0.92f)
    }
}

/** Alarm from [Widgets.schedule]: redraws every widget, which sets the next alarm. */
class WidgetTick : android.content.BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = Widgets.updateAll(context)
}
