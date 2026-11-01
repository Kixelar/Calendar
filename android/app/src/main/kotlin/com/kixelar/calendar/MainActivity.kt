package com.kixelar.calendar

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        /** True while the app is on screen; the background sync job then stays out of the way. */
        @Volatile
        var visible = false

        /** A view to open, asked for by a widget tap ("day"); read once by the app (Device "takeOpen"). */
        @Volatile
        var open: String? = null
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        open = intent?.getStringExtra("open")
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        open = intent.getStringExtra("open") ?: open
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Device.attach(flutterEngine, applicationContext)
    }

    override fun onResume() {
        super.onResume()
        visible = true
    }

    override fun onPause() {
        visible = false
        super.onPause()
    }
}
