package com.kixelar.calendar

import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

/** Channel `calendar/device`, on the app's engine and on the background sync engine (SyncJob). */
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
                // 05.4 automatic sync: run SyncJob every N minutes (Android's minimum is 15) when online; 0 stops it.
                "scheduleSync" -> {
                    SyncJob.schedule(context, call.argument<Int>("minutes")!!, call.argument<Boolean>("wifiOnly")!!)
                    result.success(null)
                }
                // "Wi-Fi only": in-app automatic sync waits while the phone is on a metered network.
                "metered" -> result.success(context.getSystemService(android.net.ConnectivityManager::class.java).isActiveNetworkMetered)
                // 04.3 holiday countries: names of ISO codes in the app's language.
                "countries" -> {
                    val lang = java.util.Locale(call.argument<String>("lang")!!)
                    result.success(call.argument<List<String>>("codes")!!.associateWith { java.util.Locale("", it).getDisplayCountry(lang) })
                }
                // A widget asked to open a view (MainActivity.open); handed out once.
                "takeOpen" -> {
                    result.success(MainActivity.open)
                    MainActivity.open = null
                }
                "testSync" -> {
                    SyncJob.testSoon(context, call.arguments as? Boolean ?: false)
                    result.success(null)
                }
                // Report of a crash since the last start (CrashLog.kt), shown once by the app.
                "lastCrash" -> result.success(CrashLog.take(context))
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
