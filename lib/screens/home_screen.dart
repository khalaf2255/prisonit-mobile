import 'dart:async';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _addDomainController = TextEditingController();
  bool _isAccessibilityEnabled = true;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccessibility();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkAccessibility();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    _addDomainController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibility();
      widget.onRefresh();
    }
  }

  Future<void> _checkAccessibility() async {
    final enabled = await BlockingService.isAccessibilityServiceEnabled();
    if (mounted && _isAccessibilityEnabled != enabled) {
      setState(() {
        _isAccessibilityEnabled = enabled;
      });
    }
  }

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
            onPressed: () {
              _checkAccessibility();
              widget.onRefresh();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Permission Warning Banner if disabled
              if (!_isAccessibilityEnabled)
                GestureDetector(
                  onTap: () async {
                    await BlockingService.requestAccessibilityPermission();
                    _checkAccessibility();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1015),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF87171), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFF87171), size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("⚠️ الحماية متوقفة حالياً!", style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(height: 2),
                              Text("اضغط هنا لتفعيل إمكانية الوصول وبدء حظر المواقع.", style: TextStyle(color: Color(0xFFFFC0C0), fontSize: 11)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFFF87171), size: 14),
                      ],
                    ),
                  ),
                ),

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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isAccessibilityEnabled ? const Color(0xFF10281C) : const Color(0xFF2E1015),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isAccessibilityEnabled ? const Color(0xFF34D399) : const Color(0xFFF87171),
                      ),
                    ),
                    child: Text(
                      _isAccessibilityEnabled ? "🟢 المراقبة نشطة" : "🔴 المراقبة متوقفة",
                      style: TextStyle(
                        color: _isAccessibilityEnabled ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        fontSize: 11,
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
                          ? "🔒 فك قفل الموقع: ${widget.status.siteDays} يوم  |  حذف التطبيق: ${widget.status.appDays} يوم"
                          : "🧪 فك قفل الموقع: ${widget.status.siteDays} ثانية  |  حذف التطبيق: ${widget.status.appDays} ثانية",
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181C30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text("🔒", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.domain,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  const Text("محبوس ومحجوب تماماً", style: TextStyle(color: Color(0xFF697091), fontSize: 11)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _requestUnlock(site),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3050),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("طلب فك القفل", style: TextStyle(color: Color(0xFFA5ACCD), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAddDomainDialog() {
    _addDomainController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181C30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("إضافة موقع للحبس 🔒", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: _addDomainController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "مثال: zara.com أو reddit.com",
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
            onPressed: () async {
              String domain = _addDomainController.text.trim().toLowerCase();
              if (domain.isNotEmpty) {
                domain = domain.replaceAll("https://", "").replaceAll("http://", "").replaceAll("www.", "");
                int slash = domain.indexOf('/');
                if (slash >= 0) domain = domain.substring(0, slash);

                if (!widget.status.blockedSites.any((s) => s.domain == domain)) {
                  widget.status.blockedSites.add(BlockedSite(domain: domain));
                  await BlockingService.saveStatus(widget.status);
                  Navigator.pop(ctx);
                  widget.onRefresh();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
            child: const Text("حبس الموقع 🔒", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _requestUnlock(BlockedSite site) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181C30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("بدء العد التنازلي لفك قفل '${site.domain}'؟", style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          "سيبدأ عداد تنازلي مدته ${widget.status.siteDays} ${widget.status.isProduction ? 'يوم' : 'ثانية'}.\nسيبقى الموقع محظوراً بالكامل خلال هذه المدة.",
          style: const TextStyle(color: Color(0xFFA5ACCD), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Color(0xFFA5ACCD))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("بدأ العد التنازلي لفك '${site.domain}'")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
            child: const Text("بدء العد التنازلي", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
