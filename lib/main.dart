import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/app_status.dart';
import 'screens/home_screen.dart';
import 'screens/setup_wizard_screen.dart';
import 'services/blocking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrisonItApp());
}

class PrisonItApp extends StatefulWidget {
  const PrisonItApp({Key? key}) : super(key: key);

  @override
  State<PrisonItApp> createState() => _PrisonItAppState();
}

class _PrisonItAppState extends State<PrisonItApp> {
  AppStatus _status = AppStatus();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await BlockingService.getStatus();
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrisonIt Mobile',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D16),
        fontFamily: 'Tajawal',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C4DFF),
          secondary: Color(0xFFB194FF),
          surface: Color(0xFF181C30),
          background: Color(0xFF0B0D16),
        ),
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
              ),
            )
          : (_status.setupCompleted
              ? HomeScreen(
                  status: _status,
                  onRefresh: _loadStatus,
                )
              : SetupWizardScreen(
                  onSetupFinished: _loadStatus,
                )),
    );
  }
}
