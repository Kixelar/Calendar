package com.kixelar.calendar

import android.app.Activity
import android.app.Application
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Records the last crash of this process (app, widgets, reminders, background sync) and shows it in [CrashActivity],
 * which runs in its own process, so the report can be copied even when the app dies at start.
 */
class CalendarApp : Application() {
    override fun onCreate() {
        super.onCreate()
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                val report = CrashLog.write(this, thread, error)
                startActivity(Intent(this, CrashActivity::class.java).putExtra("report", report)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK))
            } catch (_: Throwable) {
            }
            previous?.uncaughtException(thread, error)
        }
    }
}

object CrashLog {
    private fun file(context: Context) = File(context.filesDir, "crash.txt")

    fun write(context: Context, thread: Thread, error: Throwable): String {
        val trace = StringWriter().also { error.printStackTrace(PrintWriter(it)) }.toString()
        val version = try { context.packageManager.getPackageInfo(context.packageName, 0).versionName } catch (_: Exception) { "?" }
        val report = "${SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US).format(Date())}\n" +
            "app $version · Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT}) · ${Build.MANUFACTURER} ${Build.MODEL}\n" +
            "thread ${thread.name}\n\n$trace"
        file(context).writeText(report)
        return report
    }

    /** The last crash report, removed once read. */
    fun take(context: Context): String? {
        val f = file(context)
        if (!f.exists()) return null
        return f.readText().also { f.delete() }
    }
}

/** Plain Android screen (no Flutter) in the ":crash" process: the report and a Copy button. */
class CrashActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val report = intent.getStringExtra("report") ?: CrashLog.take(this) ?: ""
        val pad = (24 * resources.displayMetrics.density).toInt()
        val body = TextView(this).apply {
            text = report
            setTextIsSelectable(true)
            setTextColor(Color.WHITE)
            textSize = 12f
            typeface = android.graphics.Typeface.MONOSPACE
        }
        val title = TextView(this).apply {
            text = if (Locale.getDefault().language == "pl") "Aplikacja się zamknęła. Skopiuj raport i wyślij go twórcy." else
                "The app closed. Copy the report and send it to the developer."
            setTextColor(Color.WHITE)
            textSize = 18f
            setPadding(0, 0, 0, pad / 2)
        }
        val copy = Button(this).apply {
            text = if (Locale.getDefault().language == "pl") "Kopiuj raport" else "Copy report"
            setOnClickListener {
                (getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager).setPrimaryClip(ClipData.newPlainText("crash", report))
                text = if (Locale.getDefault().language == "pl") "Skopiowano" else "Copied"
            }
        }
        setContentView(LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.BLACK)
            setPadding(pad, pad * 2, pad, pad)
            addView(title)
            addView(copy)
            addView(ScrollView(this@CrashActivity).apply { addView(body) }, LinearLayout.LayoutParams(-1, 0, 1f))
        })
    }
}
