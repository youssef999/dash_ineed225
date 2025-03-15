import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/edit_offer.dart';

// ignore: must_be_immutable
class OffersTypeView extends StatefulWidget {
  String type;
  String title;

  OffersTypeView({super.key, required this.type, required this.title});

  @override
  State<OffersTypeView> createState() => _OffersTypeViewState();
}

class _OffersTypeViewState extends State<OffersTypeView> {
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _catController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _catController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchOffers() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          OffersCardWidget(),
        ],
      ),
    );
  }

  Widget OffersCardWidget() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('offers')
                  .where("type", isEqualTo: widget.type)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final offers = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0, right: 20, left: 60),
                    child: Column(
                      children: offers.map((offer) {
                        final offerData = offer.data() as Map<String, dynamic>;

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
                                        offerId: offer.id,
                                        image: offerData['image'],
                                        email:offerData['email'],
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 30),
                                    onPressed: () => _deleteOffer(offer.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          );
  }
}