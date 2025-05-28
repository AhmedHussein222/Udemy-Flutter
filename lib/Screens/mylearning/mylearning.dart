import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/Screens/subcategories/SubCategories.dart';
import 'package:udemyflutter/generated/l10n.dart';

import '../../services/enrollment_service.dart';
import '../course_content/course_content_screen.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  String selectedTab = "All";

  // بدّلنا النوع علشان يحتوي على name و id
  List<Map<String, String>> categories = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EnrollmentService _enrollmentService = EnrollmentService();
  List<Map<String, dynamic>> _enrolledCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    fetchCategoriesFromFirebase();
    _loadEnrolledCourses();
  }

  Future<void> fetchCategoriesFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Categories').get();

      List<Map<String, String>> fetchedCategories =
          snapshot.docs.map((doc) {
            return {'id': doc.id, 'name': doc['name'].toString()};
          }).toList();

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _loadEnrolledCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final courses = await _enrollmentService.getUserEnrollments(user.uid);
        setState(() {
          _enrolledCourses = courses;
        });
      }
    } catch (e) {
      print('Error loading enrolled courses: $e');
    } finally {
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
             Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                 S.of(context).MyCourses,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
           children: [
  buildTab(S.of(context).all),
  buildTab(S.of(context).downloaded),
  buildTab(S.of(context).archived),
  buildTab(S.of(context).favourited),
],

              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  selectedTab == "All"
                      ? _isLoadingCourses
                          ? const Center(child: CircularProgressIndicator())
                          : _enrolledCourses.isEmpty
                          ? SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Center(
                                  child: Image.asset(
                                    'assets/Images/value-prop-teach-2x-v3.webp',
                                    height: 150,
                                  ),
                                ),
                                const SizedBox(height: 20),
                               Text(
  S.of(context)!.whatToLearn,
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 10),
Text(
  S.of(context)!.yourCourses,
  style: TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          categories.map((category) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => SubCategoriesScreen(
                                                            categoryName:
                                                                category['name'] ??
                                                                '',
                                                            categoryId:
                                                                category['id'] ??
                                                                '',
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  category['name'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: _enrolledCourses.length,
                            itemBuilder: (context, index) {
                              final course = _enrolledCourses[index];
                              return _buildCourseItem(course);
                            },
                          )
                      : buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent() {
    if (selectedTab == "Downloaded") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          SizedBox(height: 60),
          Icon(
            Icons.download_for_offline_outlined,
            color: Colors.white,
            size: 60,
          ),
          SizedBox(height: 20),
        Text(
  S.of(context).nothingDownloaded,
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),
SizedBox(height: 10),
Padding(
  padding: EdgeInsets.symmetric(horizontal: 24),
  child: Text(
    S.of(context).downloadMessage,
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.white70, fontSize: 14),
  ),
),

        
        ],
      );
    } else {
      return  Center(
        child: Text(
       S.of(context).NoMatchingcourses,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Widget buildTab(String label) {
    bool isSelected = selectedTab == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> course) {
    final progress = course['progress'] ?? 0;
    final courseId = course['id'] ?? course['course_id'] ?? '';
    print('Course data: $course');

    if (courseId.isEmpty) {
      print('Warning: Course ID is empty for course: $course');
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseContentScreen(courseId: courseId),
          ),
        );
      },
      child: Card(
        color: Colors.black,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[800] ?? Colors.black,
                  image: DecorationImage(
                    image: NetworkImage(course['thumbnail'] ?? ''),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print('Error loading image: $exception');
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'] ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (progress >= 0 && progress < 100)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete $progress%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress / 100.0,
                            backgroundColor: Colors.grey[700],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.purple,
                            ),
                          ),
                        ],
                      )
                    else if (progress == 100)
                       Text(
                    S.of(context).Completed,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
