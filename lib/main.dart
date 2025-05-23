import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:udemyflutter/Screens/checkout/checkout_page.dart';
import 'package:udemyflutter/Screens/feature/feature.dart';
import 'package:udemyflutter/Screens/home/homePage.dart';
import 'package:udemyflutter/Screens/mylearning/mylearning.dart';
import 'package:udemyflutter/Screens/splash/splash_screen.dart';
import 'package:udemyflutter/Screens/course_content/course_content_screen.dart';
import 'package:udemyflutter/generated/l10n.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Udemy-App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      locale: Locale('en'),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: 
      StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const SplashScreen();
        },
      ),
     
      onGenerateRoute: (settings) {
        if (settings.name == '/feature') {
          return MaterialPageRoute(builder: (_) => FeatureScreen());
        }
        if (settings.name == '/my-learning') {
          return MaterialPageRoute(builder: (_) => MyLearningScreen());
        }

        if (settings.name == '/checkout') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CheckoutPage(
              userId: args['userId'],
              cartItems: args['cartItems'],
            ),
          );
        }

        return MaterialPageRoute(builder: (_) => const SplashScreen());
      },
    );
  }
}

bool isArabic() {
  return Intl.getCurrentLocale() == 'ar';
}
