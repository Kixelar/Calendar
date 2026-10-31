package com.kixelar.calendar

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Dart only knows abbreviations like "CET"; Google needs the IANA id (e.g. Europe/Warsaw) for repeating events.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "calendar/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "timeZone" -> result.success(TimeZone.getDefault().id)
                else -> result.notImplemented()
            }
        }
    }
}
