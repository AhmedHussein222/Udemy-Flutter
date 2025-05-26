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
        if (existingCourses.any((existing) => existing['id'] == course['id'])) {
          print("Course already enrolled");
          return false;
        }
      }

      // Add new course
      existingCourses.add({
        'id': course['id'],
        'title': course['title'],
        'thumbnail': course['thumbnail'],
        'enrolled_at': Timestamp.now(),
        'progress': 0,
        'completed_lessons': [],
        'last_accessed': Timestamp.now(),
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
      }

      final newCourses =
          cartItems
              .where(
                (item) =>
                    !existingCourses.any(
                      (existing) => existing['id'] == item['id'],
                    ),
              )
              .toList();

      final formattedNewCourses =
          newCourses.map((course) {
            final thumbnail = course['thumbnail']?.toString() ?? '';
            if (thumbnail.isEmpty) {
              print('Warning: Empty thumbnail for course ${course['id']}');
            }

            return {
              'id': course['id'],
              'title': course['title'],
              'thumbnail':
                  thumbnail.isNotEmpty
                      ? thumbnail
                      : 'https://i.pinimg.com/736x/42/3b/97/423b97b41c8b420d28e84f9b07a530ec.jpg',
              'enrolled_at': Timestamp.now(),
              'progress': 0,
              'completed_lessons': [],
              'last_accessed': Timestamp.now(),
            };
          }).toList();

      print("\nFormatted New Courses: $formattedNewCourses");

      final updatedCourses = [...existingCourses, ...formattedNewCourses];

      await enrollmentRef.set({
        'user_id': targetUserId,
        'courses': updatedCourses,
        'timestamp': FieldValue.serverTimestamp(),
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
        (course) => course['id'] == courseId,
      );
      if (courseIndex == -1) {
        return false;
      }

      courses[courseIndex]['progress'] = progress;
      courses[courseIndex]['completed_lessons'] = completedLessons;
      courses[courseIndex]['last_accessed'] = Timestamp.now();

      await enrollmentRef.update({'courses': courses});

      return true;
    } catch (e) {
      print('Error updating course progress: $e');
      return false;
    }
  }
}
