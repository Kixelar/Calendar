package com.kixelar.calendar

import android.app.Application
import android.content.Context
import android.os.Build
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Records the last crash of this process (app, widgets, reminders, background sync) in files/crash.txt, so the app
 * can show it on the next start and the owner can copy it (there is no crash reporting service).
 */
class CalendarApp : Application() {
    override fun onCreate() {
        super.onCreate()
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                CrashLog.write(this, thread, error)
            } catch (_: Throwable) {
            }
            previous?.uncaughtException(thread, error)
        }
    }
}

object CrashLog {
    private fun file(context: Context) = File(context.filesDir, "crash.txt")

    fun write(context: Context, thread: Thread, error: Throwable) {
        val trace = StringWriter().also { error.printStackTrace(PrintWriter(it)) }.toString()
        val p = context.packageManager.getPackageInfo(context.packageName, 0)
        file(context).writeText(
            "${SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US).format(Date())}\n" +
                "app ${p.versionName} · Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT}) · ${Build.MANUFACTURER} ${Build.MODEL}\n" +
                "thread ${thread.name}\n\n$trace"
        )
    }

    /** The last crash report, removed once read. */
    fun take(context: Context): String? {
        val f = file(context)
        if (!f.exists()) return null
        return f.readText().also { f.delete() }
    }
}
