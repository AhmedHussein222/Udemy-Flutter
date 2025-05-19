import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';
import 'package:udemyflutter/Screens/subcategories/SubCategories.dart';
import 'package:udemyflutter/customcard/coursesCard.dart';
import 'package:udemyflutter/customcategory/custombutton.dart';
import 'package:udemyflutter/recommendcourse/rating.dart';

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

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
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('User not found', style: TextStyle(color: Colors.white));
                } else {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final userName = '${userData['first_name']} ${userData['last_name']}';
                  final bio = userData['bio'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_2_sharp, size: 30, color: Colors.white),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Welcome, $userName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                bio,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            Image.asset(
              'assets/Images/billboard-mobile-v3.webp',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            const TopRatedCourses(),
            const SizedBox(height: 20),
            const Text(
              "Features courses in Web Development",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Courses')
                  .where('category_id', isEqualTo: '1')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Web Development courses found', style: TextStyle(color: Colors.white)));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Reviews').snapshots(),
                  builder: (context, reviewsSnapshot) {
                    if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (reviewsSnapshot.hasError) {
                      return Center(child: Text('Error: ${reviewsSnapshot.error}', style: TextStyle(color: Colors.white)));
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

                    final courses = snapshot.data!.docs;

                    return SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final courseDoc = courses[index];
                          final course = courseDoc.data() as Map<String, dynamic>;
                          final courseId = courseDoc.id;
                          final instructorId = course['instructor_id'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('Users').doc(instructorId).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (userSnapshot.hasError) {
                                return Center(child: Text('Error: ${userSnapshot.error}', style: TextStyle(color: Colors.white)));
                              } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                return const Center(child: Text('Instructor not found', style: TextStyle(color: Colors.white)));
                              }

                              final instructorName = '${userSnapshot.data!['first_name']} ${userSnapshot.data!['last_name']}';

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
                                child: HoverCourseCard(
                                  imageUrl: course['thumbnail'] ?? '',
                                  title: course['title'] ?? 'No Title',
                                  instructor: instructorName,
                                  price: double.tryParse(course['price'].toString()) ?? 0.0,
                                  discount: double.tryParse(course['discount'].toString()) ?? 0.0,
                                  rating: averageRatings[courseId] ?? 0.0,
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
            const SizedBox(height: 20),
            const Text(
              "New Courses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 350,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Courses')
                    .orderBy('created_at', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No new courses found', style: TextStyle(color: Colors.white)));
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Reviews').snapshots(),
                    builder: (context, reviewsSnapshot) {
                      if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (reviewsSnapshot.hasError) {
                        return Center(child: Text('Error: ${reviewsSnapshot.error}', style: TextStyle(color: Colors.white)));
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

                      final courses = snapshot.data!.docs;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final courseDoc = courses[index];
                          final course = courseDoc.data() as Map<String, dynamic>;
                          final courseId = courseDoc.id;
                          final instructorId = course['instructor_id'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('Users').doc(instructorId).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (userSnapshot.hasError) {
                                return Center(child: Text('Error: ${userSnapshot.error}', style: TextStyle(color: Colors.white)));
                              } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                return const Center(child: Text('Instructor not found', style: TextStyle(color: Colors.white)));
                              }

                              final instructorName = '${userSnapshot.data!['first_name']} ${userSnapshot.data!['last_name']}';

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
                                child: HoverCourseCard(
                                  imageUrl: course['thumbnail'] ?? '',
                                  title: course['title'] ?? 'No Title',
                                  instructor: instructorName,
                                  price: double.tryParse(course['price'].toString()) ?? 0.0,
                                  discount: double.tryParse(course['discount'].toString()) ?? 0.0,
                                  rating: averageRatings[courseId] ?? 0.0,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recent Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Reviews')
                    .orderBy('created_at', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No reviews found', style: TextStyle(color: Colors.white)));
                  }

                  final reviews = snapshot.data!.docs;

                  return ListView.builder(
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
                          } else if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
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
                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
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
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No categories found', style: TextStyle(color: Colors.white)),
                  );
                }

                final categories = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: categories.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final catName = data['name'];

                      return CustomButtonCategory(
                        text: catName,
                        textColor: Colors.white,
                        color: Colors.black,
                        onPressed: () {
                          final categoryId = doc.id;
                          final categoryName = data['name'];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubCategoriesScreen(
                                categoryId: categoryId,
                                categoryName: categoryName,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}