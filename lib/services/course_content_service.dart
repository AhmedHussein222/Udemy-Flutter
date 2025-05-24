import 'package:cloud_firestore/cloud_firestore.dart';

class CourseContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب بيانات الكورس
  Future<DocumentSnapshot> getCourseById(String courseId) async {
    print('Fetching course with ID: $courseId');
    try {
      final doc = await _firestore.collection('Courses').doc(courseId).get();
      print('Course document exists: ${doc.exists}');
      if (doc.exists) {
        print('Course data: ${doc.data()}');
      } else {
        print('No course found with ID: $courseId');
      }
      return doc;
    } catch (e) {
      print('Error fetching course: $e');
      rethrow;
    }
  }

  // التحقق من وجود الكورس
  Future<bool> checkCourseExists(String courseId) async {
    try {
      final courseDoc =
          await _firestore.collection('Courses').doc(courseId).get();
      return courseDoc.exists;
    } catch (e) {
      print('حدث خطأ في التحقق من وجود الكورس: $e');
      return false;
    }
  }

  // جلب كل الدروس الخاصة بكورس معيّن
  Future<List<QueryDocumentSnapshot>> getLessonsByCourseId(
    String courseId,
  ) async {
    print('جاري البحث عن الدروس في Firestore للكورس: $courseId');

    try {
      // التحقق من وجود الكورس أولاً
      final courseExists = await checkCourseExists(courseId);
      if (!courseExists) {
        print('الكورس غير موجود: $courseId');
        return [];
      }

      final querySnapshot =
          await _firestore
              .collection('Lessons')
              .where('course_id', isEqualTo: courseId)
              .orderBy('order', descending: false)
              .get();

      print('تم العثور على ${querySnapshot.docs.length} درس');

      // طباعة تفاصيل كل درس للتحقق
      for (var doc in querySnapshot.docs) {
        print('درس: ${doc.id}');
        print('بيانات الدرس: ${doc.data()}');
      }

      return querySnapshot.docs;
    } catch (e) {
      print('حدث خطأ في جلب الدروس: $e');
      rethrow;
    }
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
