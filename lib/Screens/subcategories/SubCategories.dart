import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemyflutter/customcard/coursesCard.dart';
import 'package:udemyflutter/customcategory/custombutton.dart';




class SubCategoriesScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  String? selectedSubCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('SubCategories')
                .where('category_id', isEqualTo: widget.categoryId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final subcategories = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subcategories.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final subId = doc.id;
                    final subName = data['name'];

                    return CustomButtonCategory(
                      text: subName,
                      onPressed: () {
                        setState(() {
                          selectedSubCategoryId = subId;
                        });
                      },
                      color: selectedSubCategoryId == subId ? Colors.white : Colors.black,
                      textColor: selectedSubCategoryId == subId ? Colors.black : Colors.white,
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          if (selectedSubCategoryId != null)
          Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Courses')
        .where('subcategory_id', isEqualTo: selectedSubCategoryId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final courses = snapshot.data!.docs;

      if (courses.isEmpty) {
        return const Center(
          child: Text("No courses found", style: TextStyle(color: Colors.white)),
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: courses.map((doc) {
              final course = doc.data() as Map<String, dynamic>;
              final instructorId = course['instructor_id'];

return FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance.collection('Users').doc(instructorId).get(),
  builder: (context, instructorSnapshot) {
    if (!instructorSnapshot.hasData) {
      return const SizedBox(
        width: 160,
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final docSnapshot = instructorSnapshot.data!;

    if (!docSnapshot.exists) {
      return SizedBox(
        width: 160,
        height: 240,
        child: Center(
          child: Text(
            'Instructor not found',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final data = docSnapshot.data();

    // تحقق إن data مش null وصيغة البيانات صحيحة
    if (data == null || data is! Map<String, dynamic>) {
      return SizedBox(
        width: 160,
        height: 240,
        child: Center(
          child: Text(
            'Invalid instructor data',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final instructorName = "${data['first_name'] ?? 'No'} ${data['last_name'] ?? 'Name'}";

    return SizedBox(
      width: 160,
      child: HoverCourseCard(
        imageUrl: course['thumbnail'],
        title: course['title'],
        instructor: instructorName,
        price: double.tryParse(course['price'].toString()) ?? 0.0,
        discount: double.tryParse(course['discount'].toString()) ?? 0.0,
        rating: course['rating']?['rate']?.toDouble() ?? 0.0,
      ),
    );
  },
);


            }).toList(),
          ),
        ),
      );
    },
  ),
),

        ],
      ),
    );
  }
}
