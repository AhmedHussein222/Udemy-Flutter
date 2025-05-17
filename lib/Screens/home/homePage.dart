import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/account/account.dart';
import 'package:udemyflutter/Screens/feature/feature.dart';
import 'package:udemyflutter/Screens/mylearning/mylearning.dart';
import 'package:udemyflutter/Screens/search/search.dart';
import 'package:udemyflutter/Screens/wishlist/wishlist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 0;

  final List<NavigationDestination> bottomDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.star_border_outlined),
      selectedIcon: Icon(Icons.star),
      label: 'Feature',
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.video_library_outlined),
      selectedIcon: Icon(Icons.video_library),
      label: 'Learning',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_outline_outlined),
      selectedIcon: Icon(Icons.favorite),
      label: 'Wishlist',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_circle),
      selectedIcon: Icon(Icons.account_circle),
      label: 'Account',
    ),
  ];

  final List<Widget> pages = [
    FeatureScreen(),
    SearchScreen(),
    MylearningScreen(),
    WishlistScreen(),
    AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // بدون AppBar
      body: Stack(
        children: [
          pages[screenIndex],
          Positioned(
            top: 0,  
            right: 1, 
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
              onPressed: () {
        
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: screenIndex,
        onDestinationSelected: (int index) {
          setState(() {
            screenIndex = index;
          });
        },
        destinations: bottomDestinations,
      ),
    );
  }
}
