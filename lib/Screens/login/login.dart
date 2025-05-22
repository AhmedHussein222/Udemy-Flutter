import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Custombutton/custombuttton.dart';
import 'package:udemyflutter/Screens/home/homePage.dart';
import 'package:udemyflutter/Screens/signup/formsignup.dart';
import 'package:udemyflutter/generated/l10n.dart';
import 'package:intl/intl.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
// final Locale selectedLocale ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/Images/splash.webp',
                        height: 200,
                        width: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        S.of(context).titlelogin,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration:  InputDecoration(
                        hintText: S.of(context).Email,
                        hintStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration:  InputDecoration(
                        hintText: S.of(context).Password,
                        hintStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                   CustomButton(
  icon:  Icon(Icons.email ,size:isArabic()?15:30,),
  text: S.of(context).Loginemail,
  color: Colors.deepPurpleAccent,
  isOutlined: false,
  textColor: Colors.white,
  borderColor: Colors.transparent,
  borderWidth: 0,
  fontSize: isArabic() ? 0 : 10,


                    onPressed: () async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

                        try {
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

    final snackBar = SnackBar(
      content:  Text( S.of(context).Loginsuccessful),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(top: 1, left: 20, right: 20, bottom: 100),
      duration: const Duration(seconds: 1), 
    );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          });
                        } on FirebaseAuthException catch (e) {
                          String message = 'An error occurred';
                          if (e.code == 'user-not-found') {
                            message = 'No user found for that email.';
                          } else if (e.code == 'wrong-password') {
                            message = 'Wrong password provided.';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                bottom: 20,
                                left: 20,
                                right: 20,
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        S.of(context).options,
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          'assets/Images/google-logo.png',
                          () {},
                        ),
                        const SizedBox(width: 8),
                        _buildSocialButton('assets/Images/3536394.png', () {}),
                        const SizedBox(width: 8),
                        _buildSocialButton('assets/Images/mac-os.png', () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.grey.shade800,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: S.of(context).Haveaccount,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 215, 213, 220),
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: S.of(context).SignUp,
                          style: const TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontWeight: FontWeight.bold,
                        
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(imagePath, width: 30, height: 30),
      ),
    );
  }
}
bool isArabic()
{
  return Intl.getCurrentLocale() == 'ar';
}
