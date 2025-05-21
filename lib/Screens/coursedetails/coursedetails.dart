import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udemyflutter/Custombutton/custombuttton.dart';
import 'package:udemyflutter/Screens/cart/cart_screen.dart';
import 'package:udemyflutter/services/wishlist_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailsScreen({super.key, required this.courseData});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<DocumentSnapshot> instructorFuture;
  final WishlistService _wishlistService = WishlistService();
  bool _isInWishlist = false;
  bool _checkingWishlist = true;

  @override
  void initState() {
    super.initState();
    String instructorId = widget.courseData['instructor_id'];
    instructorFuture =
        FirebaseFirestore.instance.collection('Users').doc(instructorId).get();

    Future.microtask(() => _checkWishlistStatus());
  }

Future<void> _checkWishlistStatus() async {
  final courseId = widget.courseData['id'] ?? widget.courseData['course_id'];
  if (courseId == null || courseId.isEmpty) {
    _showSnackBar('Error: Course ID is not available');
    setState(() {
      _isInWishlist = false;
      _checkingWishlist = false;
    });
    return;
  }

  try {
    final isInWishlist = await _wishlistService.isInWishlist(courseId);
    if (mounted) {
      setState(() {
        _isInWishlist = isInWishlist;
        _checkingWishlist = false;
      });
    }
  } catch (e) {
    _showSnackBar('Error checking wishlist: $e');
    if (mounted) {
      setState(() {
        _checkingWishlist = false;
      });
    }
  }
}

Future<void> _toggleWishlist() async {
  final courseId = widget.courseData['id'] ?? widget.courseData['course_id'];
  if (courseId == null || courseId.isEmpty) {
    _showSnackBar('Error: Course ID is not available');
    return;
  }

  try {
    final success = await _wishlistService.toggleWishlist(courseId);
    if (mounted) {
      setState(() {
        _isInWishlist = !_isInWishlist;
      });
    }
    _showSnackBar(
      success
          ? (_isInWishlist ? 'Course added to wishlist' : 'Course removed from wishlist')
          : 'Failed to update wishlist',
      success ? Colors.purple : Colors.red,
    );
  } catch (e) {
    _showSnackBar('Error toggling wishlist: $e');
  }
}

void _showSnackBar(String message, [Color backgroundColor = Colors.red]) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

  Future<void> _addToCart() async {
    try {
      final course = widget.courseData;
      final courseId = course['id']?.toString() ?? course['course_id']?.toString();

      if (courseId == null || courseId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Course ID is not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login first')),
            // backgroundColor: Colors.red,
          );
        }
        return;
      }
     final userId = user.uid;

                            final cartItemRef = FirebaseFirestore.instance
                                .collection('Carts')
                                .doc(userId)
                                .collection('items')
                                .doc(courseId);

                            final existingDoc = await cartItemRef.get();

                            if (!existingDoc.exists) {
                              await cartItemRef.set({
                                'course_id': courseId,
                                'title': course['title'],
                                'price': course['price'],
                                'thumbnail': course['thumbnail'],
                                'added_at': FieldValue.serverTimestamp(),
                                
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );

                              // الانتقال لصفحة الـ Cart
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CartScreen()),
                              );

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Course already in cart')),
                              );
                            }
                          } catch (e) {
                            print('Error adding to cart: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Something went wrong')),
                            );
                          }
                        }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> requirements = widget.courseData['requirements'] ?? [];
    List<dynamic> whatWillLearn = widget.courseData['what_will_learn'] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot>(
        future: instructorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Instructor not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final instructor = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      widget.courseData['thumbnail'] ??
                          'https://i.pinimg.com/736x/42/3b/97/423b97b41c8b420d28e84f9b07a530ec.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'https://i.pinimg.com/736x/42/3b/97/423b97b41c8b420d28e84f9b07a530ec.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      left: 1,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.courseData['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.courseData['description'] ?? 'No Description',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStarRating(
                        widget.courseData['rating']['rate']?.toDouble() ?? 0.0),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.courseData['rating']['rate']?.toStringAsFixed(1) ?? '0.0'} (${widget.courseData['rating']['count'] ?? 0} reviews)',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      ' ${widget.courseData['language']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      widget.courseData['price'] == 0
                          ? 'Free'
                          : '\$${widget.courseData['price']?.toString() ?? '0'}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    if (widget.courseData['discount'] != null &&
                        widget.courseData['discount'] > 0)
                      Text(
                        '\$${widget.courseData['discount'].toString()}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Buy Now",
                  color: Colors.purple,
                  textColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _checkingWishlist ? null : _toggleWishlist,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _checkingWishlist
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isInWishlist ? Colors.red : Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isInWishlist
                                        ? "Remove from Wishlist"
                                        : "Add to Wishlist",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: _addToCart,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "What you'll learn",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...whatWillLearn.map(
                  (item) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Requirements",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...requirements.map(
                  (item) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Instructor",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        instructor['profile_picture'] ??
                            'https://i.pinimg.com/736x/1f/79/73/1f7973fe4680410e3d683040b6da133f.jpg',
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        // ممكن تحط صورة افتراضية هنا لو حابب
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instructor['name'] ?? 'Instructor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            instructor['bio'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

