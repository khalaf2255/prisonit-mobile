import 'package:flutter/material.dart';
import '../services/motivational_quotes_service.dart';

class BlockOverlayScreen extends StatelessWidget {
  final String blockedItem;
  final int dayCount;

  const BlockOverlayScreen({
    Key? key,
    required this.blockedItem,
    required this.dayCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quote = MotivationalQuotesService.getDailyQuote(dayCount);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 3D Cage Logo
              Image.asset(
                'assets/app.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                "الموقع / التطبيق محبوس 🔒",
                style: TextStyle(
                  color: Color(0xFFF5F6FF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF181C30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7C4DFF), width: 1),
                ),
                child: Text(
                  blockedItem,
                  style: const TextStyle(
                    color: Color(0xFFB194FF),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Daily Motivational Quote Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121524),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A3050)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33651FFF),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "✨ رسالة اليوم والتحفيز ✨",
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFF5F6FF),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    "العودة للحرية والانضباط",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
