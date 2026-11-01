package com.kixelar.calendar

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Background sync (05.4) on Android's own JobScheduler: starts a Flutter engine without UI and runs `backgroundSync`
 * from main.dart (fetch the current year, reminders, invitation notifications, widgets).
 * Skipped while the app is on screen: it syncs itself then, and two engines never run at once.
 */
class SyncJob : JobService() {
    companion object {
        private const val ID = 31
        private const val TEST_ID = 32
        private const val TIMEOUT_MS = 120_000L

        /** Runs the job every [minutes] (at least 15) when online, or only on Wi-Fi; 0 or less cancels it. */
        fun schedule(context: Context, minutes: Int, wifiOnly: Boolean) {
            val js = context.getSystemService(JobScheduler::class.java)
            if (minutes <= 0) {
                js.cancel(ID)
                return
            }
            val every = maxOf(15, minutes) * 60_000L
            val net = if (wifiOnly) JobInfo.NETWORK_TYPE_UNMETERED else JobInfo.NETWORK_TYPE_ANY
            // Scheduling again restarts the period: the app does this on every start, so leave a matching job alone.
            val pending = js.getPendingJob(ID)
            @Suppress("DEPRECATION")
            if (pending?.intervalMillis == every && pending.networkType == net) return
            js.schedule(JobInfo.Builder(ID, ComponentName(context, SyncJob::class.java))
                .setPeriodic(every)
                .setRequiredNetworkType(net)
                .setPersisted(true)
                .build())
        }

        /** One extra run in about a minute, to check background sync without waiting a full period (Settings → Accounts). */
        fun testSoon(context: Context) {
            context.getSystemService(JobScheduler::class.java).schedule(JobInfo.Builder(TEST_ID, ComponentName(context, SyncJob::class.java))
                .setMinimumLatency(60_000L)
                .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                .build())
        }

        /** Writes the run's state where the app's Dart preferences read it (shared_preferences keys carry "flutter."). */
        private fun note(context: Context, result: String) {
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).edit()
                .putLong("flutter.bgLast", System.currentTimeMillis())
                .putString("flutter.bgResult", result)
                .apply()
        }
    }

    private var engine: FlutterEngine? = null
    private val main = Handler(Looper.getMainLooper())

    override fun onStartJob(params: JobParameters): Boolean {
        if (MainActivity.visible) {
            note(applicationContext, "skipped: app open")
            return false
        }
        // Dart replaces this with "ok" or the error; if it stays, the Flutter part never finished.
        note(applicationContext, "started")
        try {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(applicationContext)
            loader.ensureInitializationComplete(applicationContext, null)
            engine = FlutterEngine(applicationContext).also {
                Device.attach(it, applicationContext) { finish(params) }
                it.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "backgroundSync"))
            }
            main.postDelayed({ finish(params) }, TIMEOUT_MS)
            return true
        } catch (e: Throwable) {
            CrashLog.write(applicationContext, Thread.currentThread(), e)
            engine?.destroy()
            engine = null
            return false
        }
    }

    private fun finish(params: JobParameters) = main.post {
        val e = engine ?: return@post
        engine = null
        e.destroy()
        jobFinished(params, false)
    }

    override fun onStopJob(params: JobParameters): Boolean {
        main.post {
            engine?.destroy()
            engine = null
        }
        return true
    }
}
