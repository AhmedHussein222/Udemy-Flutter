import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> updateEnrollments(List<Map<String, dynamic>> cartItems) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final enrollmentRef = _firestore.collection('Enrollments').doc(user.uid);
      final enrollmentSnap = await enrollmentRef.get();

      List<Map<String, dynamic>> existingCourses = [];

      if (enrollmentSnap.exists) {
        final data = enrollmentSnap.data()!;
        existingCourses = List<Map<String, dynamic>>.from(
          data['courses'] ?? [],
        );
      }

      // حذف التكرارات عن طريق ID
      final newCourses =
          cartItems
              .where(
                (item) =>
                    !existingCourses.any(
                      (existing) => existing['id'] == item['id'],
                    ),
              )
              .toList();

      final updatedCourses = [...existingCourses, ...newCourses];

      await enrollmentRef.set({
        'user_id': user.uid,
        'courses': updatedCourses,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('خطأ في تحديث التسجيلات: $e');
      return false;
    }
  }
}
