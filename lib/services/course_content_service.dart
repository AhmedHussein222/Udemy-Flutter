import 'package:cloud_firestore/cloud_firestore.dart';

class CourseContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب بيانات الكورس
  Future<DocumentSnapshot> getCourseById(String courseId) {
    return _firestore.collection('courses').doc(courseId).get();
  }

  // جلب كل الدروس الخاصة بكورس معيّن
  Future<List<QueryDocumentSnapshot>> getLessonsByCourseId(
    String courseId,
  ) async {
    final querySnapshot =
        await _firestore
            .collection('lessons')
            .where('course_id', isEqualTo: courseId)
            .orderBy('order', descending: false) // لو عندك ترتيب للدروس
            .get();
    return querySnapshot.docs;
  }

  // جلب الريفيوهات الخاصة بكورس معيّن
  Future<List<QueryDocumentSnapshot>> getCourseReviews(String courseId) async {
    final querySnapshot =
        await _firestore
            .collection('Reviews')
            .where('course_id', isEqualTo: courseId)
            .orderBy('timestamp', descending: true)
            .get();
    return querySnapshot.docs;
  }
}
