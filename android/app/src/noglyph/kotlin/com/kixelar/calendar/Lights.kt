package com.kixelar.calendar

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.IBinder

/**
 * Stand-in for the Glyph Interface when Nothing's Glyph Developer Kit is not in android/app/libs (its licence does not
 * allow sharing it): the app builds and runs, it only has no Glyph lights. The real code is in src/glyph/kotlin.
 */
object Lights {
    fun kind(): String? = null
    fun schedule(context: Context) {}
}

class LightsTick : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {}
}

class CountdownToy : Service() {
    override fun onBind(intent: Intent): IBinder? = null
}
