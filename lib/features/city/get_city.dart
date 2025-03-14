import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class GetCityView extends StatefulWidget {
  const GetCityView({super.key});

  @override
  State<GetCityView> createState() => _GetCityViewState();
}

class _GetCityViewState extends State<GetCityView> {
  List<String> countries = ['مصر', 'الكويت', 'السعودية']; // List of countries
  List<Map<String, dynamic>> cities = []; // List of cities for the selected country
  String? selectedCountry; // Selected country
  bool isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          "عرض المدن",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Selection Dropdown
            DropdownButton<String>(
              hint: const Text('اختر الدولة'),
              value: selectedCountry,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCountry = newValue;
                    cities = []; // Clear cities list
                  });
                  fetchCities(newValue); // Fetch cities for the selected country
                }
              },
              items: countries.map<DropdownMenuItem<String>>((country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Cities List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cities.isEmpty
                      ? const Center(child: Text("لا توجد مدن متاحة"))
                      : ListView.builder(
                          itemCount: cities.length,
                          itemBuilder: (context, index) {
                            final city = cities[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0),
                              child: ListTile(
                                title: Text(city['city']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => editCity(city),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteCity(city['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch cities based on selected country
  Future<void> fetchCities(String country) async {
    setState(() => isLoading = true);

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('city')
              .where('country', isEqualTo: country)
              .get();

      setState(() {
        cities = querySnapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cities: $e");
      setState(() => isLoading = false);
    }
  }

  // Delete a city
  Future<void> deleteCity(String cityId) async {
    try {
      await FirebaseFirestore.instance.collection('city').doc(cityId).delete();

      // Refresh the cities list
      if (selectedCountry != null) {
        fetchCities(selectedCountry!);
      }
    } catch (e) {
      print("Error deleting city: $e");
    }
  }

  // Edit a city
  Future<void> editCity(Map<String, dynamic> city) async {
    final TextEditingController cityController =
        TextEditingController(text: city['city']);

 final TextEditingController cityControllerEn =
        TextEditingController(text: city['cityEn']);

    String? selectedCountry = city['country']; // Default to the current country

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل المدينة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'اسم المدينة'),
              ),
              const SizedBox(height: 16),
               TextField(
                controller: cityControllerEn,
                decoration: const InputDecoration(labelText: ' اسم المدينة بالإنجليزية'),
              ),
               const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: const InputDecoration(labelText: 'اختر الدولة'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                  });
                },
                items: countries.map<DropdownMenuItem<String>>((country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('city')
                      .doc(city['id'])
                      .update({
                    'city': cityController.text,
                    'country': selectedCountry,
                    'cityEn':cityControllerEn.text
                  });

                  // Refresh the cities list
                  if (selectedCountry != null) {
                    fetchCities(selectedCountry!);
                  }

                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error updating city: $e");
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}