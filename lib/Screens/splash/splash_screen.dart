import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> splashData = [
    {
      "image": "assets/Images/lohp-category-business-2x-v2.webp",
      "title": "Task Video Courses",
      "subtitle": "From cooking to coding\nand everything in between"
    },
    {
      "image": "assets/Images/value-prop-teach-2x-v3.webp",
      "title": "Learn from the Best",
      "subtitle": "Approachable expert-instructors, \n vetted by more than 50 million learners"
    },
    {
      "image": "assets/Images/value-prop-inspire-2x-v3.webp",
      "title": "Go at Your Own Pace",
      "subtitle": "Lifetime access to purchased courses, \n anytime, anywhere"
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        splashData.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.white : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: PageView.builder(
              controller: _pageController,
              itemCount: splashData.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      splashData[index]["image"]!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 30),
                    Text(
                      splashData[index]["title"]!,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      splashData[index]["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 20),
          _buildDots(),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Sign In'),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
