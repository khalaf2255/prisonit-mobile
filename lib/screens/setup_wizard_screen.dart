import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_status.dart';
import '../models/blocked_site.dart';
import '../services/blocking_service.dart';
import '../services/time_formatter.dart';

class DurationUnit {
  final String name;
  final int multiplier;
  DurationUnit(this.name, this.multiplier);
}

class SetupWizardScreen extends StatefulWidget {
  final VoidCallback onSetupFinished;

  const SetupWizardScreen({Key? key, required this.onSetupFinished}) : super(key: key);

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> with WidgetsBindingObserver {
  int _currentStep = 0;
  bool _isProductionMode = true;
  bool _enableAdultBlock = true;

  // Permissions state
  bool _isAccessibilityEnabled = false;
  bool _isOverlayGranted = false;
  bool _isBatteryIgnored = false;
  Timer? _permissionPollTimer;

  final TextEditingController _siteValueController = TextEditingController(text: "14");
  final TextEditingController _appValueController = TextEditingController(text: "30");

  late DurationUnit _selectedSiteUnit;
  late DurationUnit _selectedAppUnit;

  final List<DurationUnit> _productionUnits = [
    DurationUnit("يوم (Days)", 86400),
    DurationUnit("أسبوع (Weeks - 7 أيام)", 604800),
    DurationUnit("شهر (Months - 30 يوماً)", 2592000),
    DurationUnit("سنة (Years - 365 يوماً)", 31536000),
  ];

  final List<DurationUnit> _testingUnits = [
    DurationUnit("ثانية (Seconds)", 1),
    DurationUnit("دقيقة (Minutes)", 60),
    DurationUnit("ساعة (Hours)", 3600),
    DurationUnit("يوم (Days)", 86400),
    DurationUnit("أسبوع (Weeks - 7 أيام)", 604800),
    DurationUnit("شهر (Months - 30 يوماً)", 2592000),
    DurationUnit("سنة (Years - 365 يوماً)", 31536000),
  ];

  final List<String> _selectedSites = [
    'facebook.com',
    'youtube.com',
    'instagram.com',
    'tiktok.com',
    'x.com',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedSiteUnit = _productionUnits[0];
    _selectedAppUnit = _productionUnits[0];
    _checkPermissions();

    // Poll permissions every 1.5 seconds when wizard is open
    _permissionPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _checkPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionPollTimer?.cancel();
    _siteValueController.dispose();
    _appValueController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final acc = await BlockingService.isAccessibilityServiceEnabled();
    final over = await BlockingService.isOverlayPermissionGranted();
    final bat = await BlockingService.isBatteryOptimizationIgnored();

    if (mounted) {
      setState(() {
        _isAccessibilityEnabled = acc;
        _isOverlayGranted = over;
        _isBatteryIgnored = bat;
      });
    }
  }

  List<DurationUnit> get _activeUnits => _isProductionMode ? _productionUnits : _testingUnits;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111C),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/app.png', width: 26, height: 26),
            const SizedBox(width: 10),
            const Text(
              "PrisonIt Setup Wizard",
              style: TextStyle(color: Color(0xFFA5ACCD), fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildStepContent()),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPermissionsStep();
      case 2:
        return _buildModeStep();
      case 3:
        return _buildDurationStep();
      case 4:
        return _buildSitesStep();
      case 5:
        return _buildFinishStep();
      default:
        return Container();
    }
  }

  // STEP 0: WELCOME
  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/app.png', width: 110, height: 110),
          const SizedBox(height: 20),
          const Text("PrisonIt", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("اقفل المواقع والروابط المحظورة.. وحرر نفسك", style: TextStyle(color: Color(0xFFB194FF), fontSize: 15)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF181C30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3050)),
            ),
            child: const Text(
              "معالج الإعداد المباشر لتنظيم وضع التشغيل والعد التنازلي للمواقع المحظورة وتفعيل درع حظر الإباحية.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF697091), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1: ONE-CLICK PERMISSIONS SETUP
  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("تفعيل صلاحيات الحماية الصارمة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("الخطوة 1 من 5 - تفعيل مراقبة المتصفح ومنع التجاوز", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
          const SizedBox(height: 16),
          const Text(
            "اضغط على الأزرار بالأسفل لتفعيل الصلاحيات مباشرة بنقرة واحدة:",
            style: TextStyle(color: Color(0xFFA5ACCD), fontSize: 13),
          ),
          const SizedBox(height: 18),

          // 1. Accessibility Tile (Crucial)
          _buildPermissionTile(
            title: "خدمة مراقبة المواقع (Accessibility)",
            desc: "لقراءة روابط المتصفح وإغلاق المواقع المحظورة لحظياً.",
            isGranted: _isAccessibilityEnabled,
            buttonText: "اضغط للتفعيل ➔",
            onTap: () => BlockingService.requestAccessibilityPermission(),
            isRequired: true,
          ),
          const SizedBox(height: 12),

          // 2. Overlay Tile
          _buildPermissionTile(
            title: "الظهور فوق التطبيقات (Display Over Apps)",
            desc: "لعرض شاشة القفل المحفزة فور محاولة فتح الموقع المحظور.",
            isGranted: _isOverlayGranted,
            buttonText: "اضغط للسماح ➔",
            onTap: () => BlockingService.requestOverlayPermission(),
            isRequired: false,
          ),
          const SizedBox(height: 12),

          // 3. Battery Optimization Tile
          _buildPermissionTile(
            title: "استمرار الحماية بالخلفية (Battery Optimization)",
            desc: "لمنع نظام أندرويد من إيقاف خدمة الحظر لتوفير البطارية.",
            isGranted: _isBatteryIgnored,
            buttonText: "اضغط للاستثناء ➔",
            onTap: () => BlockingService.requestIgnoreBatteryOptimization(),
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String desc,
    required bool isGranted,
    required String buttonText,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181C30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted ? const Color(0xFF34D399) : (isRequired ? const Color(0xFF7C4DFF) : const Color(0xFF2A3050)),
          width: isGranted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle : (isRequired ? Icons.error_outline : Icons.info_outline),
                color: isGranted ? const Color(0xFF34D399) : const Color(0xFFB194FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (isGranted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10281C),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF34D399)),
                  ),
                  child: const Text("✓ مفعل", style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF697091), fontSize: 12)),
          if (!isGranted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 2: MODE SELECTION
  Widget _buildModeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("اختر وضع التشغيل لنظام الحماية", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("الخطوة 2 من 5 - تحديد شدة الانضباط", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
          const SizedBox(height: 20),
          // Production Card
          GestureDetector(
            onTap: () {
              setState(() {
                _isProductionMode = true;
                _selectedSiteUnit = _productionUnits[0];
                _selectedAppUnit = _productionUnits[0];
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181C30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isProductionMode ? const Color(0xFF7C4DFF) : const Color(0xFF2A3050), width: 2),
              ),
              child: Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _isProductionMode,
                    activeColor: const Color(0xFF7C4DFF),
                    onChanged: (val) {
                      setState(() {
                        _isProductionMode = true;
                        _selectedSiteUnit = _productionUnits[0];
                        _selectedAppUnit = _productionUnits[0];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🛡️ وضع الإنتاج الصارم (Production Mode)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text("فترات الانتظار بالأيام أو الأسابيع. قفل حاسم لا يمكن التراجع عنه حتى انتهاء العداد.", style: TextStyle(color: Color(0xFF697091), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Testing Card
          GestureDetector(
            onTap: () {
              setState(() {
                _isProductionMode = false;
                _selectedSiteUnit = _testingUnits[0];
                _selectedAppUnit = _testingUnits[0];
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181C30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: !_isProductionMode ? const Color(0xFF7C4DFF) : const Color(0xFF2A3050), width: 2),
              ),
              child: Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: _isProductionMode,
                    activeColor: const Color(0xFF7C4DFF),
                    onChanged: (val) {
                      setState(() {
                        _isProductionMode = false;
                        _selectedSiteUnit = _testingUnits[0];
                        _selectedAppUnit = _testingUnits[0];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🧪 وضع التجربة والتأهيل (Testing Mode)", style: TextStyle(color: Color(0xFFB194FF), fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text("فترات الانتظار بالثواني أو الدقائق لاختبار وظائف البرنامج بسهولة.", style: TextStyle(color: Color(0xFF697091), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Anti-Porn Checkbox
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF181C30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3050)),
            ),
            child: CheckboxListTile(
              value: _enableAdultBlock,
              activeColor: const Color(0xFF7C4DFF),
              title: const Text("🔞 تفعيل درع حظر الإباحية التلقائي", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text("حجب الكلمات المفتاحية والمواقع الإباحية والشبكات غير اللائقة تلقائياً.", style: TextStyle(color: Color(0xFF697091), fontSize: 11)),
              onChanged: (val) => setState(() => _enableAdultBlock = val ?? true),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: DURATION SELECTION
  Widget _buildDurationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("حدد فترات الانتظار الصارمة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("الخطوة 3 من 5 - مهلة فك القفل وحذف التطبيق", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
          const SizedBox(height: 20),

          // 1. Single Site Duration
          _buildDurationCard(
            title: "⏳ مدة فك قفل الموقع الواحد (Unlock Delay)",
            desc: "كم تنتظر بعد طلب رفع الحظر عن موقع محدد:",
            controller: _siteValueController,
            selectedUnit: _selectedSiteUnit,
            onUnitChanged: (unit) => setState(() => _selectedSiteUnit = unit),
          ),
          const SizedBox(height: 16),

          // 2. Full App Uninstall Duration
          _buildDurationCard(
            title: "⚠️ مدة إلغاء تثبيت التطبيق كاملاً (App Uninstall)",
            desc: "كم تنتظر بعد طلب حذف وإلغاء تطبيق PrisonIt نهائياً:",
            controller: _appValueController,
            selectedUnit: _selectedAppUnit,
            onUnitChanged: (unit) => setState(() => _selectedAppUnit = unit),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard({
    required String title,
    required String desc,
    required TextEditingController controller,
    required DurationUnit selectedUnit,
    required ValueChanged<DurationUnit> onUnitChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181C30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Color(0xFF697091), fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 44,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: const Color(0xFF0F111C),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2A3050))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7C4DFF))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F111C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A3050)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DurationUnit>(
                      value: selectedUnit,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF181C30),
                      items: _activeUnits.map((u) {
                        return DropdownMenuItem<DurationUnit>(
                          value: u,
                          child: Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onUnitChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 4: BLOCKED SITES
  Widget _buildSitesStep() {
    final defaults = [
      {'name': 'Facebook & Messenger', 'domain': 'facebook.com', 'icon': '📱'},
      {'name': 'YouTube', 'domain': 'youtube.com', 'icon': '🎥'},
      {'name': 'Instagram', 'domain': 'instagram.com', 'icon': '📸'},
      {'name': 'TikTok', 'domain': 'tiktok.com', 'icon': '🎵'},
      {'name': 'Twitter / X', 'domain': 'x.com', 'icon': '🐦'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("حدد المواقع المراد حبسها فوراً", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("الخطوة 4 من 5 - قائمة النطاقات المحظورة", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
          const SizedBox(height: 16),
          ...defaults.map((s) {
            bool isSelected = _selectedSites.contains(s['domain']);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF181C30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFF2A3050)),
              ),
              child: CheckboxListTile(
                value: isSelected,
                title: Text("${s['icon']} ${s['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(s['domain']!, style: const TextStyle(color: Color(0xFF697091), fontSize: 11)),
                activeColor: const Color(0xFF7C4DFF),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedSites.add(s['domain']!);
                    } else {
                      _selectedSites.remove(s['domain']!);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // STEP 5: FINISH & CONFIRM
  Widget _buildFinishStep() {
    int siteVal = int.tryParse(_siteValueController.text) ?? 1;
    int appVal = int.tryParse(_appValueController.text) ?? 1;
    int siteTotalSec = siteVal * _selectedSiteUnit.multiplier;
    int appTotalSec = appVal * _selectedAppUnit.multiplier;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("تأكيد وتفعيل الحماية الصارمة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("الخطوة الأخيرة - مراجعة الإعدادات وتطبيق القفل", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
          const SizedBox(height: 20),
          Container(
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
                  _isProductionMode ? "🛡️ وضع الإنتاج الصارم (PRODUCTION)" : "🧪 وضع التجربة (TESTING)",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text("• مدة قفل الموقع: ${TimeFormatter.formatArabicTimeSpanFromSeconds(siteTotalSec)}", style: const TextStyle(color: Color(0xFFA5ACCD), fontSize: 12)),
                const SizedBox(height: 4),
                Text("• مدة حذف التطبيق: ${TimeFormatter.formatArabicTimeSpanFromSeconds(appTotalSec)}", style: const TextStyle(color: Color(0xFFA5ACCD), fontSize: 12)),
                const SizedBox(height: 4),
                Text("• درع حظر الإباحية: ${_enableAdultBlock ? 'مفعل 🔞' : 'معطل ❌'}", style: const TextStyle(color: Color(0xFFA5ACCD), fontSize: 12)),
                const SizedBox(height: 4),
                Text("• النطاقات المحظورة: ${_selectedSites.length} موقع", style: const TextStyle(color: Color(0xFFA5ACCD), fontSize: 12)),
                const SizedBox(height: 4),
                Text("• مراقبة المتصفح: ${_isAccessibilityEnabled ? 'نشطة ✓' : 'يرجى التفعيل'}", style: TextStyle(color: _isAccessibilityEnabled ? const Color(0xFF34D399) : const Color(0xFFF87171), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0F111C),
        border: Border(top: BorderSide(color: Color(0xFF2A3050))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A3050))),
              child: const Text("السابق", style: TextStyle(color: Color(0xFFA5ACCD))),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: () {
              if (_currentStep == 1 && !_isAccessibilityEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("يرجى الضغط على زر تفعيل خدمة مراقبة المواقع للمتابعة."),
                    backgroundColor: Color(0xFF7C4DFF),
                  ),
                );
                return;
              }

              if (_currentStep < 5) {
                setState(() => _currentStep++);
              } else {
                _finalizeSetup();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
            child: Text(_currentStep == 5 ? "تأكيد وقفل الإعدادات فوراً 🔒" : "التالي →", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _finalizeSetup() async {
    int siteVal = int.tryParse(_siteValueController.text) ?? 1;
    int appVal = int.tryParse(_appValueController.text) ?? 1;
    int siteTotalSec = siteVal * _selectedSiteUnit.multiplier;
    int appTotalSec = appVal * _selectedAppUnit.multiplier;

    int siteDays = _isProductionMode ? (siteTotalSec / 86400).round() : siteTotalSec;
    int appDays = _isProductionMode ? (appTotalSec / 86400).round() : appTotalSec;

    final status = AppStatus(
      setupCompleted: true,
      isProduction: _isProductionMode,
      siteDays: siteDays <= 0 ? 1 : siteDays,
      appDays: appDays <= 0 ? 1 : appDays,
      adultBlock: _enableAdultBlock,
      productionStartTime: DateTime.now().microsecondsSinceEpoch * 10,
      blockedSites: _selectedSites.map((d) => BlockedSite(domain: d)).toList(),
    );

    await BlockingService.saveStatus(status);
    await BlockingService.startLocalVpn();
    widget.onSetupFinished();
  }
}
