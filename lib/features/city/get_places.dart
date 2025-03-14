import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class GetPlacesView extends StatefulWidget {
  const GetPlacesView({super.key});

  @override
  State<GetPlacesView> createState() => _GetPlacesViewState();
}

class _GetPlacesViewState extends State<GetPlacesView> {
  List<Map<String, dynamic>> countries = [
    {'id': '1', 'name': 'مصر'},
    {'id': '2', 'name': 'الكويت'},
    {'id': '3', 'name': 'السعودية'}
  ];
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> locations = [];

  String? selectedCountryId;
  String? selectedCityId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Fetch cities based on selected country
  Future<void> fetchCities(String countryId) async {
    setState(() {
      isLoading = true;
      selectedCityId = null;
      cities = [];
      locations = [];
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('city')
              .where('country', isEqualTo: countryId)
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

  // Fetch locations based on selected city
  Future<void> fetchLocations(String cityId) async {
    setState(() {
      isLoading = true;
      locations = [];
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('locations')
              .where('cityId', isEqualTo: cityId)
              .get();

      setState(() {
        locations = querySnapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching locations: $e");
      setState(() => isLoading = false);
    }
  }

  // Delete a location
  Future<void> deleteLocation(String locationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(locationId)
          .delete();

      // Refresh the locations list
      if (selectedCityId != null) {
        fetchLocations(selectedCityId!);
      }
    } catch (e) {
      print("Error deleting location: $e");
    }
  }

  // Edit a location
  Future<void> editLocation(Map<String, dynamic> location) async {
    final TextEditingController nameController =
        TextEditingController(text: location['name']);
    final TextEditingController nameControllerEn =
        TextEditingController(text: location['nameEn']);

    // Fetch cities for the dropdown
    List<Map<String, dynamic>> cities = [];
    String? selectedCityId = location['cityId']; // Default to the current cityId
    int? selectedIndex = location['index']; // Default to the current index

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('city')
              .where('country', isEqualTo: location['country'])
              .get();
      cities = querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching cities: $e");
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الموقع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الموقع'),
              ),
              TextField(
                controller: nameControllerEn,
                decoration:
                    const InputDecoration(labelText: 'اسم الموقع بالإنجليزية'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCityId,
                decoration: const InputDecoration(labelText: 'اختر المدينة'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCityId = newValue;
                  });
                },
                items: cities.map<DropdownMenuItem<String>>((city) {
                  return DropdownMenuItem<String>(
                    value: city['id'],
                    child: Text(city['city']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedIndex,
                decoration: const InputDecoration(labelText: 'اختر الترتيب'),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedIndex = newValue;
                  });
                },
                items: List.generate(25, (index) => index + 1)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
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
                      .collection('locations')
                      .doc(location['id'])
                      .update({
                    'name': nameController.text,
                    'nameEn': nameControllerEn.text,
                    'cityId': selectedCityId,
                    'index': selectedIndex, // Save the selected index
                  });

                  // Refresh the locations list
                  if (selectedCityId != null) {
                    fetchLocations(selectedCityId!);
                  }

                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error updating location: $e");
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'المناطق',
          style: TextStyle(color: Colors.white, fontSize: 19),
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
              value: selectedCountryId,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCountryId = newValue;
                    selectedCityId = null;
                    cities = [];
                    locations = [];
                  });
                  fetchCities(newValue);
                }
              },
              items: countries.map<DropdownMenuItem<String>>((country) {
                return DropdownMenuItem<String>(
                  value: country['name'],
                  child: Text(country['name']),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // City Selection Dropdown
            if (selectedCountryId != null)
              DropdownButton<String>(
                hint: const Text('اختر المدينة'),
                value: selectedCityId,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCityId = newValue;
                      locations = [];
                    });
                    fetchLocations(newValue);
                  }
                },
                items: cities.map<DropdownMenuItem<String>>((city) {
                  return DropdownMenuItem<String>(
                    value: city['id'],
                    child: Text(city['city']),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Locations List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : locations.isNotEmpty
                      ? ListView.builder(
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final location = locations[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0),
                              child: ListTile(
                                title: Text(location['name']),
                                subtitle: Text('الترتيب ${location['index'] ?? ''}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => editLocation(location),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteLocation(location['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text("لا توجد مواقع متاحة")),
            ),
          ],
        ),
      ),
    );
  }
}