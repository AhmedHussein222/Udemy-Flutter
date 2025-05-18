import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';
import 'package:udemyflutter/customcard/coursesCard.dart'; 

class TopRatedCourses extends StatelessWidget {
  const TopRatedCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Rated Courses",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 350,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Courses')
                .where('rating.rate', isGreaterThan: 4.5) 
                .orderBy('rating.rate', descending: true) 
                .snapshots(),
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
                    'No top rated courses available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final courses = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index].data() as Map<String, dynamic>;
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
                       
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => CourseDetailsScreen(courseData: course),
                          ));
                        },
                        child: HoverCourseCard(
                          imageUrl: course['thumbnail'],
                          title: course['title'],
                          instructor: instructorName,
                          price: double.tryParse(course['price'].toString()) ?? 0.0,
                          discount: double.tryParse(course['discount'].toString()) ?? 0.0,
                          rating: course['rating']['rate']?.toDouble() ?? 0.0,
                        ),
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
