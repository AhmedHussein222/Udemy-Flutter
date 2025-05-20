import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Custombutton/custombuttton.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailsScreen({
    super.key,
    required this.courseData,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<DocumentSnapshot> instructorFuture;

  @override
  void initState() {
    super.initState();
    String instructorId = widget.courseData['instructor_id'];
    instructorFuture = FirebaseFirestore.instance.collection('Users').doc(instructorId).get();
  }

  // Widget to display star rating
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
              child: Text("Instructor not found", style: TextStyle(color: Colors.white)),
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
                      widget.courseData['thumbnail'] ?? 'https://i.pinimg.com/736x/42/3b/97/423b97b41c8b420d28e84f9b07a530ec.jpg',
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.courseData['title'] ?? 'No Title',
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.courseData['description'] ?? 'No Description',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStarRating(widget.courseData['rating']['rate']?.toDouble() ?? 0.0),
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
                      widget.courseData['language'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                    if (widget.courseData['discount'] != null && widget.courseData['discount'] > 0)
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
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Add to Wishlist", style: TextStyle(color: Colors.white)),
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
                        child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// What you'll learn
                const Text(
                  "What you'll learn",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...whatWillLearn.map((item) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(color: Colors.white70)),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),

                /// Requirements
                const Text(
                  "Requirements",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...requirements.map((item) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(color: Colors.white70)),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 20),

                /// Instructor
                const Text(
                  "Instructor",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(instructor['profile_picture'] ?? 'https://i.pinimg.com/736x/1f/79/73/1f7973fe4680410e3d683040b6da133f.jpg'),
                      backgroundColor: Colors.grey[800],
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
                            instructor['bio'] ?? 'No bio available',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

               
                const Text(
                  "Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Reviews')
                      .where('course_id', isEqualTo: widget.courseData['id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Error loading reviews',
                        style: TextStyle(color: Colors.white70),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        'No reviews available',
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    final reviews = snapshot.data!.docs;

                    return Column(
                      children: reviews.map((reviewDoc) {
                        final review = reviewDoc.data() as Map<String, dynamic>;
                        final userId = review['user_id'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                              return const SizedBox();
                            }

                            final user = userSnapshot.data!.data() as Map<String, dynamic>;

                            return Card(
                              color: Colors.grey[900],
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            user['profile_picture'] ?? 'https://i.pinimg.com/736x/1f/79/73/1f7973fe4680410e3d683040b6da133f.jpg',
                                          ),
                                          backgroundColor: Colors.grey[800],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "${user['first_name']} ${user['last_name']}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildStarRating(review['rating']?.toDouble() ?? 0.0),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${review['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review['comment'] ?? 'No comment',
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}