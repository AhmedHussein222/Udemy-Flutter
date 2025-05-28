import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/account/account.dart';
import 'package:udemyflutter/Screens/feature/feature.dart';
import 'package:udemyflutter/Screens/mylearning/mylearning.dart';
import 'package:udemyflutter/Screens/search/search.dart';
import 'package:udemyflutter/Screens/wishlist/wishlist.dart';
import 'package:udemyflutter/Screens/cart/cart_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:udemyflutter/generated/l10n.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 0;

  final List<Widget> pages = [
    const FeatureScreen(),
    const SubCategoryPage(),
    const MyLearningScreen(),
    const WishlistScreen(),
    const AccountScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

  final List<Widget> bottomDestinations = [
  NavigationDestination(
    icon: Icon(Icons.star_border_outlined, color: Colors.grey[400]),
    selectedIcon: const Icon(Icons.star, color: Colors.white),
    label: S.of(context).feature,
  ),
  NavigationDestination(
    icon: Icon(Icons.search, color: Colors.grey[400]),
    selectedIcon: const Icon(Icons.search, color: Colors.white),
    label: S.of(context).search,
  ),
  NavigationDestination(
    icon: Icon(Icons.video_library_outlined, color: Colors.grey[400]),
    selectedIcon: const Icon(Icons.video_library, color: Colors.white),
    label: S.of(context)!.learning,
  ),
  StreamBuilder<DocumentSnapshot>(
    stream: user != null
        ? FirebaseFirestore.instance
            .collection('Wishlists')
            .doc(user.uid)
            .snapshots()
        : Stream.empty(),
    builder: (context, snapshot) {
      int wishlistItemCount = 0;
      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final items = data?['items'] as List<dynamic>?;
        wishlistItemCount = items?.length ?? 0;
      }

      Widget badgeIcon(IconData iconData, Color color) {
        return badges.Badge(
          badgeContent: Text(
            wishlistItemCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.deepPurple,
            padding: EdgeInsets.all(6),
          ),
          child: Icon(iconData, color: color),
        );
      }

      return NavigationDestination(
        icon: badgeIcon(Icons.favorite_border, Colors.grey[400]!),
        selectedIcon: badgeIcon(Icons.favorite, Colors.white),
        label: S.of(context).wishlist,
      );
    },
  ),
  NavigationDestination(
    icon: Icon(Icons.account_circle_outlined, color: Colors.grey[400]),
    selectedIcon: const Icon(Icons.account_circle, color: Colors.white),
    label: S.of(context).account,
  ),
];

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Stack(
          children: [
            pages[screenIndex],
            Positioned(
              top: 10,
              right: 16,
              child: 
             StreamBuilder<DocumentSnapshot>(
  stream: user != null
      ? FirebaseFirestore.instance
          .collection('Carts')
          .doc(user.uid)
          .snapshots()
      : Stream.empty(),
  builder: (context, snapshot) {
    int cartItemCount = 0;

    if (snapshot.hasData && snapshot.data!.exists) {
      final data = snapshot.data!.data() as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?; 
      cartItemCount = items?.length ?? 0;
    }


    return 
  Stack(
  alignment: Alignment.topRight,
  children: [
    IconButton(
      icon: const Icon(
        Icons.shopping_cart_rounded,
        color: Colors.white,
        size: 30,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      },
    ),
    if (cartItemCount > 0)
      Positioned(
        right: isArabic(context) ? null : 8,
        left: isArabic(context) ? 8 : null,
        top: 8,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            cartItemCount > 99 ? '99+' : '$cartItemCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
  ],
);

 
  },
),

          
          
            ),
          ],
        ),
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
          overlayColor: WidgetStateProperty.all(Colors.grey[800]),
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
bool isArabic(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'ar';
}

