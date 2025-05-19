import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({super.key});

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _fetchCourses(_searchController.text.trim());
    });
  }

  Future<void> _fetchCourses(String searchQuery) async {
    setState(() {
      isLoading = true;
      courses = [];
    });

    try {
      if (searchQuery.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final query = searchQuery.trim().toLowerCase();
      List<Map<String, dynamic>> allCourses = [];

  
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('Categories').get();
      final categoryMap = {
        for (var doc in categorySnapshot.docs)
          doc.id: doc.data()['name']?.toString().toLowerCase() ?? ''
      };

      final instructorSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      final instructorMap = {
        for (var doc in instructorSnapshot.docs)
          doc.id: doc.data()['first_name']?.toString().toLowerCase() ?? ''
      };

      final subcategorySnapshot =
          await FirebaseFirestore.instance.collection('SubCategories').get();
      final subcategoryMap = {
        for (var doc in subcategorySnapshot.docs)
          doc.id: doc.data()['name']?.toString().toLowerCase() ?? ''
      };

      // Fetch course ratings
      final reviewsSnapshot =
          await FirebaseFirestore.instance.collection('Reviews').get();
      final ratingsMap = <String, List<double>>{};
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        final courseId = data['course_id']?.toString();
        final rating = data['rating']?.toDouble() ?? 0.0;
        if (courseId != null) {
          ratingsMap.putIfAbsent(courseId, () => []).add(rating);
        }
      }

      final averageRatings = <String, double>{};
      ratingsMap.forEach((courseId, ratings) {
        final avg = ratings.reduce((a, b) => a + b) / ratings.length;
        averageRatings[courseId] = avg;
      });

      // Parse search query for price or text
      Query<Map<String, dynamic>> courseQuery =
          FirebaseFirestore.instance.collection('Courses');

      bool isPriceQuery = false;
      double? minPrice;
      double? maxPrice;


      if (query == 'free' || query == 'gratis') {
        isPriceQuery = true;
        courseQuery = courseQuery.where('price', isEqualTo: 0);
      } else if (query.contains('under') || query.contains('below')) {
        final priceStr = query.replaceAll(RegExp(r'under|below|\$'), '').trim();
        minPrice = 0;
        maxPrice = double.tryParse(priceStr);
        if (maxPrice != null) {
          isPriceQuery = true;
          courseQuery = courseQuery
              .where('price', isGreaterThanOrEqualTo: 0)
              .where('price', isLessThanOrEqualTo: maxPrice);
        }
      } else if (query.contains('above') || query.contains('over')) {
        final priceStr = query.replaceAll(RegExp(r'above|over|\$'), '').trim();
        minPrice = double.tryParse(priceStr);
        if (minPrice != null) {
          isPriceQuery = true;
          courseQuery = courseQuery.where('price', isGreaterThanOrEqualTo: minPrice);
        }
      } else if (query.contains('-')) {
        final parts = query.split('-').map((e) => e.trim()).toList();
        if (parts.length == 2) {
          minPrice = double.tryParse(parts[0].replaceAll('\$', ''));
          maxPrice = double.tryParse(parts[1].replaceAll('\$', ''));
          if (minPrice != null && maxPrice != null) {
            isPriceQuery = true;
            courseQuery = courseQuery
                .where('price', isGreaterThanOrEqualTo: minPrice)
                .where('price', isLessThanOrEqualTo: maxPrice);
          }
        }
      } else if (RegExp(r'^\$?\d+(\.\d+)?$').hasMatch(query)) {
        final price = double.tryParse(query.replaceAll('\$', '')) ?? 0;
        isPriceQuery = true;
        courseQuery = courseQuery
            .where('price', isGreaterThanOrEqualTo: price - 10)
            .where('price', isLessThanOrEqualTo: price + 10);
      }

      final coursesSnapshot = await courseQuery.get();
      allCourses = coursesSnapshot.docs.map((doc) {
        final courseData = doc.data();
        final avgRating = averageRatings[doc.id] ?? 0.0;
        return {
          'id': doc.id,
          ...courseData,
          'rating': {
            'rate': avgRating,
            'count': ratingsMap[doc.id]?.length ?? 0,
          },
        };
      }).toList();

      if (!isPriceQuery || query.contains(' ')) {
        final textQuery = isPriceQuery ? query.split(' ').last : query;
        allCourses = allCourses.where((course) {
          final categoryName = categoryMap[course['category_id']?.toString()] ?? '';
          final instructorName = instructorMap[course['instructor_id']?.toString()] ?? '';
          final subcategoryName = subcategoryMap[course['subcategory_id']?.toString()] ?? '';
          final title = course['title']?.toString().toLowerCase() ?? '';
          return categoryName.contains(textQuery) ||
              subcategoryName.contains(textQuery) ||
              instructorName.contains(textQuery) ||
              title.contains(textQuery);
        }).toList();
      }

      // Remove duplicates
      final seenIds = <String>{};
      allCourses = allCourses.where((course) {
        final id = course['id']?.toString() ?? course['title']?.toString() ?? '';
        if (seenIds.contains(id)) return false;
        seenIds.add(id);
        return true;
      }).toList();

      print('Found ${allCourses.length} courses for query: "$query"');

      setState(() {
        courses = allCourses;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: $error')),
      );
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Subcategory Courses'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Expanded(
                    child: courses.isEmpty
                        ? const Center(
                            child: Text(
                              'No courses found',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return GestureDetector(
                                onTap: () {
                                
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseDetailsScreen(
                                        courseData: course,
                                      ),
                                    ),
                                  );
                                  
                                },
                                child: Card(
                                  color: Colors.grey[900],
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          course['thumbnail'] ??
                                              'https://via.placeholder.com/150',
                                          width: 120,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Image.asset(
                                            'assets/images/billboard-mobile-v3.webp',
                                            width: 120,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course['title'] ?? 'No Title',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                course['description'] ?? 'No Description',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[400],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${course['rating']['rate']?.toString() ?? '4.5'} (${course['rating']['count']?.toString() ?? '0'} ratings)',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                course['price'] == 0
                                                    ? 'Free'
                                                    : '\$${course['price']?.toString() ?? '19.99'}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}