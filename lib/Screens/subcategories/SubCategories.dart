import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        'title': doc['title'] ?? 'No Title',
        'image': doc['thumbnail'] ?? '',
        'description': doc['description'] ?? '',
        'price': doc['price'] ?? 'Free',
      };
    }).toList();
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
                    tabs: subCategories
                        .map((sub) => Tab(text: sub['name']))
                        .toList(),
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
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return Card(
                                color: Colors.grey[900],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    course['image'] != ''
                                        ? ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: Image.network(
                                              course['image'],
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported, size: 120, color: Colors.white70),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(course['title'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(course['description'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          const SizedBox(height: 8),
                                          Text("Price: ${course['price']}",
                                              style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
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
