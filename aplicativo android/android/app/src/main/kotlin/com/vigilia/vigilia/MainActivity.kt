package com.vigilia.vigilia

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.provider.Settings
import android.net.Uri
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val APPS_CHANNEL = "com.vigilia/apps"
    private val SETTINGS_CHANNEL = "com.vigilia/settings"

    private val SYSTEM_PREFIXES = listOf(
        "com.google.", "com.android.", "com.samsung.",
        "com.sec.", "com.qualcomm.", "com.mediatek.",
        "android", "com.huawei.", "com.xiaomi.",
        "com.miui.", "com.oppo.", "com.coloros.",
        "com.oneplus.", "com.motorola.", "org.chromium.",
        "com.caf.", "com.qti."
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APPS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> result.success(getInstalledApps())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openUsageAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(true)
                    }
                    "openOverlaySettings" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(true)
                    }
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_SETTINGS))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val result = mutableListOf<Map<String, Any>>()

        for (app in apps) {
            // Skip pure system apps
            if (app.flags and ApplicationInfo.FLAG_SYSTEM != 0 &&
                app.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP == 0) {
                continue
            }

            // Skip self
            if (app.packageName == packageName) continue

            // Skip known system/manufacturer packages
            if (SYSTEM_PREFIXES.any { app.packageName.startsWith(it) }) continue

            val appName = pm.getApplicationLabel(app).toString()
            val iconBase64 = drawableToBase64(pm.getApplicationIcon(app.packageName))

            val isGame = try {
                app.category == ApplicationInfo.CATEGORY_GAME
            } catch (_: Exception) {
                false
            }

            result.add(mapOf(
                "package_name" to app.packageName,
                "app_name" to appName,
                "icon" to iconBase64,
                "is_game" to isGame
            ))
        }

        result.sortBy { it["app_name"]?.toString()?.lowercase() }
        return result
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(96, 96, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, 96, 96)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }
}
