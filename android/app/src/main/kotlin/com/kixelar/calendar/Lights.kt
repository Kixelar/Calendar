package com.kixelar.calendar

import android.app.AlarmManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import com.nothing.ketchum.Common
import com.nothing.ketchum.Glyph
import com.nothing.ketchum.GlyphManager
import com.nothing.ketchum.GlyphMatrixFrame
import com.nothing.ketchum.GlyphMatrixManager
import com.nothing.ketchum.GlyphMatrixObject
import com.nothing.ketchum.GlyphToy
import kotlin.math.atan2
import kotlin.math.hypot
import kotlin.math.roundToInt

/**
 * 05.3 Glyph Interface on Nothing phones (Glyph Developer Kit, android/app/libs). Built without a test device: the
 * owner's phone has no Glyph lights. Settings and reminder times come with the widget data ([Widgets.Data.glyph]).
 * - Light strips: reminders flash in the chosen pattern; the countdown lights the bar for 5 s at 60/45/30/15 min
 *   (Phone (4a): every 10 min, one light each); an event start blinks every light.
 * - Matrix (Phone (3), (4a) Pro): the same moments on the matrix, plus [CountdownToy] picked with the Glyph button.
 */
object Lights {
    /** "strip", "matrix" or null when the phone has no Glyph lights the kit supports (it needs Android 14). */
    fun kind(): String? = when {
        Build.VERSION.SDK_INT < 34 -> null
        Common.is23112() || Common.is25111p() -> "matrix"
        device() != null -> "strip"
        else -> null
    }

    private fun device(): String? = when {
        Common.is20111() -> Glyph.DEVICE_20111
        Common.is22111() -> Glyph.DEVICE_22111
        Common.is23111() -> Glyph.DEVICE_23111
        Common.is23113() -> Glyph.DEVICE_23113
        Common.is24111() -> Glyph.DEVICE_24111
        Common.is25111() -> Glyph.DEVICE_25111
        Common.is25131() -> Glyph.DEVICE_25131
        else -> null
    }

    fun matrixDevice(): String = if (Common.is25111p()) Glyph.DEVICE_25111p else Glyph.DEVICE_23112

    /** The strip used as a bar, top light first (README channel tables), and the count of all lights. */
    private fun bar(): Pair<List<Int>, Int> = when {
        Common.is20111() -> (14 downTo 7).toList() to 15 // D1_8 (top) .. D1_1
        Common.is22111() -> (32 downTo 25).toList() to 33 // D1_8 .. D1_1
        Common.is23111() || Common.is23113() -> (23 downTo 0).toList() to 26 // C_24 (top right) .. C_1
        Common.is24111() -> (20..30).toList() to 36 // A_1 (top) .. A_11
        Common.is25111() -> (0..5).toList() to 6
        else -> (0..3).toList() to 4 // Phone (4b)
    }

    /** Countdown steps in minutes: Phone (4a) has 6 lights, one per 10 min (owner); others as the widgets. */
    fun steps(): List<Int> = if (Build.VERSION.SDK_INT >= 34 && Common.is25111()) listOf(60, 50, 40, 30, 20, 10) else listOf(60, 45, 30, 15)

    private enum class Kind { REMINDER, STEP, START }
    private data class Moment(val at: Long, val kind: Kind, val step: Int = 0)

    private fun moments(context: Context): List<Moment> {
        val d = Widgets.data(context)
        val g = d.glyph
        val out = mutableListOf<Moment>()
        if (g.light) g.reminders.forEach { out += Moment(it, Kind.REMINDER) }
        if (g.countdown) for (e in d.events.filter { !it.allDay }) {
            steps().forEach { out += Moment(e.start - it * 60_000L, Kind.STEP, it) }
            out += Moment(e.start, Kind.START)
        }
        return out
    }

    private fun intent(context: Context) = PendingIntent.getBroadcast(context, 34,
        Intent(context, LightsTick::class.java), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

    /** Sets the alarm for the next moment; called whenever the app sends new data and after each moment. */
    fun schedule(context: Context) {
        if (kind() == null) return
        val am = context.getSystemService(AlarmManager::class.java)
        val now = System.currentTimeMillis()
        val next = moments(context).map { it.at }.filter { it > now + 1_000 }.minOrNull()
        if (next == null) am.cancel(intent(context))
        // Wakes the phone: the lights are for a phone lying face down.
        else am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, intent(context))
    }

    /** What is due now: a reminder wins over a countdown step at the same moment (owner). */
    fun due(context: Context, now: Long): Pair<String, Int>? {
        val m = moments(context).filter { it.at in now - 60_000..now + 1_000 }
        val d = Widgets.data(context).glyph
        return when {
            m.any { it.kind == Kind.REMINDER } -> d.pattern to 0
            m.any { it.kind == Kind.START } -> "start" to 0
            else -> m.firstOrNull { it.kind == Kind.STEP }?.let { "step" to it.step }
        }
    }

    /** Runs [what] (from [due]) on the lights, then calls [done]. */
    fun show(context: Context, what: Pair<String, Int>, done: () -> Unit) {
        val app = context.applicationContext
        val h = Handler(Looper.getMainLooper())
        if (kind() == "matrix") {
            val gm = GlyphMatrixManager.getInstance(app)
            val n = Common.getDeviceMatrixLength()
            fun finish() { try { gm.closeAppMatrix() } catch (_: Exception) {}; gm.unInit(); done() }
            gm.init(object : GlyphMatrixManager.Callback {
                override fun onServiceConnected(name: ComponentName) {
                    try {
                        gm.register(matrixDevice())
                        val style = Widgets.data(app).glyph.matrix
                        if (what.first == "step") {
                            gm.setAppMatrixFrame(frame(app, matrix(n, style, what.second / 60f)))
                            h.postDelayed(::finish, 5_000)
                        } else {
                            // Reminders and starts blink the full circle: the matrix "pattern" is how the circle empties.
                            val on = frame(app, matrix(n, style, 1f)); val off = IntArray(n * n)
                            for (i in 0 until 6) h.postDelayed({ try { gm.setAppMatrixFrame(if (i % 2 == 0) on else off) } catch (_: Exception) {} }, i * 400L)
                            h.postDelayed(::finish, 2_600)
                        }
                    } catch (e: Exception) { CrashLog.write(app, Thread.currentThread(), e); finish() }
                }
                override fun onServiceDisconnected(name: ComponentName) {}
            })
            return
        }
        val gm = GlyphManager.getInstance(app)
        fun finish() { try { gm.turnOff(); gm.closeSession() } catch (_: Exception) {}; gm.unInit(); done() }
        gm.init(object : GlyphManager.Callback {
            override fun onServiceConnected(name: ComponentName) {
                try {
                    gm.register(device())
                    gm.openSession()
                    val (bar, count) = bar()
                    fun lights(channels: List<Int>) = gm.glyphFrameBuilder.let { b -> channels.forEach { b.buildChannel(it) }; b }
                    val all = (0 until count).toList()
                    when (what.first) {
                        "step" -> {
                            // Lights go out from the top, like water in a glass.
                            val lit = (bar.size * what.second / 60f).roundToInt().coerceIn(1, bar.size)
                            gm.toggle(lights(bar.takeLast(lit)).build())
                            h.postDelayed(::finish, 5_000)
                        }
                        "pulse" -> {
                            gm.animate(lights(all).buildPeriod(1_500).buildCycles(3).buildInterval(200).build())
                            h.postDelayed(::finish, 5_200)
                        }
                        "steady" -> {
                            gm.toggle(lights(all).build())
                            h.postDelayed(::finish, 3_000)
                        }
                        else -> { // "blink" (quick flashes) and "start" (the full light blinks, owner)
                            val fast = what.first == "blink"
                            val on = if (fast) 150L else 400L
                            for (i in 0 until 6) h.postDelayed({
                                try { if (i % 2 == 0) gm.toggle(lights(all).build()) else gm.turnOff() } catch (_: Exception) {}
                            }, i * on)
                            h.postDelayed(::finish, 6 * on + 100)
                        }
                    }
                } catch (e: Exception) { CrashLog.write(app, Thread.currentThread(), e); finish() }
            }
            override fun onServiceDisconnected(name: ComponentName) {}
        })
    }

    /**
     * The matrix picture as n x n pixels (owner-approved preview, 2026-11-02): [fill] 1..0 of a circle that empties
     * from the top ("glass") or clockwise from 12 o'clock leaving the lit part on the left ("clock"); -1 draws the
     * 3x3 plus (more events later today); 0 is empty.
     */
    fun matrix(n: Int, style: String, fill: Float): BooleanArray {
        val out = BooleanArray(n * n)
        val c = (n - 1) / 2f
        val r = n / 2f - 0.5f - (if (n > 20) 2 else 1)
        for (y in 0 until n) for (x in 0 until n) {
            val dx = x - c; val dy = y - c
            out[y * n + x] = when {
                fill < 0 -> (dx == 0f && kotlin.math.abs(dy) <= 1) || (dy == 0f && kotlin.math.abs(dx) <= 1)
                fill == 0f || hypot(dx, dy) > r + 0.3f -> false
                style == "clock" -> {
                    var a = atan2(-dx, -dy); if (a < 0) a += (2 * Math.PI).toFloat()
                    a <= fill * 2 * Math.PI + 1e-6
                }
                else -> y >= c - r + (1 - fill) * 2 * r - 0.01f
            }
        }
        return out
    }

    fun frame(context: Context, px: BooleanArray): IntArray {
        val n = kotlin.math.sqrt(px.size.toDouble()).toInt()
        val bmp = Bitmap.createBitmap(n, n, Bitmap.Config.ARGB_8888)
        for (i in px.indices) bmp.setPixel(i % n, i / n, if (px[i]) 0xFFFFFFFF.toInt() else 0xFF000000.toInt())
        val obj = GlyphMatrixObject.Builder().setImageSource(bmp).setPosition(0, 0).build()
        return GlyphMatrixFrame.Builder().addTop(obj).build(context).render()
    }

    /** What the toy shows now: the countdown fill, the plus while timed events remain today, or nothing. */
    fun toyFill(context: Context, now: Long): Float {
        val evs = Widgets.data(context).events.filter { !it.allDay }
        val end = java.util.Calendar.getInstance().apply {
            timeInMillis = now; set(java.util.Calendar.HOUR_OF_DAY, 23); set(java.util.Calendar.MINUTE, 59)
        }.timeInMillis
        val next = evs.filter { it.start > now }.minOfOrNull { it.start }
        val step = next?.let { s -> steps().filter { s - now <= it * 60_000L }.minOrNull() }
        return when {
            step != null -> step / 60f
            evs.any { it.end > now && it.start <= end } -> -1f
            else -> 0f
        }
    }
}

/** Alarm for a Glyph moment: shows it, then sets the next one. */
class LightsTick : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val what = try { Lights.due(context, System.currentTimeMillis()) } catch (_: Exception) { null }
        if (what == null) { Lights.schedule(context); return }
        val pending = goAsync()
        try {
            Lights.show(context, what) { Lights.schedule(context); pending.finish() }
        } catch (e: Exception) {
            CrashLog.write(context, Thread.currentThread(), e)
            Lights.schedule(context)
            pending.finish()
        }
    }
}

/** Glyph Toy for the matrix (picked with the Glyph button, or the always-on toy on Phone (4a) Pro): the countdown. */
class CountdownToy : Service() {
    private var gm: GlyphMatrixManager? = null
    private val h = Handler(Looper.getMainLooper())
    private val tick = object : Runnable {
        override fun run() { draw(); h.postDelayed(this, 60_000) }
    }
    private val messenger = Messenger(object : Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            if (msg.what == GlyphToy.MSG_GLYPH_TOY && msg.data.getString(GlyphToy.MSG_GLYPH_TOY_DATA) == GlyphToy.EVENT_AOD) draw()
            else super.handleMessage(msg)
        }
    })

    private fun draw() {
        val m = gm ?: return
        try {
            val n = Common.getDeviceMatrixLength()
            m.setMatrixFrame(Lights.frame(this, Lights.matrix(n, Widgets.data(this).glyph.matrix, Lights.toyFill(this, System.currentTimeMillis()))))
        } catch (e: Exception) { CrashLog.write(this, Thread.currentThread(), e) }
    }

    override fun onBind(intent: Intent): IBinder {
        val m = GlyphMatrixManager.getInstance(applicationContext)
        gm = m
        m.init(object : GlyphMatrixManager.Callback {
            override fun onServiceConnected(name: ComponentName) {
                m.register(Lights.matrixDevice())
                h.post(tick)
            }
            override fun onServiceDisconnected(name: ComponentName) {}
        })
        return messenger.binder
    }

    override fun onUnbind(intent: Intent): Boolean {
        h.removeCallbacks(tick)
        gm?.let { it.turnOff(); it.unInit() }
        gm = null
        return false
    }
}
