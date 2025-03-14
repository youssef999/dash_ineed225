import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/categories/add_market_text.dart';
import 'package:yemen_services_dashboard/features/categories/edit_cat_market.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';

class CatMarkrtView extends StatefulWidget {
  const CatMarkrtView({super.key});

  @override
  State<CatMarkrtView> createState() => _CatMarkrtViewState();
}

class _CatMarkrtViewState extends State<CatMarkrtView> {
  String? selectedCat;
  List<String> cats = [];
  Map<String, dynamic>? catMarketData;
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchCats();
  }

  Future<void> fetchCats() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await _firestore.collection('cat').get();
    setState(() {
      cats = querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
      isLoading = false;
    });
  }

  Future<void> fetchCatMarketData(String cat) async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await _firestore
        .collection('catMarketText')
        .where('cat', isEqualTo: cat)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        catMarketData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      });
    } else {
      setState(() {
        catMarketData = null;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _deleteCatMarketData(String cat) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد أنك تريد حذف هذه البيانات؟"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if canceled
              },
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _firestore
          .collection('catMarketText')
          .where('cat', isEqualTo: cat)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      setState(() {
        catMarketData = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حذف البيانات بنجاح"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            "نص اعلاني للاقسام",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(left:46.0,right:32,top:16),
                child: Column(
                  children: [
                    // Dropdown for selecting category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCat,
                        hint: const Text("اختر قسم"),
                        isExpanded: true,
                        underline: const SizedBox(), // Remove default underline
                        items: cats.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCat = newValue;
                          });
                          fetchCatMarketData(newValue!);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display marketing text or add button
                    if (catMarketData != null)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                catMarketData!['text'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(
                                        EditCatMarketText(
                                          cat: selectedCat.toString(),
                                          txt: catMarketData!['text'],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text("تعديل"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _deleteCatMarketData(selectedCat!);
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text("حذف"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      CustomButton(
                        width: 281,
                        color1:primary,
                        text: 'اضافة نص لهذا القسم',
                        onPressed: () {
                          Get.to(
                            AddCatMarketText(
                              cat: selectedCat.toString(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}