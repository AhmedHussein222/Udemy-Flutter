import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemyflutter/Screens/coursedetails/coursedetails.dart';

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({Key? key}) : super(key: key);

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

      bool isPriceQuery = false;
      double? priceValue;
      String? priceOperator;

      if (query.startsWith('<') || query.startsWith('>') || query.startsWith('=')) {
        isPriceQuery = true;
        priceOperator = query[0];
        final priceStr = query.substring(1).replaceAll('\$', '').trim();
        priceValue = double.tryParse(priceStr);
      } else if (RegExp(r'^\$?\d+(\.\d+)?$').hasMatch(query)) {
        isPriceQuery = true;
        priceOperator = '=';
        priceValue = double.tryParse(query.replaceAll('\$', '')) ?? 0;
      }

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

    
      QuerySnapshot coursesSnapshot;

      if (isPriceQuery && priceValue != null) {
      
        if (priceOperator == '=') {
          coursesSnapshot = await FirebaseFirestore.instance
              .collection('Courses')
              .where('price', isEqualTo: priceValue)
              .get();
        } else if (priceOperator == '<') {
          coursesSnapshot = await FirebaseFirestore.instance
              .collection('Courses')
              .where('price', isLessThanOrEqualTo: priceValue)
              .get();
        } else {
          coursesSnapshot = await FirebaseFirestore.instance
              .collection('Courses')
              .where('price', isGreaterThanOrEqualTo: priceValue)
              .get();
        }
        allCourses.addAll(coursesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
      } else {
   
        coursesSnapshot = await FirebaseFirestore.instance
            .collection('Courses')
            .get();
        allCourses.addAll(coursesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((course) {
            
              final categoryName =
                  categoryMap[course['category_id']?.toString()] ?? '';
             
              final instructorName =
                  instructorMap[course['instructor_id']?.toString()] ?? '';
           
              final subcategoryName =
                  subcategoryMap[course['subcategory_id']?.toString()] ?? '';
            
              final title = course['title']?.toString().toLowerCase() ?? '';
              return (categoryName.contains(query) ||
                  subcategoryName.contains(query) ||
                  instructorName.contains(query) ||
                  title.contains(query));
            })
            .toList());
      }


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
      backgroundColor: Colors.black,
      title: const Text(
        'Search Courses',
        style: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
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
          // Loading indicator or course list
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          'assets/Images/billboard-mobile-v3.webp',
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              course['description'] ??
                                                  'No Description',
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
                                                  '${course['rating']?['rate']?.toString() ?? '4.5'} (${course['rating']?['count']?.toString() ?? '0'} ratings)',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '\$${course['price']?.toString() ?? '19.99'}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
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
}
