import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/offersSub/view_offers_filter.dart';
import '../../../core/theme/colors.dart';

class OffersCatView2 extends StatefulWidget {
  const OffersCatView2({super.key});

  @override
  State<OffersCatView2> createState() => _OffersCatViewState();
}

class _OffersCatViewState extends State<OffersCatView2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _selectedCats = []; // Stores selected categories
  late Future<QuerySnapshot> _catsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch categories from Firestore
    _catsFuture = _firestore.collection('cat').get();
  }

  // Toggle category selection
  void _toggleCatSelection(String catName) {
    setState(() {
      if (_selectedCats.contains(catName)) {
        _selectedCats.remove(catName); // Deselect
      } else {
        _selectedCats.add(catName); // Select
      }
    });
  }

  // Save selected categories
  void _saveSelectedCats() {
    print("Selected Categories: $_selectedCats");

    Get.to(OffersSubCatView2(cats: _selectedCats.join(','),

    ));
    // You can now use _selectedCats for further processing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'الاقسام',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 28.0, right: 28),
        child: FutureBuilder<QuerySnapshot>(
          future: _catsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
               return const Center(child: Text('لا توجد عروض'));
            } else {
              var cats = snapshot.data!.docs;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cats.length,
                      itemBuilder: (context, index) {
                        var cat = cats[index].data() as Map<String, dynamic>;
                        var catName = cat['name'] as String? ?? 'Unnamed Category';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: CheckboxListTile(
                            title: Text(
                              catName,
                              style: const TextStyle(fontSize: 16),
                            ),
                            value: _selectedCats.contains(catName),
                            onChanged: (bool? value) {
                              _toggleCatSelection(catName);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: ElevatedButton(
                      onPressed: _saveSelectedCats,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'عرض العروض ',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}