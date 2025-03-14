import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/categories/image_widget.dart';
import '../categories/cat_controller.dart';
import '../offers/cutom_button.dart';

class AddCountreyView extends StatefulWidget {
  const AddCountreyView({super.key});

  @override
  State<AddCountreyView> createState() => _AddCountreyViewState();
}

class _AddCountreyViewState extends State<AddCountreyView> {
  final CollectionReference countriesCollection =
      FirebaseFirestore.instance.collection('country');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final CatController _catController = Get.put(CatController());
  bool isLoading=false;
  Future<void> addCountry(String name, String nameEn) async {

    Future.delayed(const Duration(seconds: 4)).then((value) async {
       try {
      await countriesCollection.add({
        'name': name,
        'nameEn': nameEn,
        'image': _catController.uploadedFileURL.toString(),
      });
      Get.snackbar('تم اضافة البلد بنجاح', '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      _nameController.clear();
      _nameEnController.clear();
      _catController.uploadedFileURL = '';

         setState(() {
                        isLoading=false;
                      });
                  
    } catch (e) {
      Get.snackbar('حاول مرة اخري', ':حدث خطا الرجاء المحاولة $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
    });
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'إضافة بلد',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 13),
        child: ListView(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageWidget(txt: ''),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم باللغة الإنجليزية',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                (isLoading==false)?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 218.0),
                  child: CustomButton(
                    color1: primaryColor,
                    onPressed: () async {

                      setState(() {
                        isLoading=true;
                      });
                      if (_nameController.text.isEmpty ||
                          _nameEnController.text.isEmpty ||
                          _catController.uploadedFileURL!.isEmpty) {
                        Get.snackbar('خطا', 'قم برفع الصورة',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      await addCountry(
                          _nameController.text, _nameEnController.text);
                    },
                    text: 'إضافة',
                  ),
                ):const Center(child: const CircularProgressIndicator(color: primaryColor,),)
              ],
            ),
          ],
        ),
      ),
    );
  }
}