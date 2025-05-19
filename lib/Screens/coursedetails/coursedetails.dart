import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Custombutton/custombuttton.dart';
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

    // استخدام Future.microtask لضمان تنفيذ الدالة بعد بناء الواجهة
    Future.microtask(() => _checkWishlistStatus());
  }

  Future<void> _checkWishlistStatus() async {
    try {
      // تأكد من وجود معرف الكورس (مع fallback إلى course_id)
      final courseId =
          widget.courseData['id'] ?? widget.courseData['course_id'];

      // طباعة معرف الكورس للتصحيح
      print("Checking wishlist status for course ID: $courseId");

      if (courseId == null || courseId.isEmpty) {
        print("Course ID is null or empty, cannot check wishlist status");
        if (mounted) {
          setState(() {
            _isInWishlist = false;
            _checkingWishlist = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Course ID is not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final isInWishlist = await _wishlistService.isInWishlist(courseId);

      if (mounted) {
        setState(() {
          _isInWishlist = isInWishlist;
          _checkingWishlist = false;
        });
      }
    } catch (e) {
      print("Error checking wishlist status: $e");
      if (mounted) {
        setState(() {
          _checkingWishlist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking wishlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      // تأكد من وجود معرف الكورس (مع fallback إلى course_id)
      final courseId =
          widget.courseData['id'] ?? widget.courseData['course_id'];

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

      bool success;
      String message;

      if (_isInWishlist) {
        success = await _wishlistService.removeFromWishlist(courseId);
        message =
            success
                ? 'Course removed from wishlist'
                : 'Failed to remove course from wishlist';
      } else {
        success = await _wishlistService.addToWishlist(courseId);
        message =
            success
                ? 'Course added to wishlist'
                : 'Failed to add course to wishlist';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.purple : Colors.red,
          ),
        );
        if (success) {
          setState(() {
            _isInWishlist = !_isInWishlist;
          });
        }
      }
    } catch (e) {
      print("Error toggling wishlist: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                      widget.courseData['thumbnail'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
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
                  widget.courseData['description'],
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rating: ${widget.courseData['rating']['rate']}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                      '${widget.courseData['price']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.courseData['discount']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Buttons
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
                        child:
                            _checkingWishlist
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
                                      color:
                                          _isInWishlist
                                              ? Colors.red
                                              : Colors.white,
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
                        onPressed: () {},
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

                /// What you'll learn
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

                /// Requirements
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
                        instructor['profile_picture'],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${instructor['first_name']} ${instructor['last_name']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
