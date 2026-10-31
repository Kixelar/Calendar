package com.kixelar.calendar

import android.content.Context
import android.os.Build
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone
import java.util.concurrent.TimeUnit

/** Channel `calendar/device`, on the app's engine and on the background sync engine (SyncWorker). */
object Device {
    fun attach(engine: FlutterEngine, context: Context, onDone: (() -> Unit)? = null) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "calendar/device").setMethodCallHandler { call, result ->
            when (call.method) {
                // Dart only knows abbreviations like "CET"; Google needs the IANA id (e.g. Europe/Warsaw) for repeating events.
                "timeZone" -> result.success(TimeZone.getDefault().id)
                // 05.8 About: app version and Android release without extra plugins.
                "info" -> {
                    val p = context.packageManager.getPackageInfo(context.packageName, 0)
                    val code = if (Build.VERSION.SDK_INT >= 28) p.longVersionCode else @Suppress("DEPRECATION") p.versionCode.toLong()
                    result.success(mapOf("version" to p.versionName, "build" to code.toString(), "android" to Build.VERSION.RELEASE))
                }
                // Home screen widgets: events and strings from the app, redrawn at once.
                "widgets" -> {
                    Widgets.save(context, call.arguments as String)
                    result.success(null)
                }
                // 05.4 automatic sync: run SyncWorker every N minutes (WorkManager's minimum is 15) when online; 0 stops it.
                "scheduleSync" -> {
                    val minutes = (call.arguments as Int)
                    val wm = WorkManager.getInstance(context)
                    if (minutes <= 0) {
                        wm.cancelUniqueWork(SyncWorker.NAME)
                    } else {
                        val request = PeriodicWorkRequestBuilder<SyncWorker>(maxOf(15L, minutes.toLong()), TimeUnit.MINUTES)
                            .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
                            .build()
                        wm.enqueueUniquePeriodicWork(SyncWorker.NAME, ExistingPeriodicWorkPolicy.UPDATE, request)
                    }
                    result.success(null)
                }
                // The background sync finished (main.dart backgroundSync).
                "done" -> {
                    result.success(null)
                    onDone?.invoke()
                }
                else -> result.notImplemented()
            }
        }
    }
}
