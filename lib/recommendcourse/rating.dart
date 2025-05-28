import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';
import 'package:udemyflutter/customcard/coursesCard.dart';
import 'package:udemyflutter/generated/l10n.dart';

class TopRatedCourses extends StatelessWidget {
  const TopRatedCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
       S.of(context).TopRatedCourses,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 350,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Courses').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No courses available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Reviews').snapshots(),
                builder: (context, reviewsSnapshot) {
                  if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (reviewsSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${reviewsSnapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                
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

                  
                  final courses = snapshot.data!.docs.where((doc) {
                    final courseId = doc.id;
                    final avgRating = averageRatings[courseId] ?? 0.0;
                    return avgRating > 4.5;
                  }).toList();

                  if (courses.isEmpty) {
                    return const Center(
                      child: Text(
                        'No top rated courses available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final courseDoc = courses[index];
                      final course = courseDoc.data() as Map<String, dynamic>;
                      final courseId = courseDoc.id;
                      final instructorId = course['instructor_id'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(instructorId)
                            .get(),
                        builder: (context, instructorSnapshot) {
                          if (!instructorSnapshot.hasData || !instructorSnapshot.data!.exists) {
                            return const SizedBox();
                          }

                          final instructor = instructorSnapshot.data!;
                          final instructorName =
                              '${instructor['first_name']} ${instructor['last_name']}';

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
      ],
    );
  }
}