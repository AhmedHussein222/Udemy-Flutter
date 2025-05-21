import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';


class SubCategoriesScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const SubCategoriesScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> subCategories = [];
  TabController? _tabController;


  Map<String, double> averageRatings = {};
  Map<String, int> reviewCounts = {};

  @override
  void initState() {
    super.initState();
    fetchSubCategories();
  }

  Future<void> fetchSubCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('SubCategories')
          .where('category_id', isEqualTo: widget.categoryId)
          .get();

      final fetched = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? 'No Name',
        };
      }).toList();

      setState(() {
        subCategories = fetched;
        _tabController = TabController(length: subCategories.length, vsync: this);
      });
    } catch (e) {
      print("Error fetching subcategories: $e");
    }
  }

Future<List<Map<String, dynamic>>> fetchCourses(String subCategoryId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Courses')
      .where('subcategory_id', isEqualTo: subCategoryId)
      .get();

  return snapshot.docs.map((doc) {
    return {
      'id': doc.id,
      'title': doc['title'] ?? 'No Title',
      'thumbnail': doc['thumbnail']?.isNotEmpty ?? false
          ? doc['thumbnail']
          : 'https://i.pinimg.com/736x/42/3b/97/423b97b41c8b420d28e84f9b07a530ec.jpg', 
      'description': doc['description'] ?? '',
      'price': doc['price'] ?? 'Free',
      'rating': {
        'rate': doc['rating']?['rate']?.toDouble() ?? 0.0,
        'count': doc['rating']?['count'] ?? 0,
      },
      'language': doc['language'] ?? 'English',
      'requirements': doc['requirements'] ?? [],
      'what_will_learn': doc['what_will_learn'] ?? [],
      'instructor_id': doc['instructor_id'] ?? '',
    };
  }).toList();
}
 
  Future<void> fetchRatingsForCourses(List<String> courseIds) async {
    if (courseIds.isEmpty) return;

    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('Reviews')
          .where('course_id', whereIn: courseIds)
          .get();

      final ratingsMap = <String, List<double>>{};

      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final courseId = data['course_id']?.toString();
        final rating = (data['rating'] is int) ? (data['rating'] as int).toDouble() : (data['rating'] ?? 0.0);
        if (courseId != null) {
          ratingsMap.putIfAbsent(courseId, () => []).add(rating);
        }
      }

      final avgRatings = <String, double>{};
      final revCounts = <String, int>{};

      ratingsMap.forEach((courseId, ratings) {
        final avg = ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;
        avgRatings[courseId] = avg;
        revCounts[courseId] = ratings.length;
      });

      setState(() {
        averageRatings = avgRatings;
        reviewCounts = revCounts;
      });
    } catch (e) {
      print('Error fetching ratings: $e');
    }
  }
  Widget buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: subCategories.isEmpty || _tabController == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Container(
                  color: Colors.black,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicatorColor: Colors.purple,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: subCategories.map((sub) => Tab(text: sub['name'])).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: subCategories.map((sub) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchCourses(sub['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("No courses found", style: TextStyle(color: Colors.white)),
                            );
                          }

                          final courses = snapshot.data!;

                          // لو ما جبناش التقييمات للكورسات بعد، نبعت نجيبهم
                          if (averageRatings.isEmpty && reviewCounts.isEmpty) {
                            // استدعاء جلب التقييمات لكل كورس
                            fetchRatingsForCourses(courses.map((c) => c['id'] as String).toList());
                          }

                       
                       
                       
                 return GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.55, 
  ),
  itemCount: courses.length,
  itemBuilder: (context, index) {
    final course = courses[index];
    final courseId = course['id'] as String;

    final rating = averageRatings[courseId] ?? 0;
    final reviewsCount = reviewCounts[courseId] ?? 0;

    return GestureDetector(
      onTap: () {
        print("Course data: $course");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(courseData: course),
          ),
        );
      },
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            course['thumbnail']?.isNotEmpty ?? false
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      course['thumbnail'],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("Image load error for ${course['image']}: $error"); // للتصحيح
                        return const Icon(
                          Icons.image_not_supported,
                          size: 120,
                          color: Colors.white70,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 120, color: Colors.white70),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      buildStarRating(rating),
                      const SizedBox(width: 6),
                      Text(
                        "$rating ($reviewsCount)",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: ${course['price']}",
                    style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);
                      
                      
                      
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
