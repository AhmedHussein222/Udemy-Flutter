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

  final List<NavigationDestination> bottomDestinations = [
    NavigationDestination(
      icon: Icon(Icons.star_border_outlined, color: Colors.grey[400]),
      selectedIcon: Icon(Icons.star, color: Colors.white),
      label: 'Feature',
    ),
    NavigationDestination(
      icon: Icon(Icons.search, color: Colors.grey[400]),
      selectedIcon: Icon(Icons.search, color: Colors.white),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.video_library_outlined, color: Colors.grey[400]),
      selectedIcon: Icon(Icons.video_library, color: Colors.white),
      label: 'Learning',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border_outlined, color: Colors.grey[400]),
      selectedIcon: Icon(Icons.favorite, color: Colors.white),
      label: 'Wishlist',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_circle_outlined, color: Colors.grey[400]),
      selectedIcon: Icon(Icons.account_circle, color: Colors.white),
      label: 'Account',
    ),
  ];

  final List<Widget> pages = [
    FeatureScreen(),
    SubCategoryPage(),
    MylearningScreen(),
    WishlistScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          pages[screenIndex],
          Positioned(
            top: 0,
            right: 1,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.grey[800]), 
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart feature coming soon!'),
                    backgroundColor: Colors.blueAccent,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.black,
          indicatorColor: Colors.blueAccent.withOpacity(0.2), 
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontSize: 12),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.grey);
          }),
          overlayColor: WidgetStateProperty.all(Colors.grey[800])
        ),
        child: NavigationBar(
          selectedIndex: screenIndex,
          onDestinationSelected: (int index) {
            setState(() {
              screenIndex = index;
            });
          },
          destinations: bottomDestinations,
        ),
      ),
    );
  }
}