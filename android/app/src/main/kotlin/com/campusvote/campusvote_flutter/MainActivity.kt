package com.campusvote.campusvote_flutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createDefaultNotificationChannel()
    }

    // Canal de los avisos push (el servidor envía con channelId
    // "campusvote_default"). Crearlo de nuevo no cambia lo que el usuario ya
    // haya ajustado en la configuración del sistema.
    private fun createDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            getString(R.string.default_notification_channel_id),
            getString(R.string.default_notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = getString(R.string.default_notification_channel_description)
        }
        getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
    }
}
