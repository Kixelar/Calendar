package com.kixelar.calendar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
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
        val density = context.resources.displayMetrics.density
        // Portrait size: min width, max height (what launchers report for the cell area).
        val wDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 160).coerceAtLeast(40)
        val hDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 160).coerceAtLeast(40)
        val w = (wDp * density).toInt()
        val h = (hDp * density).toInt()
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val dark = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        draw(Painter(context, Canvas(bmp), w.toFloat(), h.toFloat(), density, Widgets.Colors(dark), Widgets.data(context)))
        val views = RemoteViews(context.packageName, R.layout.widget_image)
        views.setImageViewBitmap(R.id.widget_image, bmp)
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
        views.setOnClickPendingIntent(R.id.widget_image,
            PendingIntent.getActivity(context, 0, open, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
        manager.updateAppWidget(id, views)
    }
}

/** Canvas helpers in mockup units (dp) and the mockup's text styles. */
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

    /** Text with its top at [top] (CSS-like), optional right or centre alignment at [x]. */
    fun text(s: String, x: Float, top: Float, p: Paint, align: Paint.Align = Paint.Align.LEFT, maxWidth: Float = Float.MAX_VALUE) {
        p.textAlign = align
        var t = s
        if (p.measureText(t) > maxWidth) {
            while (t.isNotEmpty() && p.measureText("$t…") > maxWidth) t = t.dropLast(1)
            t = "$t…"
        }
        c.drawText(t, x, top - p.fontMetrics.ascent, p)
    }

    fun card(radiusDp: Float, fill: Int = col.surface) {
        val r = RectF(dp(0.5f), dp(0.5f), w - dp(0.5f), h - dp(0.5f))
        val rad = minOf(dp(radiusDp), h / 2, w / 2)
        c.drawRoundRect(r, rad, rad, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = fill })
        if (fill == col.surface) {
            c.drawRoundRect(r, rad, rad, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col.border; style = Paint.Style.STROKE; strokeWidth = dp(1f) })
        }
    }

    fun circle(cx: Float, cy: Float, rDp: Float, color: Int) =
        c.drawCircle(cx, cy, dp(rDp), Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color })

    fun fmt(pattern: String, d: Date): String = SimpleDateFormat(pattern, locale).format(d)
    fun upper(s: String) = s.uppercase(locale)
    fun hm(ms: Long) = fmt("HH:mm", Date(ms))

    fun startOfDay(cal: Calendar): Long = (cal.clone() as Calendar).apply {
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0); set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    /** Timed events still to come today, in order. */
    fun todayLeft(): List<Widgets.Ev> {
        val end = startOfDay(now) + 86_400_000L
        return data.events.filter { !it.allDay && it.end > now.timeInMillis && it.start < end }.sortedBy { it.start }
    }

    /** The next timed event that has not started, and its label: "In 12 min", "Today", "Tomorrow" or a date. */
    fun next(): Pair<Widgets.Ev, String>? {
        val e = data.events.filter { !it.allDay && it.start > now.timeInMillis }.minByOrNull { it.start } ?: return null
        val mins = ((e.start - now.timeInMillis + 59_999) / 60_000).toInt()
        val day = (startOfDay(Calendar.getInstance().apply { timeInMillis = e.start }) - startOfDay(now)) / 86_400_000L
        val label = when {
            mins <= 60 -> String.format(locale, data.inMin, mins)
            day == 0L -> data.today
            day == 1L -> data.tomorrow
            else -> upper(fmt("EEE d", Date(e.start)))
        }
        return e to label
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
        text(upper(fmt("LLLL", now.time)), pad, pad, label(col.display))
        text("${now.get(Calendar.YEAR)}", w - pad, pad, caption(col.secondary), Paint.Align.RIGHT)
        val cell = (w - 2 * pad) / 7
        val labels = weekdayLabels()
        val top = pad + dp(28f)
        for (i in 0 until 7) text(labels[i], pad + cell * i + cell / 2, top, label(col.secondary), Paint.Align.CENTER)
        val first = (now.clone() as Calendar).apply { set(Calendar.DAY_OF_MONTH, 1) }
        val offset = col(first.get(Calendar.DAY_OF_WEEK))
        val days = now.getActualMaximum(Calendar.DAY_OF_MONTH)
        val rows = (offset + days + 6) / 7
        val gridTop = top + dp(20f)
        val rowH = (h - gridTop - pad / 2) / rows
        val today = now.get(Calendar.DAY_OF_MONTH)
        for (d in 1..days) {
            val i = offset + d - 1
            val cx = pad + cell * (i % 7) + cell / 2
            val cy = gridTop + rowH * (i / 7) + rowH / 2
            val num = dot(20f, if (d == today) col.surface else if (d < today) col.secondary else col.display)
            if (d == today) circle(cx, cy, 16f, col.display)
            text("$d", cx, cy - dp(12f), num, Paint.Align.CENTER)
        }
    }
}

/** 4x2: the day on the left, the next three events on the right. */
class TodayWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val padX = dp(24f); val padY = dp(20f)
        text(upper(fmt("EEEE", now.time)), padX, padY, label(col.display))
        text("${now.get(Calendar.DAY_OF_MONTH)}", padX, h / 2 - dp(28f), dot(56f, col.display))
        text(upper(fmt("LLLL", now.time)), padX, h - padY - dp(16f), caption(col.secondary))
        val left = padX + dp(104f + 24f)
        val right = w - padX
        val evs = todayLeft()
        text(if (evs.isEmpty()) upper(data.noEvents) else upper(String.format(locale, data.more, evs.size)), left, padY, label(col.secondary),
            maxWidth = right - left)
        next()?.let { (e, lbl) -> if (lbl.contains(Regex("\\d")) && e in evs) text(upper(lbl), right, padY, label(col.accentText), Paint.Align.RIGHT) }
        val line = Paint().apply { color = col.border; strokeWidth = dp(1f) }
        evs.take(3).forEachIndexed { i, e ->
            val y = padY + dp(20f) + dp(32f) * i
            c.drawLine(left, y, right, y, line)
            val first = i == 0
            text(hm(e.start), left, y + dp(8f), caption(if (first) col.display else col.secondary))
            text(e.title, left + dp(44f), y + dp(6f), body(if (first) col.display else col.primary), maxWidth = right - left - dp(44f))
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
        for (i in 0 until 7) {
            val d = (start.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, i) }
            val isToday = d.get(Calendar.DAY_OF_YEAR) == now.get(Calendar.DAY_OF_YEAR) && d.get(Calendar.YEAR) == now.get(Calendar.YEAR)
            val cx = pad + step * i + step / 2
            text(labels[i], cx, h / 2 - dp(24f), label(if (isToday) col.display else col.secondary), Paint.Align.CENTER)
            if (isToday) circle(cx, h / 2 + dp(8f), 16f, col.display)
            text("${d.get(Calendar.DAY_OF_MONTH)}", cx, h / 2 - dp(4f), dot(20f, if (isToday) col.surface else col.primary), Paint.Align.CENTER)
        }
    }
}

/** 2x2: weekday and big date on a dot grid. */
class DateWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val dotPaint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply { color = col.dotOff }
        var y = dp(5f)
        while (y < h) {
            var x = dp(5f)
            while (x < w) { c.drawCircle(x, y, dp(1f), dotPaint); x += dp(10f) }
            y += dp(10f)
        }
        val pad = dp(20f)
        text(upper(fmt("EEEE", now.time)), pad, pad, label(col.display))
        text("${now.get(Calendar.DAY_OF_MONTH)}", pad, h - pad - dp(56f), dot(56f, col.display))
        text(upper(fmt("LLL", now.time)).replace(".", ""), w - pad, h - pad - dp(22f), caption(col.secondary), Paint.Align.RIGHT)
    }
}

/** 2x2: the next event, its time and how soon. */
class NextWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(24f)
        val pad = dp(20f)
        val n = next()
        if (n == null) {
            text(upper(data.noEvents), pad, pad, label(col.secondary), maxWidth = w - 2 * pad)
            return@with
        }
        val (e, lbl) = n
        text(upper(lbl), pad, pad, label(if (lbl.contains(Regex("\\d"))) col.accentText else col.secondary), maxWidth = w - 2 * pad)
        text(hm(e.start), pad, h - pad - dp(66f), dot(40f, col.display))
        text(e.title, pad, h - pad - dp(20f), body(col.primary), maxWidth = w - 2 * pad)
    }
}

/** 2x1 pill: how soon and the time of the next event. */
class NextSmallWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        card(999f)
        val pad = dp(28f)
        val n = next()
        if (n == null) {
            text(upper(data.noEvents), pad, h / 2 - dp(6f), label(col.secondary), maxWidth = w - 2 * pad)
            return@with
        }
        val (e, lbl) = n
        text(upper(lbl), pad, h / 2 - dp(26f), label(if (lbl.contains(Regex("\\d"))) col.accentText else col.secondary), maxWidth = w - 2 * pad)
        text(hm(e.start), pad, h / 2 - dp(10f), dot(40f, col.display))
    }
}

/** 1x1: today's date in a filled circle. */
class DaySmallWidget : CalendarWidget() {
    override fun draw(p: Painter) = with(p) {
        val r = minOf(w, h) / 2
        c.drawCircle(w / 2, h / 2, r, android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply { color = col.display })
        text("${now.get(Calendar.DAY_OF_MONTH)}", w / 2, h / 2 - dp(20f), dot(40f, col.bg), Paint.Align.CENTER)
    }
}
