import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/service_providers/adv_serach/adv_provider.dart';

class AdvSearchView extends StatefulWidget {
  const AdvSearchView({super.key});

  @override
  State<AdvSearchView> createState() => _AdvSearchViewState();
}

class _AdvSearchViewState extends State<AdvSearchView> {
  // Variables to store selected values
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedCountry;

  // Lists to store options
  List<String> categories = [];
  List<String> subCategories = [];
  final List<String> countries = ['مصر', 'الكويت', 'السعودية'];

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading states
  bool isLoadingCategories = false;
  bool isLoadingSubCategories = false;

  @override
  void initState() {
    super.initState();
    // Fetch categories from Firestore when the page loads
    _fetchCategories();
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    setState(() {
      isLoadingCategories = true;
    });
    try {
      final QuerySnapshot snapshot = await _firestore.collection('cat').get();
      setState(() {
        categories = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  // Fetch sub-categories based on the selected category
  Future<void> _fetchSubCategories(String category) async {
    setState(() {
      isLoadingSubCategories = true;
    });
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('sub_cat')
          .where('cat', isEqualTo: category)
          .get();
      setState(() {
        subCategories = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      print('Error fetching sub-categories: $e');
    } finally {
      setState(() {
        isLoadingSubCategories = false;
      });
    }
  }

  // Save selected data
  void _saveSelectedData() {
    if (selectedCategory != null && selectedSubCategory != null && selectedCountry != null) {
      print('Selected Category: $selectedCategory');
      print('Selected Sub-Category: $selectedSubCategory');
      print('Selected Country: $selectedCountry');

      Get.to(AdvProvidersScreen(
        cat:selectedCategory!,
        subCat: selectedSubCategory!,
        country: selectedCountry!,
      ));
      // You can now use these values for further processing (e.g., filtering data)
    } else {
      print('Please select all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث متقدم',style:TextStyle(color:Colors.white,)),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Dropdown
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'اختر الفئة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedCategory = value;
                                selectedSubCategory = null; // Reset sub-category when category changes
                                if (value != null) {
                                  _fetchSubCategories(value);
                                }
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sub-Category Dropdown
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'اختر الفئة الفرعية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    isLoadingSubCategories
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: selectedSubCategory,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: subCategories.map((String subCategory) {
                              return DropdownMenuItem<String>(
                                value: subCategory,
                                child: Text(subCategory),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedSubCategory = value;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Country Dropdown
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'اختر الدولة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCountry,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: countries.map((String country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveSelectedData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'حفظ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}