import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/categories/image_widget.dart';
import 'package:yemen_services_dashboard/features/country/add_countty.dart';
import 'package:yemen_services_dashboard/features/country/fire_service.dart';

class CountryView extends StatefulWidget {
  const CountryView({super.key});

  @override
  State<CountryView> createState() => _CountryViewState();
}

class _CountryViewState extends State<CountryView> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  void _openCountryDialog({String? docId, String? name, String? nameEn, String? image}) {
    _nameController.text = name ?? '';
    _nameEnController.text = nameEn ?? '';
    _imageController.text = image ?? '';
    bool isLoading=false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'اضف بلد جديدة' : 'تعديل'),
          content: 
          
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم '),
              ),
              TextField(
                controller: _nameEnController,
                decoration: const InputDecoration(labelText: 'الاسم بالغة الانجليزية'),
              ),
             ImageWidget(txt: '')
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('الغاء'),
            ),


            (isLoading==false)?
            TextButton(
              onPressed: () {
                  setState(() {
                      isLoading=true;
                    });
                if (docId == null) {
                  _firestoreService.addCountry(
                    _nameController.text,
                    _nameEnController.text,
                    _imageController.text,
                  );
                  Future.delayed(const Duration(seconds: 4)).then((value) {
                    Get.snackbar('تم اضافة البلد بنجاح', '',
                    colorText:Colors.white,backgroundColor:Colors.green,
                    snackPosition: SnackPosition.BOTTOM
                    );
                    setState(() {
                      isLoading=false;
                    });
                     Navigator.pop(context);
                  });
                } else {
                  // _firestoreService.updateCountry(
                  //   docId,
                  //   _nameController.text,
                  //   _nameEnController.text,
                  //   _imageController.text,
                  // );
                  // Future.delayed(const Duration(seconds: 4)).then((value) {
                  //   Get.snackbar('تم تعديل البلد بنجاح', '');
                  //    Navigator.pop(context);
                  // });
                }
               
              },
              child: 
              (isLoading==false)?
              Text(docId == null ? 'اضف' : 'تعديل'):const Center(child: CircularProgressIndicator(),),
            ):const Center(child: CircularProgressIndicator(),)
          ],
        );
      },
    );
  }

void _deleteCountry(String docId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف بيانات هذا البلد؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              _firestoreService.deleteCountry(docId); // Delete the country
              Navigator.pop(context); // Close the dialog
              Get.snackbar('تم الحذف', 'تم حذف البلد بنجاح',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.green)),
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
        title: const Text('البلدان'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getCountries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final countries = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              final data = country.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(top:38.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 200,
                    child: Image.network(data['image'])),
                  title: Text(data['name']),
                  subtitle: Text(data['nameEn']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   icon: const Icon(Icons.edit),
                      //   onPressed: () {
                      //     _openCountryDialog(
                      //       docId: country.id,
                      //       name: data['name'],
                      //       nameEn: data['nameEn'],
                      //       image: data['image'],
                      //     );
                      //   },
                      // ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteCountry(country.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {


          Get.to(const AddCountreyView());
        //  _openCountryDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}