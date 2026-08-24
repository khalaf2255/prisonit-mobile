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

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 0;
  bool _isProductionMode = true;
  bool _enableAdultBlock = true;

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
    _selectedSiteUnit = _productionUnits[0];
    _selectedAppUnit = _productionUnits[0];
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
        return _buildModeStep();
      case 2:
        return _buildDurationStep();
      case 3:
        return _buildSitesStep();
      case 4:
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

  // STEP 1: MODE SELECTION
  Widget _buildModeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("اختر وضع التشغيل لنظام الحماية", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("الخطوة 1 من 4 - تحديد شدة الانضباط", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
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
              color: const Color(0xFF1C162D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF503282)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _enableAdultBlock,
                  activeColor: const Color(0xFF34D399),
                  onChanged: (val) => setState(() => _enableAdultBlock = val ?? true),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🔞 تفعيل درع حظر الإباحية (Anti-Porn Shield)", style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(height: 2),
                      Text("فرض البحث الآمن SafeSearch وحظر المواقع الإباحية بالكامل.", style: TextStyle(color: Color(0xFF697091), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: DURATION SELECTION WITH DROPDOWN
  Widget _buildDurationStep() {
    int siteVal = int.tryParse(_siteValueController.text) ?? 1;
    int appVal = int.tryParse(_appValueController.text) ?? 1;
    int siteTotalSec = siteVal * _selectedSiteUnit.multiplier;
    int appTotalSec = appVal * _selectedAppUnit.multiplier;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("تحديد مدة العد التنازلي لإلغاء القفل", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_isProductionMode ? "الخطوة 2 من 4 - تحديد فترات العد التنازلي (أيام فأكثر)" : "الخطوة 2 من 4 - تحديد فترات التجربة", style: const TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
          const SizedBox(height: 20),
          // Single site delay
          const Text("1. مدة إلغاء قفل الموقع الواحد:", style: TextStyle(color: Color(0xFFB194FF), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _siteValueController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF181C30),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7C4DFF))),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181C30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF7C4DFF), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DurationUnit>(
                      value: _activeUnits.contains(_selectedSiteUnit) ? _selectedSiteUnit : _activeUnits[0],
                      dropdownColor: const Color(0xFF181C30),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      onChanged: (val) => setState(() => _selectedSiteUnit = val!),
                      items: _activeUnits.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "✨ قفل الموقع: ${TimeFormatter.formatArabicTimeSpanFromSeconds(siteTotalSec)}",
            style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // App Uninstall delay
          const Text("2. مدة حذف/فك تثبيت التطبيق بالكامل:", style: TextStyle(color: Color(0xFFB194FF), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _appValueController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF181C30),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7C4DFF))),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181C30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF7C4DFF), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DurationUnit>(
                      value: _activeUnits.contains(_selectedAppUnit) ? _selectedAppUnit : _activeUnits[0],
                      dropdownColor: const Color(0xFF181C30),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      onChanged: (val) => setState(() => _selectedAppUnit = val!),
                      items: _activeUnits.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "✨ قفل التطبيق: ${TimeFormatter.formatArabicTimeSpanFromSeconds(appTotalSec)}",
            style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // STEP 3: SITES SELECTION
  Widget _buildSitesStep() {
    final List<Map<String, String>> defaults = [
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
          const Text("الخطوة 3 من 4 - قائمة النطاقات المحظورة", style: TextStyle(color: Color(0xFFB194FF), fontSize: 12)),
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

  // STEP 4: FINISH & CONFIRM
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
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _finalizeSetup();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
            child: Text(_currentStep == 4 ? "تأكيد وقفل الإعدادات فوراً 🔒" : "التالي →", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    widget.onSetupFinished();
  }
}
