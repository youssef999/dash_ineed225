// ignore_for_file: unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/categories/cat_controller.dart';
import 'dart:io';
import '../categories/image_widget.dart';

// ignore: must_be_immutable
class EditOfferScreen extends StatefulWidget {
  final String offerId;
  String image;

  // ignore: use_super_parameters
  EditOfferScreen({Key? key, required this.offerId, required this.image}) : super(key: key);

  @override
  _EditOfferScreenState createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  final FirebaseFirestore _firestone = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  bool _isLoading = false;

  String? _selectedProviderId;
  List<Map<String, dynamic>> _serviceProviders = [];

  String netImage = '';
  bool appLoading = true;

  List<Map<String, dynamic>> categories = []; // List to store categories
  List<Map<String, dynamic>> subCategories = []; // List to store subcategories
  String? selectedCategoryId; // Selected category ID
  bool isLoading = false; // Loading state
  String? selectedSubCat;

  String? _selectedOfferType; // 'daily' or 'weekly'

  @override
  void initState() {
    _fetchOfferDetails();
    _fetchServiceProviders();
    fetchCategories();
    startAppLoading();
    super.initState();
  }

  startAppLoading() async {
    Future.delayed(const Duration(seconds: 2)).then((v) {
      setState(() {
        appLoading = false;
      });
    });
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('cat').get();

      setState(() {
        categories = querySnapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSubCategories(String catId) async {
    print("CAT ID===$catId");
    subCategories = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('sub_cat')
              .where('cat', isEqualTo: catId)
              .get();

      setState(() {
        subCategories = querySnapshot.docs.map((doc) => doc.data()).toList();
        if (subCategories.isNotEmpty) {
          selectedSubCat = subCategories[0]['name'];
        } else {
          selectedSubCat = '';
        }
      });

      print("========SUB=====$subCategories");
    } catch (e) {
      print("Error fetching subcategories: $e");
    }
  }

  // Fetch service providers from Firestore
  Future<void> _fetchServiceProviders() async {
    final querySnapshot = await _firestone.collection('serviceProviders').get();
    setState(() {
      _serviceProviders = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'email': doc['email'],
          'image': doc['image'],
        };
      }).toList();
    });
  }

  String provEmail = '';
  String provName = '';
  Future<String?> getProviderEmail(String providerId) async {
    try {
      // Fetch the service provider document by ID
      DocumentSnapshot providerDoc = await _firestone
          .collection('serviceProviders')
          .doc(providerId)
          .get();

      if (providerDoc.exists) {
        provEmail = providerDoc['email'];
        provName = providerDoc['name'];

        if (controller.imageUrl == null) {
          _updateOffer(widget.image);
        } else {
          Future.delayed(const Duration(seconds: 7)).then((value) {
            _updateOffer(controller.uploadedFileURL.toString());
          });
        }
        // Return the email field from the document
        return providerDoc['email'];
      } else {
        // If the document doesn't exist, return null
        print('Service provider not found');
        return null;
      }
    } catch (e) {
      // Handle any errors (e.g., Firestone connection issues)
      print('Error fetching provider email: $e');
      return null;
    }
  }

  late DocumentSnapshot<Map<String, dynamic>> offerData;

  // Fetch offer details from Firestore
  Future<void> _fetchOfferDetails() async {
    print("offerID===${widget.offerId}");

    final offerDoc = _firestone.collection('offers').doc(widget.offerId);

    offerData = await offerDoc.get();

    print("OFFER DATA=====" + offerData!['title']);

    setState(() {
      _titleController.text = offerData!['title'];
      _priceController.text = offerData!['price'].toString();
      _descriptionController.text = offerData!['description'];
      _emailController.text = offerData!['email'];
      _startDate = offerData!['start_date'].toDate();
      selectedCategoryId = offerData!['cat'];
      selectedSubCat = offerData!['sub_cat'] ?? '';
      netImage = offerData!['image'].toString();
      _endDate = offerData!['end_date'].toDate();
      _nameController.text = offerData!['name'];
      _selectedProviderId = offerData!['providerId']; // Assuming 'providerId' is stored
      _selectedOfferType = offerData!['type']; // Fetch the offer type
    });
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Update offer in Firestore
  Future<void> _updateOffer(String image) async {
    //print("====PROV===$_selectedProviderId");

    final offerDoc = _firestone.collection('offers').doc(widget.offerId);

    // Set start and end dates based on the selected offer type
    _startDate = DateTime.now();
    if (_selectedOfferType == 'daily') {
      _endDate = _startDate!.add(const Duration(days: 1));
    } else if (_selectedOfferType == 'weekly') {
      _endDate = _startDate!.add(const Duration(days: 7));
    }

    await offerDoc.update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'cat': selectedCategoryId,
      'sub_cat': selectedSubCat,
      'price': _priceController.text,
      'time': '${_startDate!.hour}:${_startDate!.minute}',
      'email': provEmail,
      'start_date': _startDate,
      'end_date': _endDate,
      'name': provName,
      'image': image,
      'providerId': _selectedProviderId.toString(),
      'type': _selectedOfferType, // Update the offer type
    });

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  CatController controller = Get.put(CatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('تعديل العرض', style: TextStyle(color: Colors.white)),
        actions: [],
      ),
      body: appLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(left: 28.0, right: 12),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 48, right: 17, top: 12, bottom: 2),
                child: Column(
                  children: [
                    // Dropdown to select service provider
                    DropdownButtonFormField<String>(
                      value: _selectedProviderId,
                      decoration: const InputDecoration(labelText: 'مقدم الخدمة'),
                      items: _serviceProviders.map((provider) {
                        return DropdownMenuItem<String>(
                          value: provider['id'],
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(provider['image']),
                                radius: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(provider['name']),
                              const SizedBox(width: 8),
                              Text('(${provider['email']})'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProviderId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'العنوان'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      maxLines: 8,
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'الوصف'),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("القسم المختار سابقا : " + offerData!['cat']),
                          // Dropdown to select a category
                          DropdownButton<String>(
                            hint: const Text(' اختر القسم '),
                            value: selectedCategoryId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategoryId = newValue;
                                subCategories = []; // Clear previous subcategories
                              });
                              if (newValue != null) {
                                fetchSubCategories(newValue); // Fetch subcategories
                              }
                            },
                            items: categories.map<DropdownMenuItem<String>>((category) {
                              return DropdownMenuItem<String>(
                                value: category['name'], // Use catId as the value
                                child: Text(category['name']), // Display category name
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          // ignore: prefer_interpolation_to_compose_strings
                          Text("القسم الفرعي المختار سابقا : " + offerData!['sub_cat']),
                          DropdownButton<String>(
                            hint: const Text('  اختر القسم الفرعي '),
                            value: selectedSubCat,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSubCat = newValue;
                              });
                            },
                            items: subCategories.map<DropdownMenuItem<String>>((category) {
                              return DropdownMenuItem<String>(
                                value: category['name'], // Use catId as the value
                                child: Text(category['name']), // Display category name
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

               (offerData!['type'] == 'daily' ) ?
               const Row(
                 children: [
                   Text('عرض يومي'),
                 ],
               ):const Text('عرض اسبوعي'),
               


                        const SizedBox(height: 8),
                    // Dropdown for Offer Type
                    DropdownButtonFormField<String>(
                      value: _selectedOfferType,
                      decoration: const InputDecoration(
                        labelText: 'نوع العرض',
                        border: OutlineInputBorder(),
                      ),
                      items: ['عرض يومي', 'عرض اسبوعي']
                          .map((type) => DropdownMenuItem(
                                value: type == 'عرض يومي' ? 'daily' : 'weekly',
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOfferType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار نوع العرض';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const Text('صورة العرض', style: TextStyle(color: Colors.black, fontSize: 21)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: widget.image,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Column(
                              children: [
                                SizedBox(
                                    height: 71,
                                    child: Image.asset('assets/logoXX.png')),
                                const SizedBox(height: 5,),
                                const Text(
                                  maxLines: 7,
                                  "هذا يعني ان صورة هذا القسم تعمل ولكنها لا تعمل علي بعض المتصفحات",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                )
                              ],
                            ),
                            height: 124,
                          ),
                        ),
                        const Divider(),
                        const Text("اضغط هنا لتغيير صورة القسم  ", style: TextStyle(color: Colors.grey)),
                        ImageWidget(txt: 'اضغط هنا لتغيير صورة القسم  '),
                        const SizedBox(height: 20),
                      ],
                    ),
                    (isLoading == false)
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              getProviderEmail(_selectedProviderId.toString());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('تعديل العرض', style: TextStyle(color: Colors.black, fontSize: 21, fontWeight: FontWeight.bold)),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator()),

                            const SizedBox(height: 40,),
                  ],
                ),
              ),
            ),
    );
  }
}