import 'package:flutter/material.dart';
import 'package:udemyflutter/services/course_content_service.dart';
import 'package:video_player/video_player.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseId;
  const CourseContentScreen({super.key, required this.courseId});

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  final CourseContentService _service = CourseContentService();
  List<Map<String, dynamic>> lessons = [];
  Map<String, dynamic>? selectedLesson;
  VideoPlayerController? _videoController;
  bool showMore = false;

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  Future<void> loadLessons() async {
    final lessonsSnap = await _service.getLessonsByCourseId(widget.courseId);
    setState(() {
      lessons =
          lessonsSnap.map((doc) => doc.data() as Map<String, dynamic>).toList();
      if (lessons.isNotEmpty && lessons[0]['video_url'] != null) {
        selectedLesson = lessons[0];
        _initVideo(lessons[0]['video_url']);
      }
    });
  }

  void _initVideo(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محتوى الكورس')),
      body: Column(
        children: [
          // الفيديو في الأعلى
          if (_videoController != null && _videoController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          else
            Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: Text('جاري تحميل الفيديو...')),
            ),

          // قائمة الدروس
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return ListTile(
                  title: Text(lesson['title'] ?? 'بدون عنوان'),
                  onTap: () {
                    if (lesson['video_url'] != null) {
                      setState(() {
                        selectedLesson = lesson;
                        _initVideo(lesson['video_url']);
                      });
                    }
                  },
                  selected: selectedLesson == lesson,
                );
              },
            ),
          ),

          // زرار More (اختياري)
          ElevatedButton(
            onPressed: () {
              setState(() {
                showMore = !showMore;
              });
            },
            child: Text(showMore ? 'إخفاء التفاصيل' : 'المزيد'),
          ),
          if (showMore && selectedLesson != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(selectedLesson!['description'] ?? 'لا يوجد تفاصيل'),
            ),
        ],
      ),
    );
  }
}
