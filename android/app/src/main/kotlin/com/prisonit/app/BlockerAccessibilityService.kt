package com.prisonit.app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONObject

class BlockerAccessibilityService : AccessibilityService() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val STATUS_KEY = "flutter.prisonit_app_status"

        private var blockedDomains = mutableListOf<String>()
        private var isAdultBlockEnabled = true

        private val BROWSER_PACKAGES = setOf(
            "com.android.chrome",
            "com.chrome.beta",
            "com.chrome.canary",
            "com.chrome.dev",
            "com.google.android.apps.chrome",
            "com.sec.android.app.sbrowser",
            "com.sec.android.app.sbrowser.beta",
            "org.mozilla.firefox",
            "org.mozilla.firefox_beta",
            "org.mozilla.fenix",
            "org.mozilla.focus",
            "com.microsoft.emmx",
            "com.microsoft.emmx.canary",
            "com.microsoft.emmx.dev",
            "com.brave.browser",
            "com.opera.browser",
            "com.opera.mini.native",
            "com.opera.gx",
            "com.duckduckgo.mobile.android",
            "com.UCMobile.intl",
            "com.kiwibrowser.browser",
            "mark.via.gp",
            "com.ecosia.android",
            "com.vivaldi.browser"
        )

        private val ADULT_KEYWORDS = listOf(
            "porn", "xxx", "xvideos", "pornhub", "xhamster", "xnxx", "redtube",
            "youporn", "erotic", "sex", "nude", "stripchat", "chaturbate",
            "onlyfans", "camsoda", "livejasmin", "brazzers", "spankbang", "eporner"
        )

        fun updateConfig(context: Context, jsonStr: String) {
            try {
                val json = JSONObject(jsonStr)
                isAdultBlockEnabled = json.optBoolean("adultBlock", true)
                val rawSites = json.optJSONArray("blockedSites")
                blockedDomains.clear()
                if (rawSites != null) {
                    for (i in 0 until rawSites.length()) {
                        val site = rawSites.getJSONObject(i)
                        val domain = cleanDomain(site.optString("domain", ""))
                        if (domain.isNotEmpty()) {
                            blockedDomains.add(domain)
                        }
                    }
                }

                // Persist to local prefs for background restarts
                val prefs: SharedPreferences = context.getSharedPreferences("prisonit_native_prefs", Context.MODE_PRIVATE)
                prefs.edit()
                    .putString("cached_config", jsonStr)
                    .apply()
            } catch (_: Exception) {}
        }

        private fun cleanDomain(raw: String): String {
            var d = raw.trim().lowercase()
            d = d.replace("https://", "").replace("http://", "")
            if (d.startsWith("www.")) d = d.substring(4)
            val slash = d.indexOf('/')
            if (slash >= 0) d = d.substring(0, slash)
            return d.trim()
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        loadPersistedConfig()
    }

    private fun loadPersistedConfig() {
        try {
            // First try flutter prefs
            val flutterPrefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonStr = flutterPrefs.getString(STATUS_KEY, null)
            if (!jsonStr.isNullOrEmpty()) {
                updateConfig(this, jsonStr)
                return
            }

            // Fallback to native prefs
            val nativePrefs = getSharedPreferences("prisonit_native_prefs", Context.MODE_PRIVATE)
            val nativeJson = nativePrefs.getString("cached_config", null)
            if (!nativeJson.isNullOrEmpty()) {
                updateConfig(this, nativeJson)
            }
        } catch (_: Exception) {}
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val packageName = event.packageName?.toString() ?: return

        // 1. Anti-Tampering: Prevent opening PrisonIt in Settings (Force Stop / Uninstall / Clear Data)
        if (packageName == "com.android.settings") {
            val rootNode = rootInActiveWindow ?: return
            val textNodes = mutableListOf<AccessibilityNodeInfo>()
            findTextNodes(rootNode, textNodes)

            for (node in textNodes) {
                val text = node.text?.toString()?.lowercase() ?: ""
                if (text.contains("prisonit") || text.contains("إلغاء التثبيت") || text.contains("uninstall") || text.contains("force stop") || text.contains("مسح البيانات")) {
                    performGlobalAction(GLOBAL_ACTION_HOME)
                    break
                }
            }
            return
        }

        // 2. Browser Inspection
        if (BROWSER_PACKAGES.contains(packageName) || isBrowserLike(packageName)) {
            val rootNode = rootInActiveWindow ?: return
            val detectedUrl = extractUrlFromBrowser(rootNode)

            if (!detectedUrl.isNullOrEmpty()) {
                val cleanedUrl = cleanDomain(detectedUrl)

                // Check custom blocked domains
                for (domain in blockedDomains) {
                    if (cleanedUrl.contains(domain) || detectedUrl.contains(domain)) {
                        triggerBlock(domain)
                        return
                    }
                }

                // Check adult sites if enabled
                if (isAdultBlockEnabled) {
                    for (keyword in ADULT_KEYWORDS) {
                        if (cleanedUrl.contains(keyword) || detectedUrl.contains(keyword)) {
                            triggerBlock(keyword)
                            return
                        }
                    }
                }
            }
        }
    }

    private fun isBrowserLike(pkg: String): Boolean {
        val p = pkg.lowercase()
        return p.contains("browser") || p.contains("chrome") || p.contains("firefox") || p.contains("opera")
    }

    private fun extractUrlFromBrowser(root: AccessibilityNodeInfo): String? {
        // Priority 1: Search by standard address bar view resource IDs
        val knownIds = listOf(
            "url_bar", "search_box_text", "location_bar_edit_text",
            "url_bar_title", "mozac_browser_toolbar_url_view",
            "toolbar_url", "addressbar", "display_url", "address_bar"
        )

        for (id in knownIds) {
            val nodes = root.findAccessibilityNodeInfosByViewId("com.android.chrome:id/$id")
            if (nodes.isNotEmpty()) {
                val text = nodes[0].text?.toString()
                if (!text.isNullOrEmpty()) return text.lowercase()
            }
        }

        // Priority 2: Recursive search across all nodes
        return findUrlInHierarchy(root)
    }

    private fun findUrlInHierarchy(node: AccessibilityNodeInfo?): String? {
        if (node == null) return null

        val viewId = node.viewIdResourceName?.lowercase() ?: ""
        val text = node.text?.toString()?.lowercase() ?: ""
        val desc = node.contentDescription?.toString()?.lowercase() ?: ""

        if (viewId.contains("url") || viewId.contains("location") || viewId.contains("address") || viewId.contains("search")) {
            if (text.isNotEmpty() && (text.contains(".") || text.contains("http") || text.contains("www"))) {
                return text
            }
            if (desc.isNotEmpty() && (desc.contains(".") || desc.contains("http") || desc.contains("www"))) {
                return desc
            }
        }

        if (node.className != null) {
            val cls = node.className.toString()
            if (cls.contains("EditText") || cls.contains("TextView")) {
                if (text.isNotEmpty() && (text.contains(".com") || text.contains(".net") || text.contains(".org") || text.contains(".io") || text.contains(".co") || text.contains("http"))) {
                    return text
                }
            }
        }

        for (i in 0 until node.childCount) {
            val res = findUrlInHierarchy(node.getChild(i))
            if (res != null) return res
        }

        return null
    }

    private fun triggerBlock(blockedDomain: String) {
        performGlobalAction(GLOBAL_ACTION_BACK)
        performGlobalAction(GLOBAL_ACTION_HOME)

        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("blockedItem", blockedDomain)
        }
        startActivity(intent)
    }

    private fun findTextNodes(node: AccessibilityNodeInfo?, list: MutableList<AccessibilityNodeInfo>) {
        if (node == null) return
        if (node.text != null) list.add(node)
        for (i in 0 until node.childCount) {
            findTextNodes(node.getChild(i), list)
        }
    }

    override fun onInterrupt() {}
}
