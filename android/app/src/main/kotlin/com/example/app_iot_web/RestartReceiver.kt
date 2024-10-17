package com.example.app_iot_web

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.pravera.flutter_foreground_task.service.ForegroundService

class RestartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val i: Intent = Intent(context, ForegroundService::class.java)
        context.startService(i)
    }
}