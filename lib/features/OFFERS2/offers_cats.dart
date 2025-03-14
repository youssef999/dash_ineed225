import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';

import 'offersSub/offers_subcat.dart'; // Assuming you're using Firestore

class OffersCatView extends StatefulWidget {
  const OffersCatView({super.key});

  @override
  State<OffersCatView> createState() => _OffersCatViewState();
}

class _OffersCatViewState extends State<OffersCatView> {
  String? selectedCat;
  List<String> selectedSubCats = [];
  List<String> categories = [];
  List<String> subCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('cat').get();
    setState(() {
      categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> fetchSubCategories(String cat) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sub_cat')
        .where('cat', isEqualTo: cat)
        .get();
    setState(() {
      subCategories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor, // Replace with your primaryColor
        title: const Text(
          'فلتر الاقسام',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCat,
              hint: const Text('اختر القسم'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCat = newValue;
                  selectedSubCats.clear(); // Clear previous selections
                  fetchSubCategories(newValue!);
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView(
                children: subCategories.map((subCat) {
                  return CheckboxListTile(
                    title: Text(subCat),
                    value: selectedSubCats.contains(subCat),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedSubCats.add(subCat);
                        } else {
                          selectedSubCats.remove(subCat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 11,),
            CustomButton(
              width: 243,
              text: 'عرض العروض', onPressed: (){
              print("sub==$selectedSubCats");
              Get.to(OffersSubCatView(subCats: selectedSubCats.join(','),

              ));
              
            },),
          ],
        ),
      ),
    );
  }
}