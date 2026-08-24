import 'package:flutter/material.dart';
import '../models/app_status.dart';
import '../models/blocked_site.dart';
import '../services/blocking_service.dart';
import '../services/motivational_quotes_service.dart';
import '../services/time_formatter.dart';

class HomeScreen extends StatefulWidget {
  final AppStatus status;
  final VoidCallback onRefresh;

  const HomeScreen({
    Key? key,
    required this.status,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _addDomainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int dayCount = 1;
    if (widget.status.productionStartTime > 0) {
      int nowMicros = DateTime.now().microsecondsSinceEpoch;
      int startMicros = widget.status.productionStartTime ~/ 10;
      int diffSec = (nowMicros - startMicros) ~/ 1000000;
      dayCount = (diffSec ~/ 86400) + 1;
    }

    String dailyQuote = MotivationalQuotesService.getDailyQuote(dayCount);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111C),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/app.png', width: 28, height: 28),
            const SizedBox(width: 10),
            const Text(
              "PrisonIt Mobile Guard",
              style: TextStyle(
                color: Color(0xFFF5F6FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFB194FF)),
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode & Status Badges Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.status.isProduction ? const Color(0xFF181C30) : const Color(0xFF142332),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.status.isProduction ? const Color(0xFF7C4DFF) : const Color(0xFF28506E),
                      ),
                    ),
                    child: Text(
                      widget.status.isProduction ? "🛡️ PRODUCTION (صارم)" : "🧪 TESTING MODE (تجربة)",
                      style: TextStyle(
                        color: widget.status.isProduction ? const Color(0xFFF5F6FF) : const Color(0xFF64C8FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Daily Motivational Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF121524),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A3050)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "✨ رسالة اليوم والتحفيز ✨",
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dailyQuote,
                      style: const TextStyle(color: Color(0xFFF5F6FF), fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Lock Duration Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181C30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C4DFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.status.isProduction
                          ? "🔒 مدة فك قفل الموقع الواحد: ${widget.status.siteDays} يوم  |  فك التطبيق: ${widget.status.appDays} يوم"
                          : "🧪 مدة فك قفل الموقع للتجربة: ${widget.status.siteDays} ثانية  |  فك التطبيق: ${widget.status.appDays} ثانية",
                      style: const TextStyle(color: Color(0xFFF5F6FF), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Section Header: Blocked Sites
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "المواقع المحظورة (${widget.status.blockedSites.length})",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF7C4DFF), size: 28),
                    onPressed: _showAddDomainDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.status.blockedSites.map((site) => _buildSiteCard(site)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteCard(BlockedSite site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181C30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: site.isUnlocking ? const Color(0xFFF87171) : const Color(0xFF2A3050)),
      ),
      child: Row(
        children: [
          const Text("🌐", style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site.domain,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  site.isUnlocking
                      ? "🔒 قيد فك القفل: متبقي ${TimeFormatter.formatArabicTimeSpanFromSeconds(site.remainingSeconds)}"
                      : "🔒 محظور ومقفول بصرامة",
                  style: TextStyle(
                    color: site.isUnlocking ? const Color(0xFFF87171) : const Color(0xFF697091),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!site.isUnlocking && !site.isUnlocked)
            ElevatedButton(
              onPressed: () => _requestUnlockSite(site),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D1216),
                side: const BorderSide(color: Color(0xFF6E232D)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              child: const Text("فك القفل", style: TextStyle(color: Color(0xFFF87171), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  void _showAddDomainDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181C30),
        title: const Text("إضافة موقع محظور جديد", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _addDomainController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "مثال: reddit.com",
            hintStyle: TextStyle(color: Color(0xFF697091)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7C4DFF))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Color(0xFFA5ACCD))),
          ),
          ElevatedButton(
            onPressed: () {
              String raw = _addDomainController.text.trim().toLowerCase();
              if (raw.isNotEmpty) {
                String dom = raw.replaceAll("https://", "").replaceAll("http://", "").split('/')[0];
                if (!widget.status.blockedSites.any((s) => s.domain == dom)) {
                  widget.status.blockedSites.add(BlockedSite(domain: dom));
                  BlockingService.saveStatus(widget.status);
                  widget.onRefresh();
                }
              }
              _addDomainController.clear();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
            child: const Text("حفظ وحظر", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _requestUnlockSite(BlockedSite site) async {
    int delaySeconds = widget.status.isProduction ? widget.status.siteDays * 86400 : widget.status.siteDays;
    
    int index = widget.status.blockedSites.indexWhere((s) => s.domain == site.domain);
    if (index >= 0) {
      widget.status.blockedSites[index] = BlockedSite(
        domain: site.domain,
        reqTime: DateTime.now().microsecondsSinceEpoch * 10,
        remainingSeconds: delaySeconds,
      );
      await BlockingService.saveStatus(widget.status);
      widget.onRefresh();
    }
  }
}
