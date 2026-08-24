package com.prisonit.app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONObject

class BlockerAccessibilityService : AccessibilityService() {

    companion object {
        private var blockedDomains = mutableListOf<String>()
        private var isAdultBlockEnabled = true

        fun updateConfig(jsonStr: String) {
            try {
                val json = JSONObject(jsonStr)
                isAdultBlockEnabled = json.optBoolean("adultBlock", true)
                val rawSites = json.optJSONArray("blockedSites")
                blockedDomains.clear()
                if (rawSites != null) {
                    for (i in 0 until rawSites.length()) {
                        val site = rawSites.getJSONObject(i)
                        val domain = site.optString("domain", "").lowercase()
                        if (domain.isNotEmpty()) {
                            blockedDomains.add(domain)
                        }
                    }
                }
            } catch (_: Exception) {}
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val packageName = event.packageName?.toString() ?: return

        // Prevent opening App Info / Clear Data in Settings
        if (packageName == "com.android.settings") {
            val rootNode = rootInActiveWindow ?: return
            val textNodes = mutableListOf<AccessibilityNodeInfo>()
            findTextNodes(rootNode, textNodes)

            for (node in textNodes) {
                val text = node.text?.toString()?.lowercase() ?: ""
                if (text.contains("prisonit") || text.contains("إلغاء التثبيت") || text.contains("uninstall") || text.contains("force stop")) {
                    performGlobalAction(GLOBAL_ACTION_HOME)
                    break
                }
            }
        }

        // Monitor Browser URL Bar (Chrome, Edge, Firefox, Brave)
        val rootNode = rootInActiveWindow ?: return
        val url = findUrlInNode(rootNode)?.lowercase() ?: ""

        if (url.isNotEmpty()) {
            for (domain in blockedDomains) {
                if (url.contains(domain)) {
                    showBlockOverlay(domain)
                    performGlobalAction(GLOBAL_ACTION_HOME)
                    break
                }
            }
        }
    }

    private fun findUrlInNode(node: AccessibilityNodeInfo?): String? {
        if (node == null) return null

        if (node.className != null && node.className.toString().contains("EditText")) {
            val text = node.text?.toString()
            if (text != null && (text.contains(".") || text.contains("http"))) {
                return text
            }
        }

        for (i in 0 until node.childCount) {
            val res = findUrlInNode(node.getChild(i))
            if (res != null) return res
        }
        return null
    }

    private fun findTextNodes(node: AccessibilityNodeInfo?, list: MutableList<AccessibilityNodeInfo>) {
        if (node == null) return
        if (node.text != null) list.add(node)
        for (i in 0 until node.childCount) {
            findTextNodes(node.getChild(i), list)
        }
    }

    private fun showBlockOverlay(domain: String) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        intent.putExtra("blockedItem", domain)
        startActivity(intent)
    }

    override fun onInterrupt() {}
}
