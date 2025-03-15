

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/categories/cat_controller.dart';
import 'package:yemen_services_dashboard/features/categories/image_widget.dart';

class AddAdScreen3 extends StatefulWidget{

  const AddAdScreen3({super.key});
  @override
  _AddAdScreenState createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen3> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  // Controllers


  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  
  //Variables
  String? _selectedCat;
  String? _selectedSubCat;
  String? _selectedServiceProviderEmail;
  DateTime? _startTime;
  DateTime? _endTime;
  List<QueryDocumentSnapshot> _subCatDocs = [];
  bool _isLoading = false;


  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final querySnapshot = await _firestore.collection('cat').get();
    // Define the "main" category
    final mainCategory = {
      'id': 'main', // Unique identifier for the "main" category
      'name': 'الرئيسية',
    };
    // Convert Firestore documents to a list of maps
    final categories = querySnapshot.docs.map((doc) {
      return {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id, // Include the document ID
      };
    }).toList();

    // Add the "main" category at the beginning of the list
    categories.insert(0, mainCategory);

    return categories;
  }


  // Fetch subcategories based on selected category
  Future<void> _fetchSubCategories(String catId) async {
    final querySnapshot = await _firestore
        .collection('sub_cat')
        .where('cat', isEqualTo: catId)
        .get();
    setState(() {
      _subCatDocs = querySnapshot.docs;
      _selectedSubCat = null;
    });
  }

  // Fetch service providers
  Future<List<QueryDocumentSnapshot>> _fetchServiceProviders() async {
    final querySnapshot = await _firestore.collection('serviceProviders').get();
    return querySnapshot.docs;
  }


  Future<void> _addAd() async {
  String newCat = '';
  if (_selectedCat == 'الرئيسية') {
    newCat = 'main';
  } else {
    newCat = _selectedCat.toString();
  }

  CatController controller = Get.put(CatController());
  print("=======IMAGE==========${controller.imageUrl}");

  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    // Wait until the image URL is available and its length is greater than 5
    while (controller.uploadedFileURL == null || controller.uploadedFileURL.toString().length <= 5) {
      await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second before checking again
    }
    // Proceed with adding the ad to Firestore
    try {
      // Generate a custom ID (you can customize this logic)
      final String adId = _firestore.collection('ads').doc().id;
      await _firestore.collection('ads').doc(adId).set({
        'id': adId, // Include the custom ID in the document itself if needed
        'image': controller.uploadedFileURL,
        'imageUrl': controller.uploadedFileURL,
        'country': selectedCountry,
        'cat': newCat,
        'sub_cat': _selectedSubCat,
        'des': _descriptionController.text,
        'email': _selectedServiceProviderEmail,
        'current_date': Timestamp.fromDate(_startTime!), // Convert to Firestore Timestamp
        'end_date': Timestamp.fromDate(_endTime!), // Convert to Firestore Timestamp
        'title': _titleController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الإعلان بنجاح')),
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCat = null;
        _selectedSubCat = null;
        _selectedServiceProviderEmail = null;
        _startTime = null;
        _endTime = null;
      });

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة الإعلان: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  }


  // Add new ad
  // Future<void> _addAd() async {
  //
  //
  //
  //   CatController controller =Get.put(CatController());
  //   print("=======IMAGE=========="+controller.imageUrl!);
  //
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     try {
  //       await _firestore.collection('ads').add({
  //         'image': controller.uploadedFileURL,
  //         'imageUrl': controller.uploadedFileURL,
  //         'cat': _selectedCat,
  //         'sub_cat': _selectedSubCat,
  //         'description': _descriptionController.text,
  //         'email': _selectedServiceProviderEmail,
  //         'start_time': (_startTime!),
  //         'end_time': (_endTime!),
  //         'title': _titleController.text,
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('تمت إضافة الإعلان بنجاح')),
  //       );


  //       // Clear form
  //       _titleController.clear();
  //       _descriptionController.clear();
  //       setState(() {
  //         _selectedCat = null;
  //         _selectedSubCat = null;
  //         _selectedServiceProviderEmail = null;
  //         _startTime = null;
  //         _endTime = null;
  //       });
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('حدث خطأ أثناء إضافة الإعلان: $e')),
  //       );
  //     } finally {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }


  List<Map<String, dynamic>> serviceProviders = [];
  List<Map<String, dynamic>> filteredProviders = [];

   @override
  void initState() {
     fetchServiceProviders();
    super.initState();
  }

  Future<void> fetchServiceProviders() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('serviceProviders')
          .get();
      setState(() {
        serviceProviders = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        filteredProviders = serviceProviders;
      });
    } catch (e) {
      print("Error fetching service providers: $e");
    }
  }
  String? selectedCountry;
  final List<String> countries = ["مصر", "سعودية", "الكويت"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة إعلان جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              Column(
                children: [
                  const SizedBox(height: 24),
                  ImageWidget(txt: 'اضف صورتك الشخصية'),
                  const SizedBox(height: 20),
                ],
              ),
              // Title Field
              Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الإعلان',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان الإعلان';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

       
                Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف الإعلان',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف الإعلان';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),



              // Service Provider Dropdown
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _fetchServiceProviders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('لا يوجد مزودي خدمات متاحين');
                  }
                  final serviceProviders = snapshot.data!;
                  return  Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                    child: DropdownButtonFormField<String>(
                      value: _selectedServiceProviderEmail,
                      decoration: const InputDecoration(
                        helperMaxLines: 8,
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
                                backgroundImage: CachedNetworkImageProvider(data['image']),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['name']),
                                  //     Text(data['email'], style: const TextStyle(fontSize: 12)),
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

       Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
          child: DropdownButton<String>(
            value: selectedCountry,
            hint: const Text("اختر الدولة",
            style:TextStyle(color:Colors.black,fontSize: 21,fontWeight:FontWeight.bold),
            ),
            items: countries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCountry = newValue;
              });
          
            },
          ),
        ),
              const SizedBox(height: 20),




              // Category Dropdown
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('لا توجد فئات متاحة');
                  }
                  final categories = snapshot.data!;
                  return  Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCat,
                      decoration: const InputDecoration(
                        labelText: 'اختر الفئة',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['name'],
                          child: Text(cat['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCat = value;
                          _fetchSubCategories(value!);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار الفئة';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Subcategory Dropdown
              Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                child: DropdownButtonFormField<String>(
                  value: _selectedSubCat,
                  decoration: const InputDecoration(
                    labelText: 'اختر الفئة الفرعية',
                    border: OutlineInputBorder(),
                  ),
                  items: _subCatDocs.map((subCat) {
                    return DropdownMenuItem<String>(
                      value: subCat['name'],
                      child: Text(subCat['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCat = value;
                    });
                  },
                  validator: (value) {
                    // if (value == null || value.isEmpty) {
                    //   return 'الرجاء اختيار الفئة الفرعية';
                    // }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Start Time Picker
              Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                child: ListTile(
                  title: Text(
                    _startTime == null
                        ? 'اختر وقت البدء'
                        : 'وقت البدء: ${_startTime!.toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startTime = pickedDate;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // End Time Picker
              Padding(
                padding: const EdgeInsets.only(left:28.0,right:28),
                child: ListTile(
                  title: Text(
                    _endTime == null
                        ? 'اختر وقت الانتهاء'
                        : 'وقت الانتهاء: ${_endTime!.toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endTime = pickedDate;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              Padding(
                padding: const EdgeInsets.only(left:58.0,right:58),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addAd,
                  // ignore: sort_child_properties_last
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إضافة الإعلان'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),


              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
