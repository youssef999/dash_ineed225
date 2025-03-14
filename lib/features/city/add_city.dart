import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';

import '../../core/theme/colors.dart';
import 'get_city.dart';

// Replace with your primary color
//const Color primary = Colors.teal;

class AddCity extends StatefulWidget {
  const AddCity({super.key});

  @override
  State<AddCity> createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  // Controllers for TextFormFields
  final TextEditingController _cityArController = TextEditingController();
  final TextEditingController _cityEnController = TextEditingController();

  // Country dropdown list
  final List<Map<String, String>> countries = [
    {'country': 'الكويت', 'countryEn': 'Kuwait'},
    {'country': 'السعودية', 'countryEn': 'Saudi Arabia'},
    {'country': 'مصر', 'countryEn': 'Egypt'},
  ];

  String? selectedCountry; // Holds the Arabic country name
  String? selectedCountryEn; // Holds the English country name

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add city to Firestore
  Future<void> _addCityToFirestore() async {
    if (_cityArController.text.isEmpty ||
        _cityEnController.text.isEmpty ||
        selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال جميع الحقول')),
      );
      return;
    }

    try {
      // Add a new document and retrieve the document reference
      DocumentReference docRef = await _firestore.collection('city').add({
        'city': _cityArController.text,
        'cityEn': _cityEnController.text,
        'country': selectedCountry,
        'countryEn': selectedCountryEn,
      });

      // Update the document to include the ID as a field
      await _firestore.collection('city').doc(docRef.id).update({
        'id': docRef.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المدينة بنجاح')),
      );

      // Clear inputs after success
      _cityArController.clear();
      _cityEnController.clear();
      setState(() {
        selectedCountry = null;
        selectedCountryEn = null;
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
        backgroundColor: primary,
        toolbarHeight: 94,
        title: const Text(
          'المحافظات ',
          style: TextStyle(
              color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
        ),
        actions: [
          //GetCityView 

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomButton(
              width: 290,
              text: 'عرض المحافظات ', onPressed: (){
            
              Get.to(const GetCityView ());
            }),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(33.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            // Arabic City Name Field
            TextFormField(
              controller: _cityArController,
              decoration: InputDecoration(
                labelText: 'اسم المدينة (بالعربية)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // English City Name Field
            TextFormField(
              controller: _cityEnController,
              decoration: InputDecoration(
                labelText: 'اسم المدينة (بالإنجليزية)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Country Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'الدولة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedCountry,
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country['country'],
                  child: Text(country['country']!),
                  onTap: () {
                    setState(() {
                      selectedCountryEn = country['countryEn'];
                    });
                  },
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
              },
            ),
            const SizedBox(height: 24),
            // Add Button
            ElevatedButton(
              onPressed: _addCityToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'إضافة ',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
