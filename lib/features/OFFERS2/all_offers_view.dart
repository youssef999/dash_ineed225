import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/add_offer.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/edit_offer.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/offersSub/offers_cat_view.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/offers_type.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';

import 'offers_cats.dart';

class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;

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
        title: const Text('العروض'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: CustomButton(
                color1: primary,
                text: 'اضافة عرض جديد', onPressed: () {
              Get.to(AddOfferScreen2());
            }),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 11,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                width: 250,
                color1: Colors.blue,
                text: 'عروض اسبوعية',
                onPressed: () {
                  Get.to(OffersTypeView(type: 'weekly', title: 'عروض اسبوعية',));
                },
              ),
              CustomButton(
                  width: 250,
                color1: Colors.green,
                text: 'عروض يومية',
                onPressed: () {
                  Get.to(OffersTypeView(type: 'daily', title: 'عروض يومية',));
                },
              ),
            ],
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.only(bottom:20,top:20,left:48.0,right:48),
            child: CustomButton(
              color1: primary,
              text: 'فلتر الاقسام',
            onPressed:(){
              Get.to(const OffersCatView2());
            },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:20,top:20,left:48.0,right:48),
            child: CustomButton(
              color1: primary,
              text: 'فلتر الاقسام الفرعية ',
            onPressed:(){
              Get.to(const OffersCatView());
            },
            ),
          ),
          const Divider(),
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
              stream: _firestore.collection('offers').snapshots(),
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
                                        offerId: offer.id.toString(),
                                        image: offerData['image'] ?? '',
                                        email: offerData['email'] ?? '',
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