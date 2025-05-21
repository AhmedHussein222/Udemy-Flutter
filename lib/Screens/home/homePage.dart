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
        label: 'Feature',
      ),
      NavigationDestination(
        icon: Icon(Icons.search, color: Colors.grey[400]),
        selectedIcon: const Icon(Icons.search, color: Colors.white),
        label: 'Search',
      ),
      NavigationDestination(
        icon: Icon(Icons.video_library_outlined, color: Colors.grey[400]),
        selectedIcon: const Icon(Icons.video_library, color: Colors.white),
        label: 'Learning',
      ),
StreamBuilder<QuerySnapshot>(
  stream: user != null
      ? FirebaseFirestore.instance
          .collection('Wishlists')
          .doc(user.uid)
          .collection('items')
          .snapshots()
      : Stream.empty(),
  builder: (context, snapshot) {
    int wishlistItemCount = 0;

    if (snapshot.hasData) {
      wishlistItemCount = snapshot.data!.docs.length;
    }

    Widget badgeIcon(IconData iconData, Color color) {
      return badges.Badge(
        badgeContent: Text(
          wishlistItemCount.toString(),
          style: const TextStyle(color: Colors.white),
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
      label: 'Wishlist',
    );
  },
),

      NavigationDestination(
        icon: Icon(Icons.account_circle_outlined, color: Colors.grey[400]),
        selectedIcon: const Icon(Icons.account_circle, color: Colors.white),
        label: 'Account',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          pages[screenIndex],
          Positioned(
            top: 0,
            right: 1,
            child: StreamBuilder<QuerySnapshot<Object?>>(
              stream: user != null
                  ? FirebaseFirestore.instance
                      .collection('Carts')
                      .doc(user.uid)
                      .collection('items')
                      .snapshots()
                  : Stream.value(QuerySnapshotMock([])),
              builder: (context, snapshot) {
                int cartItemCount = 0;
                if (snapshot.hasData && snapshot.data != null) {
                  cartItemCount = snapshot.data!.docs.length;
                }

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(Colors.grey[800]),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                    if (cartItemCount > 0)
                      Positioned(
                        right: 8,
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
                            '$cartItemCount',
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

class QuerySnapshotMock implements QuerySnapshot<Object?> {
  final List<QueryDocumentSnapshot<Object?>> _docs;

  QuerySnapshotMock(this._docs);

  @override
  List<QueryDocumentSnapshot<Object?>> get docs => _docs;

  @override
  List<DocumentChange<Object?>> get docChanges => [];

  @override
  SnapshotMetadata get MetaData => SnapshotMetadata(
        hasPendingWrites: false,
        isFromCache: false,
      );

  @override
  int get size => _docs.length;

  @override
  bool get isEmpty => _docs.isEmpty;

  @override
  bool get isNotEmpty => _docs.isNotEmpty;

  @override
  Stream<QuerySnapshot<Object?>> snapshots({bool includeMetadataChanges = false}) {
    return Stream.value(this);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SnapshotMetadata {
  final bool hasPendingWrites;
  final bool isFromCache;

  SnapshotMetadata({
    required this.hasPendingWrites,
    required this.isFromCache,
  });
}