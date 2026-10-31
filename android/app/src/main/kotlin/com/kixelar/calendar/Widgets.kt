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
        val use24h: Boolean = json.optBoolean("use24h", true)
        val events: List<Ev> = json.optJSONArray("events")?.let { a ->
            (0 until a.length()).map { i ->
                val e = a.getJSONObject(i)
                Ev(e.getString("t"), e.getLong("s"), e.getLong("e"), e.getBoolean("a"))
            }
        } ?: emptyList()
    }

    fun save(context: Context, json: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("data", json).apply()
        updateAll(context)
    }

    fun data(context: Context): Data =
        Data(JSONObject(context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("data", null) ?: "{}"))

    fun updateAll(context: Context) {
        val m = AppWidgetManager.getInstance(context)
        for (cls in listOf(MonthWidget::class.java, TodayWidget::class.java, WeekWidget::class.java, DateWidget::class.java,
            NextWidget::class.java, NextSmallWidget::class.java, DaySmallWidget::class.java)) {
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
        views.setImageViewBitmap(R.id.widget_light, bitmap(false))
        views.setImageViewBitmap(R.id.widget_dark, bitmap(true))
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
        views.setOnClickPendingIntent(R.id.widget_root,
            PendingIntent.getActivity(context, 0, open, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
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

    /** The next timed event that has not started, its label ("In 12 min", "Today", "Tomorrow", a date) and whether it is soon. */
    fun next(): Triple<Widgets.Ev, String, Boolean>? {
        val e = data.events.filter { !it.allDay && it.start > now.timeInMillis }.minByOrNull { it.start } ?: return null
        val mins = ((e.start - now.timeInMillis + 59_999) / 60_000).toInt()
        val day = (startOfDay(Calendar.getInstance().apply { timeInMillis = e.start }) - startOfDay(now)) / 86_400_000L
        val label = when {
            mins <= 60 -> String.format(locale, data.inMin, mins)
            day == 0L -> data.today
            day == 1L -> data.tomorrow
            else -> fmt("EEE d", Date(e.start))
        }
        return Triple(e, upper(label), mins <= 60)
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

/** 1x1: today's date in a filled circle. */
class DaySmallWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        circle(w / 2, h / 2, minOf(w, h) / 2, col.display)
        mid("${now.get(Calendar.DAY_OF_MONTH)}", w / 2, h / 2, dot(40f, col.bg), Paint.Align.CENTER)
    }
}
