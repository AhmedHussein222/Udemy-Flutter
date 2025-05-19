import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';
import 'package:udemyflutter/customcard/coursesCard.dart';
import 'package:udemyflutter/customcategory/custombutton.dart';

class SubCategoriesScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  String? selectedSubCategoryId;

  // Widget to display star rating
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('SubCategories')
                .where('category_id', isEqualTo: widget.categoryId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading subcategories', style: TextStyle(color: Colors.white)),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final subcategories = snapshot.data!.docs;

              if (subcategories.isEmpty) {
                return const Center(
                  child: Text('No subcategories found', style: TextStyle(color: Colors.white)),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subcategories.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final subId = doc.id;
                    final subName = data['name'] ?? 'Unnamed';

                    return CustomButtonCategory(
                      text: subName,
                      onPressed: () {
                        setState(() {
                          selectedSubCategoryId = subId;
                        });
                      },
                      color: selectedSubCategoryId == subId ? Colors.white : Colors.black,
                      textColor: selectedSubCategoryId == subId ? Colors.black : Colors.white,
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (selectedSubCategoryId != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Courses Section
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Courses')
                          .where('subcategory_id', isEqualTo: selectedSubCategoryId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error loading courses', style: TextStyle(color: Colors.white)),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final courses = snapshot.data!.docs;

                        if (courses.isEmpty) {
                          return const Center(
                            child: Text('No courses found', style: TextStyle(color: Colors.white)),
                          );
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('Reviews').snapshots(),
                          builder: (context, reviewsSnapshot) {
                            if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (reviewsSnapshot.hasError) {
                              return const Center(
                                child: Text('Error loading reviews', style: TextStyle(color: Colors.white)),
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
                              final avg = ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;
                              averageRatings[courseId] = avg;
                              reviewCounts[courseId] = ratings.length;
                            });

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: courses.map((doc) {
                                  final course = doc.data() as Map<String, dynamic>;
                                  final courseId = doc.id;
                                  final instructorId = course['instructor_id'];

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('Users').doc(instructorId).get(),
                                    builder: (context, instructorSnapshot) {
                                      if (instructorSnapshot.hasError) {
                                        return const SizedBox(
                                          width: 160,
                                          height: 240,
                                          child: Center(
                                            child: Text('Error loading instructor', style: TextStyle(color: Colors.white)),
                                          ),
                                        );
                                      }
                                      if (!instructorSnapshot.hasData) {
                                        return const SizedBox(
                                          width: 160,
                                          height: 240,
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }

                                      final docSnapshot = instructorSnapshot.data!;

                                      if (!docSnapshot.exists) {
                                        return const SizedBox(
                                          width: 160,
                                          height: 240,
                                          child: Center(
                                            child: Text(
                                              'Instructor not found',
                                              style: TextStyle(color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }

                                      final data = docSnapshot.data() as Map<String, dynamic>?;

                                      if (data == null) {
                                        return const SizedBox(
                                          width: 160,
                                          height: 240,
                                          child: Center(
                                            child: Text(
                                              'Invalid instructor data',
                                              style: TextStyle(color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }

                                      final instructorName = "${data['first_name'] ?? 'No'} ${data['last_name'] ?? 'Name'}";

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CourseDetailsScreen(
                                                courseData: {
                                                  ...course,
                                                  'id': courseId,
                                                  'rating': {
                                                    'rate': averageRatings[courseId] ?? 0.0,
                                                    'count': reviewCounts[courseId] ?? 0,
                                                  },
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: 160,
                                          child: HoverCourseCard(
                                            imageUrl: course['thumbnail'] ?? '',
                                            title: course['title'] ?? 'Untitled',
                                            instructor: instructorName,
                                            price: double.tryParse(course['price']?.toString() ?? '0') ?? 0.0,
                                            discount: double.tryParse(course['discount']?.toString() ?? '0') ?? 0.0,
                                            rating: averageRatings[courseId] ?? 0.0,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Reviews Section
                    if (selectedSubCategoryId != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Reviews",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Courses')
                                  .where('subcategory_id', isEqualTo: selectedSubCategoryId)
                                  .snapshots(),
                              builder: (context, coursesSnapshot) {
                                if (coursesSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (coursesSnapshot.hasError) {
                                  return const Center(
                                    child: Text('Error loading courses', style: TextStyle(color: Colors.white)),
                                  );
                                }
                                if (!coursesSnapshot.hasData || coursesSnapshot.data!.docs.isEmpty) {
                                  return const Center(
                                    child: Text('No courses found for reviews', style: TextStyle(color: Colors.white)),
                                  );
                                }

                                final courseIds = coursesSnapshot.data!.docs.map((doc) => doc.id).toList();

                                return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Reviews')
                                      .where('course_id', whereIn: courseIds)
                                      .orderBy('created_at', descending: true)
                                      .limit(10)
                                      .snapshots(),
                                  builder: (context, reviewsSnapshot) {
                                    if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (reviewsSnapshot.hasError) {
                                      return const Center(
                                        child: Text('Error loading reviews', style: TextStyle(color: Colors.white)),
                                      );
                                    }
                                    if (!reviewsSnapshot.hasData || reviewsSnapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text('No reviews found', style: TextStyle(color: Colors.white)),
                                      );
                                    }

                                    final reviews = reviewsSnapshot.data!.docs;

                                    return SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: reviews.length,
                                        itemBuilder: (context, index) {
                                          final review = reviews[index].data() as Map<String, dynamic>;
                                          final userId = review['user_id'];

                                          return FutureBuilder<DocumentSnapshot>(
                                            future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator());
                                              }
                                              if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                                                return const SizedBox();
                                              }

                                              final user = userSnapshot.data!.data() as Map<String, dynamic>;
                                              final userName = '${user['first_name'] ?? 'Unknown'} ${user['last_name'] ?? ''}';

                                              return Card(
                                                color: Colors.grey[900],
                                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Container(
                                                  width: 250,
                                                  padding: const EdgeInsets.all(12),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 20,
                                                            backgroundColor: Colors.grey[800],
                                                            child: ClipOval(
                                                              child: user['profile_picture'] != null &&
                                                                      user['profile_picture'].isNotEmpty
                                                                  ? Image.network(
                                                                      user['profile_picture'],
                                                                      width: 40,
                                                                      height: 40,
                                                                      fit: BoxFit.cover,
                                                                      errorBuilder: (context, error, stackTrace) =>
                                                                          Image.asset(
                                                                        'assets/images/default_user.jpg',
                                                                        width: 40,
                                                                        height: 40,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    )
                                                                  : Image.asset(
                                                                      'assets/images/default_user.jpg',
                                                                      width: 40,
                                                                      height: 40,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              userName,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          _buildStarRating(review['rating']?.toDouble() ?? 0.0),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '${review['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        review['comment'] ?? 'No comment',
                                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    
                  ],
                ),
              ),
            ),
          if (selectedSubCategoryId == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Please select a subcategory',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}