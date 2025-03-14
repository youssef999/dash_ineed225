import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/statistics/cat/st_cat_view.dart';

class CatSelectionScreen extends StatefulWidget {
  @override
  _CatSelectionScreenState createState() => _CatSelectionScreenState();
}

class _CatSelectionScreenState extends State<CatSelectionScreen> {
  List<Map<String, dynamic>> cats = [];
  String? selectedCatName;

  @override
  void initState() {
    super.initState();
    fetchCats();
  }

  Future<void> fetchCats() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('cat').get();

      // Extract data
      setState(() {
        cats = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc['name'], // Ensure 'name' exists in the document
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching cats: $e');
    }
  }

  void selectCat(String catName) {
    setState(() {
      selectedCatName = catName;
    });
    print('Selected Cat: $catName');

    Get.to(StCatsView(cat: selectedCatName!.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'فلتر حسب القسم',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: cats.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left:26.0,right:20,top:10,bottom:10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Two items per row
                  crossAxisSpacing: 16.0, // Spacing between columns
                  mainAxisSpacing: 16.0, // Spacing between rows
                  childAspectRatio: 2.22, // Width to height ratio of each card
                ),
                itemCount: cats.length,
                itemBuilder: (context, index) {
                  final cat = cats[index];
                  return Padding(
                    padding: const EdgeInsets.only(left:38.0,right:38,top:12,bottom:16),
                    child: Card(
                      elevation: 5, // Add shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () => selectCat(cat['name'] ?? 'Unknown'),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              cat['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: selectedCatName != null
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(
                'القسم المحدد: $selectedCatName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}