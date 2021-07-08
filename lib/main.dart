import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/pages/audio_page.dart';
import 'package:flutter_multiplication_trainer_app/pages/input_page.dart';
import 'package:flutter_multiplication_trainer_app/pages/settings_page.dart';
import 'package:flutter_multiplication_trainer_app/preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = sharedPrefsService;
  await prefs.initPrefs();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (BuildContext context) => InputPage(),
          'settings': (BuildContext context) => SettingsPage(),
          'audio': (BuildContext context) => AudioPage(),
        },
        theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF0A0E21),
          scaffoldBackgroundColor: Color(0xFF0A0E21),
        ),
      ),
    );
  }
}
