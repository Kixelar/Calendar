package com.kixelar.calendar

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.work.Worker
import androidx.work.WorkerParameters
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * Background sync (05.4): starts a Flutter engine without UI and runs `backgroundSync` from main.dart, which
 * fetches the current year from Google, reschedules reminders, shows invitation notifications and updates widgets.
 */
class SyncWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    companion object {
        const val NAME = "calendar-sync"
    }

    override fun doWork(): Result {
        val done = CountDownLatch(1)
        val main = Handler(Looper.getMainLooper())
        var engine: FlutterEngine? = null
        // Flutter engines are created and run on the main thread.
        main.post {
            try {
                val loader = FlutterInjector.instance().flutterLoader()
                loader.startInitialization(applicationContext)
                loader.ensureInitializationComplete(applicationContext, null)
                engine = FlutterEngine(applicationContext).also {
                    Device.attach(it, applicationContext) { done.countDown() }
                    it.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "backgroundSync"))
                }
            } catch (_: Exception) {
                done.countDown()
            }
        }
        val finished = done.await(2, TimeUnit.MINUTES)
        main.post { engine?.destroy() }
        return if (finished) Result.success() else Result.retry()
    }
}
