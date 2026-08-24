package com.prisonit.app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.prisonit.app/blocking"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context))
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                "isDeviceAdminActive" -> {
                    val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val comp = ComponentName(context, PrisonItDeviceAdmin::class.java)
                    result.success(dpm.isAdminActive(comp))
                }
                "requestDeviceAdmin" -> {
                    val comp = ComponentName(context, PrisonItDeviceAdmin::class.java)
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
                    intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, comp)
                    intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "تفعيل حماية PrisonIt لمنع فك التثبيت أو التلاعب بالإعدادات.")
                    startActivity(intent)
                    result.success(true)
                }
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
                "syncStatus" -> {
                    val jsonStr = call.arguments as? String
                    if (jsonStr != null) {
                        BlockerAccessibilityService.updateConfig(jsonStr)
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
