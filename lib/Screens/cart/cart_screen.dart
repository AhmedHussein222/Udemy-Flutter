import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/home/homePage.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  Future<void> _showCheckoutDialog(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Checkout'),
            content: const Text(
              'Are you sure you want to complete the payment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      for (var doc in docs) {
        await doc.reference.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text("Cart", style: TextStyle(color: Colors.white))
        ,backgroundColor: Colors.black,),
        body: const Center(child: Text("Please login first")),
      );
    }

    final cartItemsRef = FirebaseFirestore.instance
        .collection('Carts')
        .doc(user.uid)
        .collection('items');

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/checkout',
                arguments: {'userId': user.uid, 'cartItemsRef': cartItemsRef},
              );
            },
          ),
        ],
  
      backgroundColor: Colors.black,
     
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartItemsRef.snapshots(),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Your Cart is empty!",
                    style: TextStyle(
                      fontSize: 20, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Go Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final cartDocs = cartSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Reviews').snapshots(),
            builder: (context, reviewsSnapshot) {
              if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (reviewsSnapshot.hasError) {
                return Center(child: Text('Error: ${reviewsSnapshot.error}', style: const TextStyle(color: Colors.white)));
              }

                // Calculate ratings from reviewUsersSnapshot
              final ratingsMap = <String, List<double>>{};
              for (var doc in reviewsSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final courseId = data['course_id']?.toString();
                final rating = data['rating']?.toDouble() ?? 0.0;
                if (courseId != null) {
                  ratingsMap.putIfAbsent(courseId, () => []).add(rating);
                }
              }

              final averageRatings = <String, double>{};
              final reviewCounts = <String, int>{};
              ratingsMap.forEach((courseId, ratings) {
                final avg = ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;
                averageRatings[courseId] = avg;
                reviewCounts[courseId] = ratings.length;
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartDocs.length,
                itemBuilder: (context, index) {
                  final courseDoc = cartDocs[index];
                  final cartCourse = courseDoc.data() as Map<String, dynamic>;
                  final courseId = cartCourse['course_id']?.toString() ?? courseDoc.id;

                  // جلب بيانات الكورس من collection الـ Courses
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('Courses').doc(courseId).get(),
                    builder: (context, courseSnapshot) {
                      if (courseSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (courseSnapshot.hasError || !courseSnapshot.hasData || !courseSnapshot.data!.exists) {
                        return const Center(child: Text('Course not found', style: TextStyle(color: Colors.white)));
                      }

                      final course = courseSnapshot.data!.data() as Map<String, dynamic>;

                      // جلب بيانات الـ Reviews الخاصة بالكورس
                      final courseReviews = reviewsSnapshot.data!.docs
                          .where((doc) => doc['course_id']?.toString() == courseId)
                          .map((doc) => doc.data() as Map<String, dynamic>)
                          .toList();

                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: Future.wait(
                          courseReviews.map((review) async {
                            final userId = review['user_id']?.toString();
                            if (userId == null) {
                              return {
                                'userName': 'Anonymous',
                                'review': review,
                              };
                            }
                            final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
                            final userData = userDoc.data() as Map<String, dynamic>?;
                            return {
                              'userName': userData != null
                                  ? '${userData['first_name'] ?? 'Unknown'} ${userData['last_name'] ?? ''}'
                                  : 'Anonymous',
                              'review': review,
                            };
                          }),
                        ),
                        builder: (context, reviewUsersSnapshot) {
                          if (reviewUsersSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (reviewUsersSnapshot.hasError) {
                            return Center(child: Text('Error: ${reviewUsersSnapshot.error}', style: const TextStyle(color: Colors.white)));
                          }

                          final reviewUsers = reviewUsersSnapshot.data ?? [];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailsScreen(
                                    courseData: {
                                      ...course, // بيانات الكورس الكاملة من Courses
                                      'id': courseId,
                                      'rating': {
                                        'rate': averageRatings[courseId] ?? 0.0,
                                        'count': reviewCounts[courseId] ?? 0,
                                      },
                                      'reviews': reviewUsers,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.grey[900],
                              margin: const EdgeInsets.only(bottom: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 140,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          cartCourse['thumbnail']?.toString() ?? '',
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 120,
                                            width: 120,
                                            color: Colors.grey,
                                            child: const Icon(Icons.broken_image, size: 50, color: Colors.white54),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartCourse['title']?.toString() ?? 'No Title',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            if (cartCourse['description']?.toString() != null)
                                              Text(
                                                cartCourse['description'].toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 6),
                                            Column(
                                              children: [
                                                Text(
                                                  cartCourse['price'] == 0
                                                      ? 'Free'
                                                      : '\$${cartCourse['price']?.toString() ?? '0'}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                if (cartCourse['discount'] != null && cartCourse['discount'] > 0)
                                                  Text(
                                                    '\$${cartCourse['discount'].toString()}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white54,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  '★ ${(averageRatings[courseId] ?? 0.0).toStringAsFixed(1)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(255, 233, 164, 6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              cartDocs[index].reference.delete();
                                            },
                                            child: const Text(
                                              'Remove',
                                              style: TextStyle(
                                                color: Colors.purple,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () => _showCheckoutDialog(context, cartDocs),
                                            child: const Text(
                                              'Checkout',
                                              style: TextStyle(
                                                color: Colors.purple,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}