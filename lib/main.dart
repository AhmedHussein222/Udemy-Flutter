import 'package:flutter/material.dart';
// import 'package:udemyflutter/Screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:udemyflutter/Screens/feature/feature.dart';
import 'package:udemyflutter/Screens/splash/splash_screen.dart';
// import 'package:udemyflutter/Screens/mylearning/mylearning.dart';
// import 'package:udemyflutter/Screens/cart/cart_screen.dart';
import 'firebase_options.dart';

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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
      ),
      home: SplashScreen(),
       routes: {
    '/feature': (context) => FeatureScreen(), // غيري الاسم حسب اسم الصفحة اللي عندك
  },
      // home: CartScreen()
      // home: MyLearningScreen()
    );
  }
}

