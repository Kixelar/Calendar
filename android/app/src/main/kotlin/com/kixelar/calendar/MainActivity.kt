package com.kixelar.calendar

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "calendar/device").setMethodCallHandler { call, result ->
            when (call.method) {
                // Dart only knows abbreviations like "CET"; Google needs the IANA id (e.g. Europe/Warsaw) for repeating events.
                "timeZone" -> result.success(TimeZone.getDefault().id)
                // 05.8 About: app version and Android release without extra plugins.
                "info" -> {
                    val p = packageManager.getPackageInfo(packageName, 0)
                    val code = if (Build.VERSION.SDK_INT >= 28) p.longVersionCode else @Suppress("DEPRECATION") p.versionCode.toLong()
                    result.success(mapOf("version" to p.versionName, "build" to code.toString(), "android" to Build.VERSION.RELEASE))
                }
                else -> result.notImplemented()
            }
        }
    }
}
