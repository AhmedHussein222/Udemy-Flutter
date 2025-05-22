import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:udemyflutter/Screens/splash/splash_screen.dart';
import 'package:udemyflutter/generated/l10n.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
void main() async {

   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
            localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
     
      title: 'Udemy-App',
      debugShowCheckedModeBanner: false, 
      home: SplashScreen(),
    );
  }
}
bool isArabic()
{
  return Intl.getCurrentLocale() == 'ar';
}

