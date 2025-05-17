import 'package:flutter/material.dart';
import 'package:udemyflutter/Custombutton/custombuttton.dart';
import 'package:udemyflutter/Screens/signup/formsignup.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SignupScreen> {
    bool isChecked = false;
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/Images/value-prop-inspire-2x-v3.webp',
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        'Sign up  to continue your learning \n journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                  activeColor: Colors.deepPurpleAccent, 
                ),
                const SizedBox(width: 8),
                const Text(
                  'Send me special offers, personalized recommendations\n,and learning tips.',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
                    const SizedBox(height: 30),
                    CustomButton(
                      icon: const Icon(Icons.email),
                      text: "Sign up  with email",
                      color: Colors.deepPurpleAccent,
                      isOutlined: false,
                      textColor: Colors.white,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        '_____ Other login options _____',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 20),
                  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _buildSocialButton('assets/Images/google-logo.png', () {
   

    }),
    const SizedBox(width: 8),
    _buildSocialButton('assets/Images/3536394.png', () {
    
    }),
   
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
                  
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 215, 213, 220),
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: const TextStyle(
                            color: Colors.deepPurpleAccent,
                            // decoration: TextDecoration.underline,
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
      child: Image.asset(
        imagePath,
        width: 30,
        height: 30,
      ),
    ),
  );
}

  
}