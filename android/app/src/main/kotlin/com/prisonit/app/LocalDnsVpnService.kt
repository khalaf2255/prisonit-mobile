package com.prisonit.app

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class LocalDnsVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (vpnInterface == null) {
            try {
                val builder = Builder()
                builder.addAddress("10.0.0.2", 32)
                // Use Family SafeSearch DNS Servers (CleanBrowsing Family Filter DNS)
                builder.addDnsServer("185.228.168.168")
                builder.addDnsServer("185.228.169.168")
                builder.addRoute("0.0.0.0", 0)
                builder.setSession("PrisonIt Safe Guard")

                vpnInterface = builder.establish()
            } catch (_: Exception) {}
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (_: Exception) {}
    }
}
