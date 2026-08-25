package com.prisonit.app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.prisonit.app/blocking"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // 1. Accessibility Service
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }

                // 2. Overlay Permission (Appear on top)
                "isOverlayPermissionGranted" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(context))
                    } else {
                        result.success(true)
                    }
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                    }
                    result.success(true)
                }

                // 3. Battery Optimization (Keep active in background)
                "isBatteryOptimizationIgnored" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                "requestIgnoreBatteryOptimization" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        } catch (e: Exception) {
                            val fallback = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(fallback)
                        }
                    }
                    result.success(true)
                }

                // 4. Device Admin
                "isDeviceAdminActive" -> {
                    val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val comp = ComponentName(context, PrisonItDeviceAdmin::class.java)
                    result.success(dpm.isAdminActive(comp))
                }
                "requestDeviceAdmin" -> {
                    val comp = ComponentName(context, PrisonItDeviceAdmin::class.java)
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                        putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, comp)
                        putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "تفعيل حماية PrisonIt لمنع فك التثبيت أو التلاعب بالإعدادات.")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }

                // 5. VPN Service
                "startVpn" -> {
                    val intent = VpnService.prepare(context)
                    if (intent != null) {
                        startActivityForResult(intent, 1001)
                    } else {
                        val vpnIntent = Intent(context, LocalDnsVpnService::class.java)
                        startService(vpnIntent)
                    }
                    result.success(true)
                }

                // 6. Sync Config
                "syncStatus" -> {
                    val jsonStr = call.arguments as? String
                    if (jsonStr != null) {
                        BlockerAccessibilityService.updateConfig(context, jsonStr)
                    }
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val prefString = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        val serviceName = "${context.packageName}/${BlockerAccessibilityService::class.java.canonicalName}"
        return prefString?.contains(serviceName) == true
    }
}
