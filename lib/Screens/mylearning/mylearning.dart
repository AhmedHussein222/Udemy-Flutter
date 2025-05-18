import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  String selectedTab = "All";
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategoriesFromFirebase();
  }

  Future<void> fetchCategoriesFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Categories').get();

      List<String> fetchedCategories =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Courses",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  buildTab("All"),
                  buildTab("Downloaded"),
                  buildTab("Archived"),
                  buildTab("Favourited"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // محتوى التاب
            Expanded(
              child: selectedTab == "All"
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          // الصورة
                          Center(
                            child: Image.asset(
                              'assets/Images/value-prop-teach-2x-v3.webp',
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // العنوان
                          const Text(
                            "What will you learn first?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // الوصف
                          const Text(
                            "Your courses will go here.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // الكاتيجوريز من فايربيز
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: categories.map((category) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  : buildTabContent(),

            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent() {
  if (selectedTab == "Downloaded") {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(height: 60),
        Icon(
          Icons.download_for_offline_outlined,
          color: Colors.white,
          size: 60,
        ),
        SizedBox(height: 20),
        Text(
          "Nothings downloaded yet",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "When you download a course to take with you, you'll see them here!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  } else {
    return const Center(
      child: Text(
        "No Matching courses",
        style: TextStyle(
           fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}


  Widget buildTab(String label) {
    bool isSelected = selectedTab == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
