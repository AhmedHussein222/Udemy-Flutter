import 'package:flutter/material.dart';
import 'package:udemyflutter/services/course_content_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseId;
  const CourseContentScreen({Key? key, this.courseId = '2'}) : super(key: key);

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  final CourseContentService _service = CourseContentService();
  List<Map<String, dynamic>> lessons = [];
  Map<String, dynamic>? selectedLesson;
  WebViewController? _webViewController;
  bool showMore = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _courseExists = true;
  Map<String, dynamic>? courseData;

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  Future<void> loadLessons() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // جلب بيانات الدورة والدروس معاً
      final results = await Future.wait([
        _service.getCourseById(widget.courseId),
        _service.getLessonsByCourseId(widget.courseId),
      ]);

      final courseDataSnap = results[0] as dynamic;
      final lessonsSnap = results[1] as List;

      // التحقق من وجود الدورة
      if (courseDataSnap == null || !(courseDataSnap.exists ?? false)) {
        setState(() {
          _courseExists = false;
          _errorMessage = 'Course does not exist';
          _isLoading = false;
        });
        return;
      }

      final courseMap = courseDataSnap.data() as Map<String, dynamic>?;
      final lessonsList =
          lessonsSnap.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        courseData = courseMap;
        lessons = lessonsList;
        if (lessons.isNotEmpty && lessons[0]['video_url'] != null) {
          selectedLesson = lessons[0];
          _initVideo(lessons[0]['video_url']);
        } else if (lessons.isEmpty) {
          _errorMessage = 'No lessons available for this course';
        } else {
          _errorMessage = 'No video available for the first lesson';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading course or lessons';
        _isLoading = false;
      });
    }
  }

  Future<void> _initVideo(String url) async {
    try {
      print('Initializing video: $url');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final embedUrl = _getEmbedUrl(url);
      if (embedUrl.isEmpty) {
        throw Exception('Invalid YouTube URL');
      }

      _webViewController =
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(embedUrl));

      print('Video initialized successfully');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading video: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading video. Please check the URL';
      });
    }
  }

  String _getEmbedUrl(String url) {
    String? videoId;
    if (url.contains('youtube.com/watch')) {
      videoId = Uri.parse(url).queryParameters['v'];
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/')[1];
    }
    if (videoId == null || videoId.isEmpty) {
      return '';
    }
    return 'https://www.youtube.com/embed/$videoId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : !_courseExists
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Unexpected error occurred',
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
              : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    if (_errorMessage != null)
                      Container(
                        height: 200,
                        color: Colors.red[900],
                        child: Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else if (_webViewController != null)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: WebViewWidget(controller: _webViewController!),
                      )
                    else
                      Container(
                        height: 200,
                        color: Colors.grey[900],
                        child: const Center(
                          child: Text(
                            'No video available',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseData?['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    TabBar(
                      labelColor: Colors.deepPurple,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.deepPurple,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Lectures'),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  courseData?['description'] ??
                                      'No description available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  "What you'll learn",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...(courseData?['what_will_learn']
                                            as List<dynamic>? ??
                                        [])
                                    .map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              size: 20,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item.toString(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Requirements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...(courseData?['requirements']
                                            as List<dynamic>? ??
                                        [])
                                    .map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.arrow_right,
                                              size: 20,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item.toString(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Course Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'Language',
                                  courseData?['language'] ?? 'English',
                                ),
                                _buildDetailRow(
                                  'Level',
                                  courseData?['level'] ?? 'All Levels',
                                ),
                                _buildDetailRow(
                                  'Duration',
                                  '${(courseData?['duration'] ?? 0) >= 60 ? '${((courseData?['duration'] ?? 0) / 60).toStringAsFixed(1)} hours' : '${courseData?['duration'] ?? 0} minutes'}',
                                ),
                                _buildDetailRow(
                                  'Lectures',
                                  '${lessons.length} lectures',
                                ),
                                _buildDetailRow(
                                  'Last Updated',
                                  courseData?['created_at'] ?? 'N/A',
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            itemCount: lessons.length,
                            itemBuilder: (context, index) {
                              final lesson = lessons[index];
                              final isSelected = selectedLesson == lesson;
                              return Container(
                                color:
                                    isSelected
                                        ? Colors.grey[900]
                                        : Colors.black,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.download_rounded,
                                    color: Colors.deepPurple,
                                  ),
                                  title: Text(
                                    lesson['title'] ?? 'No title',
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    lesson['type'] == 'video'
                                        ? 'Video - ${lesson['duration']} mins'
                                        : lesson['type'] == 'article'
                                        ? 'Article'
                                        : '',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  trailing: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  onTap: () {
                                    if (lesson['video_url'] != null) {
                                      setState(() {
                                        selectedLesson = lesson;
                                        _initVideo(lesson['video_url']);
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
