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
        private const val TIMEOUT_MS = 120_000L

        /** Runs the job every [minutes] (at least 15) when online; 0 or less cancels it. */
        fun schedule(context: Context, minutes: Int) {
            val js = context.getSystemService(JobScheduler::class.java)
            if (minutes <= 0) {
                js.cancel(ID)
                return
            }
            js.schedule(JobInfo.Builder(ID, ComponentName(context, SyncJob::class.java))
                .setPeriodic(maxOf(15, minutes) * 60_000L)
                .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                .setPersisted(true)
                .build())
        }
    }

    private var engine: FlutterEngine? = null
    private val main = Handler(Looper.getMainLooper())

    override fun onStartJob(params: JobParameters): Boolean {
        if (MainActivity.visible) return false
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
