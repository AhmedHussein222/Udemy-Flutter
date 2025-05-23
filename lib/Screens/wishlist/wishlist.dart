import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Custombutton/custombuttton.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';
import 'package:udemyflutter/Screens/home/homePage.dart';
import 'package:udemyflutter/services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Stream<DocumentSnapshot> _wishlistStream; // Updated to DocumentSnapshot
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WishlistService _wishlistService = WishlistService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWishlistStream();
  }

  void _initWishlistStream() {
    _wishlistStream = _wishlistService.getWishlistStream();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _toggleWishlistItem(String courseId) async {
    try {
      final success = await _wishlistService.toggleWishlist(courseId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course removed from wishlist'),
              backgroundColor: Colors.purple,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove course from wishlist'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing course from wishlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Wishlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : StreamBuilder<DocumentSnapshot>(
                stream: _wishlistStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (_auth.currentUser == null) {
                    return _buildNotLoggedInView();
                  }

                  if (!snapshot.hasData ||
                          !snapshot.data!.exists ||
                          (snapshot.data!.data() as Map<String, dynamic>?) ==
                              null ||
                          (snapshot.data!.data()
                                  as Map<String, dynamic>)['items']
                              ?.isEmpty ??
                      true) {
                    return _buildEmptyWishlistView();
                  }

                  final wishlistItems = List<Map<String, dynamic>>.from(
                    (snapshot.data!.data() as Map<String, dynamic>)['items'] ??
                        [],
                  );

                  return _buildWishlistItems(wishlistItems);
                },
              ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.white70,
          ),
          const SizedBox(height: 20),
          const Text(
            'Sign in to view your wishlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your wishlist will be saved and accessible across all devices',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: "Sign In",
            color: Colors.purple,
            textColor: Colors.white,
            onPressed: () {
              // Navigate to login screen
              // TODO: Replace with actual login screen navigation
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlistView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 80, color: Colors.white70),
            const SizedBox(height: 20),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Courses you save to your wishlist will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Browse Courses",
              color: Colors.purple,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItems(List<Map<String, dynamic>> wishlistItems) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Reviews').snapshots(),
      builder: (context, reviewsSnapshot) {
        if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          );
        } else if (reviewsSnapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${reviewsSnapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // Calculate ratings from Reviews
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
          final avg =
              ratings.isNotEmpty
                  ? ratings.reduce((a, b) => a + b) / ratings.length
                  : 0.0;
          averageRatings[courseId] = avg;
          reviewCounts[courseId] = ratings.length;
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final wishlistCourse = wishlistItems[index];
            final courseId = wishlistCourse['id']?.toString();

            if (courseId == null) {
              return const SizedBox.shrink(); // Skip invalid items
            }

            // Fetch course data from Courses collection
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('Courses')
                      .doc(courseId)
                      .get(),
              builder: (context, courseSnapshot) {
                if (courseSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  );
                } else if (courseSnapshot.hasError ||
                    !courseSnapshot.hasData ||
                    !courseSnapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      'Course not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final course =
                    courseSnapshot.data!.data() as Map<String, dynamic>;

                // Fetch reviews for the course
                final courseReviews =
                    reviewsSnapshot.data!.docs
                        .where(
                          (doc) => doc['course_id']?.toString() == courseId,
                        )
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                    courseReviews.map((review) async {
                      final userId = review['user_id']?.toString();
                      if (userId == null) {
                        return {'userName': 'Anonymous', 'review': review};
                      }
                      final userDoc =
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userId)
                              .get();
                      final userData = userDoc.data() as Map<String, dynamic>?;
                      return {
                        'userName':
                            userData != null
                                ? '${userData['first_name'] ?? 'Unknown'} ${userData['last_name'] ?? ''}'
                                : 'Anonymous',
                        'review': review,
                      };
                    }),
                  ),
                  builder: (context, reviewUsersSnapshot) {
                    if (reviewUsersSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.purple),
                      );
                    } else if (reviewUsersSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${reviewUsersSnapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final reviewUsers = reviewUsersSnapshot.data ?? [];

                    return Dismissible(
                      key: Key(courseId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _toggleWishlistItem(courseId);
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CourseDetailsScreen(
                                    courseData: {
                                      ...course,
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
                          color: const Color(0xFF1C1C1E),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                                child: Image.network(
                                  wishlistCourse['thumbnail']?.toString() ??
                                      'https://via.placeholder.com/300x200',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white70,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wishlistCourse['title']?.toString() ??
                                            'Untitled Course',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        wishlistCourse['instructor_name']
                                                ?.toString() ??
                                            'Unknown Instructor',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${(averageRatings[courseId] ?? 0.0).toStringAsFixed(1)} (${reviewCounts[courseId] ?? 0} reviews)',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            wishlistCourse['price'] == 0
                                                ? 'Free'
                                                : '\$${(wishlistCourse['price'] ?? 0.0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white70,
                                            ),
                                            onPressed:
                                                () => _toggleWishlistItem(
                                                  courseId,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
  }
}
