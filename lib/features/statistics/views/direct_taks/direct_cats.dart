import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';

import 'direct_task_sub.dart';

class DirectCatsView extends StatefulWidget {
  @override
  _DirectCatsViewState createState() => _DirectCatsViewState();
}

class _DirectCatsViewState extends State<DirectCatsView> {
  List<Map<String, dynamic>> cats = [];
  List<Map<String, dynamic>> subCats = [];
  String? selectedCatName;
  List<String> selectedSubCats = [];

  @override
  void initState() {
    super.initState();
    fetchCats();
  }

  Future<void> fetchCats() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('cat').get();
      setState(() {
        cats = snapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name']})
            .toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchSubCats(String catId) async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sub_cat')
          .where('cat', isEqualTo: catId).get();
      setState(() {
        subCats = snapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name']})
            .toList();
        selectedSubCats.clear();
      });
    } catch (e) {
      print('Error fetching subcategories: $e');
    }
  }

  void selectCat(Map<String, dynamic> cat) {
    setState(() {
      selectedCatName = cat['name'];
    });
    fetchSubCats(cat['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'اختر القسم',
          style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: cats.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 3.8,
                      ),
                      itemCount: cats.length,
                      itemBuilder: (context, index) {
                        final cat = cats[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () => selectCat(cat),
                            child: Center(
                              child: Text(
                                cat['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (selectedCatName != null && subCats.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'اختر الفئات الفرعية:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: subCats.map((subCat) {
                    return CheckboxListTile(
                      title: Text(subCat['name']),
                      value: selectedSubCats.contains(subCat['name']),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedSubCats.add(subCat['name']);
                          } else {
                            selectedSubCats.remove(subCat['name']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom:28.0,left:255,right:255),
        child: CustomButton(
          color1:primaryColor,
          text: 'التالي', onPressed: (){
        
          if(selectedSubCats.isEmpty){
            Get.snackbar('خطاء', 'يجب اختيار الفئات الفرعية');
          }else{
              Get.to(DirectTaskSub(subCats: selectedSubCats,));
          }
        
        },
        
        ),
      ),
    );
  }
}