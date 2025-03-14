



// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yemen_services_dashboard/main.dart';

import '../model/subCat_model.dart';
import 'cat_model.dart';

class CatController extends GetxController{

 String? uploadedFileURL;
 final ImagePicker picker = ImagePicker();
bool isImageUploading = false; 
List<XFile> images = [];
String? imageUrl;

TextEditingController nameController = TextEditingController();
TextEditingController nameEnController = TextEditingController();

  Future<void> pickMultipleImages() async {
   
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Immediately set the image URL to display in the dialog
     // setState(() {
        imageUrl = pickedFile.path; // Set the picked image path
     // });
      // Read the image as bytes for upload
      Uint8List imageData = await pickedFile.readAsBytes();
      // ignore: avoid_print
      print('picked');
      update();
      uploadImage(imageData);
    }
  }
   Future<String> uploadImage(Uint8List xfile) async {
    Reference ref = FirebaseStorage.instance.ref().child('Folder');
    String id = const Uuid().v1();
    ref = ref.child(id);

    UploadTask uploadTask = ref.putData(
      xfile,
      SettableMetadata(contentType: 'image/png'),
    );
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
   // setState(() {
      uploadedFileURL = downloadUrl;
      update();
   // });
    // ignore: avoid_print
    print(downloadUrl);
    print("upload image$uploadedFileURL");

    return downloadUrl;
  }

   Future<void> imgFromGallery() async {
    final pickedFile =
        await ImagePicker().
        pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
    //  setState(() {
        imageUrl = pickedFile.path; // Set the picked image path
        isImageUploading = true; // Set uploading status to true
       update();
      // Read the image as bytes for upload
      Uint8List imageData = await pickedFile.readAsBytes();
      print('picked');
      await uploadImage(imageData); // Await the image upload
    }
  }



  TextEditingController subCatNameController=TextEditingController();
  TextEditingController subCatNameEnController=TextEditingController();

  String selectedItem = 'خدمات الكمبيوتر';

   List<String>catListNames=[];

    changeCatValue(String val) {
    selectedItem = val;
    update();
    getCatItemLength(val);
  }


int catItemLength=0;
    List<int>subCatItemLength=[];

  int selectedSubIndex=1;

  changeSubIndex(int v){
    selectedSubIndex=v;
    update();
  }

 Future<int> getCatItemLength(String val) async {
    print("val=========-===================$val");
    subCatItemLength=[];
   try {
     // Query the 'cat' collection where the 'name' field matches the given value
     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
         .collection('sub_cat')
         .where('cat', isEqualTo: val)
         .get();
      catItemLength=querySnapshot.docs.length;

       if(catItemLength==0){
         print("EMPTY...");
         subCatItemLength.add(1);
       }else{
         for(int i=0;i<catItemLength;i++){
           subCatItemLength.add(i+1);
         }
         subCatItemLength.add(catItemLength+1);
       }
       print("SUBCATINDEXlist===$subCatItemLength");

      update();


     // Return the number of documents that match the query
     return querySnapshot.docs.length;
   } catch (e) {
     // Handle any errors (e.g., Firestore connection issues)
     print('Error fetching cat item length: $e');
     return 0; // Return 0 in case of an error
   }
 }

  List<Cat>catList=[];

  List<SubCat>subCatListTest=[];
  List<Cat>catListTest=[];

  Future<void> getCats() async {
    catListNames = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('cat').get();

      catList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Cat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      update();

      for (int i = 0; i < catList.length; i++) {
        catListNames.add(catList[i].name);
        update();
      }
      selectedItem = catList[0].name;
      update();
      // ignore: avoid_print
      print("Cats loaded: ${catList.length} ads found.");
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching ads: $e");
    }
  }





  List<int>subCatNum=[];
  List<int>catNum=[];

  int selectSubCatNum=1;
  int selectedCatNum=1;

 Future<void> getSubCatsLength(String cat,int index) async {
   subCatNum=[];
   try {
     QuerySnapshot querySnapshot =
     await FirebaseFirestore.instance.collection('sub_cat')
         .where('cat',isEqualTo: cat)
         .get();

     subCatListTest= querySnapshot.docs.map((DocumentSnapshot doc) {
       return SubCat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
     }).toList();
     update();

     for (int i = 0; i <=  subCatListTest.length; i++) {

       if(i==0){
         subCatNum.add(1);
       }else{
         subCatNum.add(i+1);
         // subCatNum.add(subCatListTest.length+2);
         // subCatNum.add(subCatListTest.length+3);
         // subCatNum.add(subCatListTest.length+4);
         // subCatNum.add(subCatListTest.length+5);
         // subCatNum.add(subCatListTest.length+6);
         // subCatNum.add(subCatListTest.length+7);
         // subCatNum.add(subCatListTest.length+8);
         // subCatNum.add(subCatListTest.length+9);
         // subCatNum.add(subCatListTest.length+10);
         // subCatNum.add(subCatListTest.length+11);
         // subCatNum.add(subCatListTest.length+12);
         // subCatNum.add(subCatListTest.length+13);
         // subCatNum.add(subCatListTest.length+14);
         // subCatNum.add(subCatListTest.length+15);
         // subCatNum.add(subCatListTest.length+16);
         // subCatNum.add(subCatListTest.length+17);
         // subCatNum.add(subCatListTest.length+18);
         // subCatNum.add(subCatListTest.length+19);
         // subCatNum.add(subCatListTest.length+20);
       }

      // update();
     }
     subCatNum.add(subCatListTest.length+2);
     subCatNum.add(subCatListTest.length+3);
     subCatNum.add(subCatListTest.length+4);
     subCatNum.add(subCatListTest.length+5);
     subCatNum.add(subCatListTest.length+6);
     subCatNum.add(subCatListTest.length+7);
     subCatNum.add(subCatListTest.length+8);
     subCatNum.add(subCatListTest.length+9);
     subCatNum.add(subCatListTest.length+10);
     subCatNum.add(subCatListTest.length+11);
     subCatNum.add(subCatListTest.length+12);
     subCatNum.add(subCatListTest.length+13);
     subCatNum.add(subCatListTest.length+14);
     subCatNum.add(subCatListTest.length+15);
     subCatNum.add(subCatListTest.length+16);
     subCatNum.add(subCatListTest.length+17);
     subCatNum.add(subCatListTest.length+18);
     subCatNum.add(subCatListTest.length+19);
     subCatNum.add(subCatListTest.length+20);
   //  selectSubCatNum =index;
     update();
     // ignore: avoid_print
     print("SUB CATS loaded: ${catList.length} ads found.");
   } catch (e) {
     // ignore: avoid_print
     print("Error fetching ads: $e");
   }
 }


 Future<void> getCatsLength(int index) async {
   print("GET CAT LENGTH===");
   catNum=[];
   try {
     QuerySnapshot querySnapshot =
     await FirebaseFirestore.instance.collection('cat')
         .get();

     catListTest= querySnapshot.docs.map((DocumentSnapshot doc) {
       return Cat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
     }).toList();
     update();

     for (int i = 0; i <=  catListTest.length; i++) {

       if(i==0){
         catNum.add(1);
       }else{
        catNum.add(i+1);
       }
       update();
     }
    selectedCatNum =index;
     update();
     // ignore: avoid_print
     print("CATS loaded: ${catNum.length} ads found.");
     print("CATS loaded:===== ${catListTest} ads found.");
     print("CATS loaded:====xx= ${catNum} ads found.");
   } catch (e) {
     // ignore: avoid_print
     print("Error fetching cats lewngth: $e");
   }
 }


 changeSelectsedNum(int val) {
   if(subCatNum.contains(val)){
     selectSubCatNum= val;
   }else{
     print("HEREEE...");
   }
   update();
 }

 changeCatNum(int val) {
   selectedCatNum = val;
   update();
 }


  passCatValue(String val) {
    selectedItem = val;
    update();
  }

 Future<void> updateSubCategoryDocument(String name, Map<String, dynamic> newData) async {

    print("NEW DATA==$newData");
   try {
     // Reference to the Firestore collection
     CollectionReference subCatCollection = FirebaseFirestore.instance.collection('sub_cat');

     // Query to find the document where the "name" field matches the provided name
     QuerySnapshot querySnapshot = await subCatCollection.where('name', isEqualTo: name).get();

     // Check if the document exists
     if (querySnapshot.docs.isNotEmpty) {
       // Get the document ID and update it
       String docId = querySnapshot.docs.first.id;
       await subCatCollection.doc(docId).update(newData);

       print('Document updated successfully!');
       Get.offAll(const Dashboard());
       Get.snackbar('', 'تم تعديل القسم بنجاح',
       colorText:Colors.white,
         backgroundColor: Colors.green
       );
     } else {
       print('No document found with the name: $name');
     }
   } catch (e) {
     print('Failed to update document: $e');
   }
 }


 Future<void> updateCat(String name, Map<String, dynamic> newData) async {

   print("NEW DATA==$newData");
   try {
     // Reference to the Firestore collection
     CollectionReference subCatCollection = FirebaseFirestore.instance.collection('cat');

     // Query to find the document where the "name" field matches the provided name
     QuerySnapshot querySnapshot = await subCatCollection.where('name', isEqualTo: name).get();

     // Check if the document exists
     if (querySnapshot.docs.isNotEmpty) {
       // Get the document ID and update it
       String docId = querySnapshot.docs.first.id;
       await subCatCollection.doc(docId).update(newData);

       print('Document updated successfully!');
       Get.offAll(const Dashboard());
       Get.snackbar('', 'تم تعديل القسم بنجاح',
           colorText:Colors.white,
           backgroundColor: Colors.green
       );
     } else {
       print('No document found with the name: $name');
     }
   } catch (e) {
     print('Failed to update document: $e');
   }
 }

   bool isLoading = false;
  Future<void> addSubCategory(BuildContext context) async {
    
    if (uploadedFileURL == null || subCatNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: 
        Text('يرجى اضافة الصورة واسم التصنيف')),
      );
      return;
    }
    // Check the number of existing categories
    final categoryCount =
        await FirebaseFirestore.instance.collection('sub_cat').get();

    if (categoryCount.docs.length >= 230) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:
         Text('لا يمكن إضافة أكثر من 12 تصنيف')),
      );
      return;
    }

    //setState(() {
      isLoading = true; // Show loading indicator
      update();
    //});

    try {
      // Add category to Firestore
      await FirebaseFirestore.instance.collection('sub_cat').add({
        'name': subCatNameController.text,
        'nameEn': subCatNameEnController.text,
        'image': uploadedFileURL,
        'cat':selectedItem,
        'index':selectSubCatNum
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت اضافة التصنيف بنجاح')),
      );
      Get.offAll(const Dashboard());
      subCatNameController.clear();
      subCatNameEnController.clear();
      // selectedItem='';
        imageUrl = null; // Clear the image URL
        uploadedFileURL = null; // Clear uploaded file URL
        update();
    } catch (error) {
      if (error is FirebaseException) {
        // ignore: avoid_print
        print('Firebase Error: ${error.message}');
      } else {
        // ignore: avoid_print
        print('Error: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ ما')),
      );
    } finally {

        isLoading = false;
        update(); // Hide loading indicator
    }
  }


}