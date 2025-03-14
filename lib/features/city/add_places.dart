import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/city/get_places.dart';
import '../offers/cutom_button.dart';

class AddPlaces extends StatefulWidget {
  const AddPlaces({super.key});

  @override
  State<AddPlaces> createState() => _AddPlacesState();
}

class _AddPlacesState extends State<AddPlaces> {
  // Controllers for name fields
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();

  // Selected country, city, and index
  String? selectedCountry;
  String? selectedCityId;
  int? selectedIndex;

  // Countries
  final List<Map<String, String>> countries = [
    {'name': 'الكويت', 'nameEn': 'Kuwait'},
    {'name': 'السعودية', 'nameEn': 'Saudi Arabia'},
    {'name': 'مصر', 'nameEn': 'Egypt'},
  ];

  bool isLoadingCities = false;
  // List of cities fetched from Firestore
  List<Map<String, dynamic>> cities = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch cities based on selected country
  Future<void> _fetchCities(String countryName) async {
    setState(() {
      isLoadingCities = true;
      selectedCityId = null; // Reset city selection
      cities.clear();
    });

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('city')
          .where('country', isEqualTo: countryName)
          .get();

      setState(() {
        cities = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'city': doc['city'],
                  'cityEn': doc['cityEn'],
                })
            .toList();
        isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCities = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cities: $e')),
      );
    }
  }

  String name = '';

  Future<String?> getCityName(String cityId) async {
    print("id===$cityId");

    try {
      // Query Firestore for the city document where 'id' matches cityId
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('city')
              .where('id', isEqualTo: cityId)
              .get();

      // Check if any documents were returned
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming 'id' is unique)
        final doc = querySnapshot.docs.first;
        final cityName = doc.data()['city'];
        name = cityName;
        print("name=====$name");
        return cityName; // Return the city name
      } else {
        // No documents found
        print("City with ID $cityId not found");
        return null;
      }
    } catch (e) {
      // Handle any errors
      print("Error fetching city name: $e");
      return null;
    }
  }

  // Function to add place to Firestore
  Future<void> _addPlaceToFirestore() async {
    if (_nameArController.text.isEmpty ||
        _nameEnController.text.isEmpty ||
        selectedCityId == null ||
        selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال جميع الحقول')),
      );
      return;
    }

    try {
      // Add place to 'locations' collection
      DocumentReference docRef = await _firestore.collection('locations').add({
        'cityId': selectedCityId,
        'name': _nameArController.text,
        'country': selectedCountry,
        'city': name,
        'nameEn': _nameEnController.text,
        'index': selectedIndex, // Add the selected index
      });

      // Update with the document ID
      await docRef.update({'id': docRef.id});
      print("DOCid==${docRef.id}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الموقع بنجاح')),
      );

      // Clear inputs after success
      _nameArController.clear();
      _nameEnController.clear();
      setState(() {
        selectedCountry = null;
        selectedCityId = null;
        selectedIndex = null;
        cities.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الإضافة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 93,
        backgroundColor: primary,
        title: const Text(
          'المناطق',
          style: TextStyle(
              color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomButton(
              width: 290,
              text: 'عرض المناطق',
              onPressed: () {
                Get.to(const GetPlacesView());
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Country Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اختر البلد',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedCountry,
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country['name'],
                  child: Text(country['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
                _fetchCities(value!);
              },
            ),
            const SizedBox(height: 16),

            // City Dropdown
            if (selectedCountry != null)
              isLoadingCities
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'اختر المدينة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedCityId,
                      items: cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city['id'],
                          child: Text(city['city']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCityId = value;
                        });
                      },
                    ),
            const SizedBox(height: 16),

            // Index Dropdown
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'اختر الترتيب ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedIndex,
              items: List.generate(55, (index) => index + 1)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Name in Arabic
            TextFormField(
              controller: _nameArController,
              decoration: InputDecoration(
                labelText: 'اسم الموقع (بالعربية)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name in English
            TextFormField(
              controller: _nameEnController,
              decoration: InputDecoration(
                labelText: 'اسم الموقع (بالإنجليزية)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                getCityName(selectedCityId!);
                Future.delayed(const Duration(seconds: 2)).then((value) {
                  _addPlaceToFirestore();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 22),
              ),
              child: const Text(
                'إضافة',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}