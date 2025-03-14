// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yemen_services_dashboard/features/categories/cat_controller.dart';

import '../categories/image_widget.dart';

class AddOfferScreen2 extends StatefulWidget {
  @override
  _AddOfferScreenState createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Variables
  String? _selectedServiceProviderEmail;
  String? _selectedCountry;
  String? _selectedOfferType; // 'daily' or 'weekly'
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  // Fetch service providers
  Future<List<QueryDocumentSnapshot>> _fetchServiceProviders() async {
    final querySnapshot = await _firestore.collection('serviceProviders').get();
    return querySnapshot.docs;
  }

  // Add new offer
  Future<void> _addOffer() async {
    print("prov====$_selectedServiceProviderEmail");
    CatController controller = Get.put(CatController());
    print("=======IMAGE==========${controller.imageUrl}");

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Set start and end dates based on the selected offer type
        _startTime = DateTime.now();
        if (_selectedOfferType == 'daily') {
          _endTime = _startTime!.add(const Duration(days: 1));
        } else if (_selectedOfferType == 'weekly') {
          _endTime = _startTime!.add(const Duration(days: 7));
        }

        await _firestore.collection('offers').add({
          'cat': selectedCategoryId,
          'sub_cat': selectedSubCat,
          'description': _descriptionController.text,
          'email': providers[0]['email'],
          'start_date': Timestamp.fromDate(_startTime!),
          'end_date': Timestamp.fromDate(_endTime!),
          'type': _selectedOfferType, // Set the type based on the selection
          'lat': 0.0,
          'price': _priceController.text,
          'lng': 0.0,
          'time': "${_startTime!.hour}:${_startTime!.minute}",
          'image': controller.uploadedFileURL,
          'name': providers[0]['name'],
          'providerId': providers[0]['id'],
          'title': _titleController.text,
          'country': _selectedCountry,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة العرض بنجاح')),
        );

        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedServiceProviderEmail = null;
          _selectedCountry = null;
          _selectedOfferType = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إضافة العرض: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> providers = [];

  Future<List<Map<String, dynamic>>> getServiceProviderByEmail(String email) async {
    providers = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('serviceProviders')
          .where('email', isEqualTo: email)
          .get();

      providers = snapshot.docs
          .map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id
      })
          .toList();
      _addOffer();
      return providers;
    } catch (e) {
      print("Error fetching service provider: $e");
      return [];
    }
  }

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];
  String? selectedCategoryId;
  bool isLoading = true;
  String? selectedSubCat;

  @override
  void initState() {
    super.initState();
    fetchCategories();
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
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('sub_cat')
              .where('cat', isEqualTo: catId)
              .get();
      setState(() {
        subCategories = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error fetching subcategories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عرض جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text("اضف صورة العرض"),
                    const SizedBox(height: 10),
                    ImageWidget(txt: 'اضف صورتك الشخصية'),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان العرض',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان العرض';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف العرض',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف العرض';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'سعر العرض',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال السعر ';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'اختر الدولة',
                    border: OutlineInputBorder(),
                  ),
                  items: ['مصر', 'سعودية', 'الكويت']
                      .map((country) => DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الدولة';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchServiceProviders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('لا يوجد مزودي خدمات متاحين');
                    }
                    final serviceProviders = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedServiceProviderEmail,
                      decoration: const InputDecoration(
                        labelText: 'اختر مقدم الخدمة',
                        border: OutlineInputBorder(),
                      ),
                      items: serviceProviders.map((provider) {
                        final data = provider.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: data['email'],
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                CachedNetworkImageProvider(data['image']),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['name']),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedServiceProviderEmail = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار مقدم الخدمة';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('اختر القسم '),
                      value: selectedCategoryId,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategoryId = newValue;
                          subCategories = [];
                        });
                        if (newValue != null) {
                          fetchSubCategories(newValue);
                        }
                      },
                      items: categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['name'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
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
                          value: category['name'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
             Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: DropdownButtonFormField<String>(
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
              ),
              const SizedBox(height: 20),
              Padding(
                 padding: const EdgeInsets.only(left: 28.0, right: 26),
                child: ElevatedButton(
                  onPressed: () {
                    getServiceProviderByEmail(_selectedServiceProviderEmail!);
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إضافة العرض'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
                const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}