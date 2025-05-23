import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> enrollCourse({
    required String userId,
    required Map<String, dynamic> course,
  }) async {
    try {
      final enrollmentRef = _firestore.collection('Enrollments').doc(userId);
      final enrollmentSnap = await enrollmentRef.get();
      List<Map<String, dynamic>> existingCourses = [];

      if (enrollmentSnap.exists) {
        final data = enrollmentSnap.data()!;
        existingCourses = List<Map<String, dynamic>>.from(
          data['courses'] ?? [],
        );

        // Check if course already exists
        if (existingCourses.any(
          (existing) => existing['course_id'] == course['course_id'],
        )) {
          print("Course already enrolled");
          return false;
        }
      }

      // Add new course
      existingCourses.add({
        'course_id': course['course_id'],
        'title': course['title'],
        'instructor_name': course['innstructor_name'],
        'thumbnail': course['thumbnail'],
        'enrolled_at': FieldValue.serverTimestamp(),
        'progress': 0,
        'completed_lessons': [],
        'last_accessed': FieldValue.serverTimestamp(),
      });

      // Update document
      await enrollmentRef.set({
        'user_id': userId,
        'courses': existingCourses,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error enrolling course: $e');
      return false;
    }
  }

  Future<bool> updateEnrollments(
    List<Map<String, dynamic>> cartItems, {
    String? userId,
  }) async {
    try {
      // Use provided userId or fallback to current user
      final String targetUserId = userId ?? _auth.currentUser?.uid ?? '';
      if (targetUserId.isEmpty) {
        print("No valid user ID provided");
        return false;
      }

      final enrollmentRef = _firestore
          .collection('Enrollments')
          .doc(targetUserId);
      final enrollmentSnap = await enrollmentRef.get();
      List<Map<String, dynamic>> existingCourses = [];

      if (enrollmentSnap.exists) {
        final data = enrollmentSnap.data()!;
        existingCourses = List<Map<String, dynamic>>.from(
          data['courses'] ?? [],
        );
        print("existingCourses in enroll: $existingCourses");
      }

      // Remove duplicates by ID
      final newCourses =
          cartItems
              .where(
                (item) =>
                    !existingCourses.any(
                      (existing) => existing['course_id'] == item['course_id'],
                    ),
              )
              .toList();

      // Add additional information for new courses
      final formattedNewCourses =
          newCourses
              .map(
                (course) => {
                  'course_id': course['course_id'],
                  'title': course['title'],
                  'instructor_name': course['innstructor_name'],
                  'thumbnail': course['thumbnail'],
                  'enrolled_at': FieldValue.serverTimestamp(),
                  'progress': 0,
                  'completed_lessons': [],
                  'last_accessed': FieldValue.serverTimestamp(),
                },
              )
              .toList();

      final updatedCourses = [...existingCourses, ...formattedNewCourses];

      // Create or update the document
      await enrollmentRef.set({
        'user_id': targetUserId,
        'courses': updatedCourses,
        'timestamp': FieldValue.serverTimestamp(),
        'created_at':
            enrollmentSnap.exists ? null : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Successfully updated enrollments for user: $targetUserId");
      return true;
    } catch (e) {
      print('Error updating enrollments: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserEnrollments(String userId) async {
    try {
      final enrollmentRef = _firestore.collection('Enrollments').doc(userId);
      final enrollmentSnap = await enrollmentRef.get();

      if (!enrollmentSnap.exists) {
        return [];
      }

      final data = enrollmentSnap.data()!;
      return List<Map<String, dynamic>>.from(data['courses'] ?? []);
    } catch (e) {
      print('Error getting user enrollments: $e');
      return [];
    }
  }

  Future<bool> updateCourseProgress({
    required String userId,
    required String courseId,
    required int progress,
    required List<String> completedLessons,
  }) async {
    try {
      final enrollmentRef = _firestore.collection('Enrollments').doc(userId);
      final enrollmentSnap = await enrollmentRef.get();

      if (!enrollmentSnap.exists) {
        return false;
      }

      final data = enrollmentSnap.data()!;
      List<Map<String, dynamic>> courses = List<Map<String, dynamic>>.from(
        data['courses'] ?? [],
      );

      // Find course and update progress
      final courseIndex = courses.indexWhere(
        (course) => course['course_id'] == courseId,
      );
      if (courseIndex == -1) {
        return false;
      }

      courses[courseIndex]['progress'] = progress;
      courses[courseIndex]['completed_lessons'] = completedLessons;
      courses[courseIndex]['last_accessed'] = FieldValue.serverTimestamp();

      await enrollmentRef.update({'courses': courses});

      return true;
    } catch (e) {
      print('Error updating course progress: $e');
      return false;
    }
  }
}
