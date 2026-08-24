package com.prisonit.app

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class PrisonItDeviceAdmin : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Toast.makeText(context, "تم تفعيل درع حماية PrisonIt لمنع التلاعب", Toast.LENGTH_SHORT).show()
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence? {
        return "تنبيه: محاولة إيقاف حماية PrisonIt ستتطلب انتهاء مدة العد التنازلي المحددة."
    }
}
