

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/theme/colors.dart';
import '../edit_offer.dart';

class OffersSubCatView2 extends StatefulWidget {
  final String cats;

 const OffersSubCatView2({super.key, required this.cats});

  @override
  State<OffersSubCatView2> createState() => _OffersSubCatViewState();
}

class _OffersSubCatViewState extends State<OffersSubCatView2> {
  late Future<QuerySnapshot> _offersFuture;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch all offers
    _offersFuture = FirebaseFirestore.instance.collection('offers').get();
  }

  Future<void> _deleteOffer(String offerId) async {
    bool confirmDelete = await _showConfirmDeleteDialog();
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('offers').doc(offerId).delete();
      print("Offer deleted successfully.");
    } else {
      print("Offer deletion canceled.");
    }
  }

  Future<bool> _showConfirmDeleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "تأكيد الحذف",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "هل أنت متأكد أنك تريد حذف هذا العرض؟ لا يمكن التراجع عن هذا الإجراء.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "إلغاء",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "حذف",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Helper function to filter offers locally
  List<QueryDocumentSnapshot> _filterOffers(List<QueryDocumentSnapshot> offers) {
    final subCatsList = widget.cats.split(',').map((e) => e.trim()).toList();
    return offers.where((offer) {
      final subCat = offer['cat'] as String? ?? '';
      return subCatsList.any((cat) => subCat.contains(cat));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'فلتر العروض',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 28.0, right: 28, bottom: 21),
        child: FutureBuilder<QuerySnapshot>(
          future: _offersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No offers found.'));
            } else {
              // Filter offers locally
              var filteredOffers = _filterOffers(snapshot.data!.docs);
              if (filteredOffers.isEmpty) {
                return const Center(child: Text('لا توجد عروض'));
              }
              return Padding(
                padding: const EdgeInsets.only(top: 18.0, right: 21, left: 21),
                child: ListView.builder(
                  itemCount: filteredOffers.length,
                  itemBuilder: (context, index) {
                    var offer = filteredOffers[index].data() as Map<String, dynamic>;
                    var documentId = filteredOffers[index].id; // Get the document ID
                    return OffersCardWidget(offer, documentId);
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget OffersCardWidget(Map<String, dynamic> offerData, String documentId) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, right: 20, left: 20),
      child: Card(
        margin: const EdgeInsets.all(16),
        child: ListTile(
          leading: offerData['image'] != null
              ? Image.network(
                  offerData['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image, size: 40),
          title: Text(
            offerData['title'],
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            offerData['description'],
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 30),
                onPressed: () {
                  Get.to(EditOfferScreen(
                    offerId: documentId, // Pass the document ID
                    image: offerData['image'] ?? '',
                  ));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 30),
                onPressed: () => _deleteOffer(documentId), // Pass the document ID
              ),
            ],
          ),
        ),
      ),
    );
  }
}