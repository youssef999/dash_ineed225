
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yemen_services_dashboard/features/categories/cat_model.dart';
import 'package:yemen_services_dashboard/features/model/subCat_model.dart';
import 'package:yemen_services_dashboard/features/offers/model/ads_model.dart';
import 'package:yemen_services_dashboard/main.dart';

class AdController extends GetxController {


  final ImagePicker picker = ImagePicker();

  List<XFile> images = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();

  List<String> downloadUrls = [];
  String downloadUrl = '';
  List<Cat> catList = [];
  List<SubCat> subCatList = [];
  List<String> catListNames = [];
  List<String> subCatListNames = [];
  String selectedCat = 'خدمات الصيانة';
  String selectedSubCat = 'فني طابعات و احبار';
  String selectedDays = 'شهر';

  String price='500';

  List<String> daysList = ['شهر', '3 شهور', '6 شهور', 'سنة'];
  List<String> priceList = ['500', '1200', '2200', '3000'];

  DateTime   startDate = DateTime.now();

  DateTime ?endDate=DateTime.now();

  List<Ad> adsList = [];
  //List<WorkerProvider> workerList = [];

  String providerName = '';
  Future<String?> getProviderNameByEmail(String email) async {
    try {
      // Query the Firestore collection to find the provider by email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('serviceProviders')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Check if any document is found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the 'name' field from the first matching document
       providerName = querySnapshot.docs.first['name'] ?? 'اسم غير متوفر';
       update();
        return providerName;
      } else {
        // If no provider is found, return null
        return null;
      }
    } catch (e) {
      // Handle errors (e.g., Firestore access issues)
      print('Error fetching provider name: $e');
      return null;
    }

  }
Future<void> deleteAdById(String id) async {
  try {
    // Reference to Firestore
    final firestore = FirebaseFirestore.instance;
    // Delete the document in the "ads" collection where id matches the given id
    await firestore.collection('ads').doc(id).delete();

    print('Document with id $id deleted successfully.');
    Get.snackbar('', 'تم الحذف بنجاح',
    backgroundColor:Colors.green,
    colorText:Colors.white
    );
    Get.offAll(const Dashboard());
  } catch (e) {
    print('Error deleting document: $e');
  }
}

 Future<void> getAds() async {
    try {
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('ads').get();
      // Map each document to an Ad instance and add to adsList
      adsList = querySnapshot.docs.map((DocumentSnapshot doc) {
        // Convert the document data to the Ad model using fromFirestore
        return Ad.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      update(); // Call update() if using a state management solution like GetX
      // Optional: Print the list for debugging
      print("Ads loaded: ${adsList.length} ads found.");
    } catch (e) {
      // Handle any errors
      print("Error fetching ads: $e");
    }
  }

  getWorkerAds()async{
    print("HERE ADS...");
    final box=GetStorage();
    String email=box.read('email');
    try {
        QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('ads')
            .where('email', isEqualTo: email)
            .get();
        adsList = querySnapshot.docs.map((DocumentSnapshot doc) {
          return Ad.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        update();
    } catch (e) {
      print("Error fetching ads: $e");
    }
    print("aadsss==${adsList.length}");

  }



final box=GetStorage();

  List<Map<String,dynamic>>adsDataList=[];

  getAdsData() async {

     daysList = [];
    priceList = [];
    try {
      print("GET ADS DATA.....");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('adsPrice')
          .get();
      adsDataList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      for(int i=0;i<adsDataList.length;i++){

        String loc=box.read('locale')??'ar';
        if(loc=='ar'){
          daysList.add(adsDataList[i]['timeAr']);
        }else{
          daysList.add(adsDataList[i]['time']);
        }
         priceList.add(adsDataList[i]['price'].toString());
      }
      selectedDays = daysList[1];
      price = priceList[1];
      /*
        List<String> daysList = ['شهر', '3 شهور', '6 شهور', 'سنة'];
  List<String> priceList = ['500', '1200', '2200', '3000'];
       */

      update();
      print("Tasks loaded: ${adsDataList.length} Tasks found.");
      print("days loaded: ${daysList.length} Tasks found.");
      print("price loaded: ${price.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }

  getAdPrice(String id) async {

    daysList = [];
    priceList = [];
    try {
      print("GET ADS DATA.....");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('adsPrice')
          .get();
      adsDataList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      for(int i=0;i<adsDataList.length;i++){

        String loc=box.read('locale')??'ar';
        if(loc=='ar'){
          daysList.add(adsDataList[i]['timeAr']);
        }else{
          daysList.add(adsDataList[i]['time']);
        }
        priceList.add(adsDataList[i]['price'].toString());
      }
      selectedDays = daysList[1];
      price = priceList[1];
      /*
        List<String> daysList = ['شهر', '3 شهور', '6 شهور', 'سنة'];
  List<String> priceList = ['500', '1200', '2200', '3000'];
       */

      update();
      print("Tasks loaded: ${adsDataList.length} Tasks found.");
      print("days loaded: ${daysList.length} Tasks found.");
      print("price loaded: ${price.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }



  firstCatAndSubCatValue(
      String cat,String subCat,String price,String days
      )async{
    selectedCat=cat;
    selectedSubCat=subCat;
    selectedDays=days;
    price=price;
    update();
  }

    Future<void> changeDayListValue(String value) async {
    try {
      // Set the selectedDays value
      selectedDays = value;

      String loc=box.read('locale')??'ar';

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('adsPrice')
          .where('time', isEqualTo: value)
          .get();

      if(loc=='ar'){
        querySnapshot = await FirebaseFirestore.instance
            .collection('adsPrice')
            .where('timeAr', isEqualTo: value)
            .get();
      }else{
        querySnapshot = await FirebaseFirestore.instance
            .collection('adsPrice')
            .where('time', isEqualTo: value)
            .get();
      }
      // Query Firestore for the price where the time matches the given value


      if (querySnapshot.docs.isNotEmpty) {
        // Extract the price from the first document
        var docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        price = docData['price'].toString();

        // Calculate the end date based on the time period
        int days = docData['days'] ?? 0; // Ensure the days field exists in the document
        endDate = startDate.add(Duration(days: days));
      } else {
        print("No price found for the given time: $value");
      }

      print("END DATE=====$endDate");
      print("END porice=====$price");
      update();
    } catch (e) {
      print("Error fetching price from Firestore: $e");
    }
  }



  Future<void> getSubCats(String cat) async {
    subCatList = [];
    subCatListNames = [];
    print("HERE CATS......");
    try {
      if (cat.length > 1) {
        QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('sub_cat')
            .where('cat', isEqualTo: cat)
            .get();
        subCatList = querySnapshot.docs.map((DocumentSnapshot doc) {
          return SubCat.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        selectedSubCat = subCatList[0].name;
        update();
      } else {
        QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('sub_cat').get();
        subCatList = querySnapshot.docs.map((DocumentSnapshot doc) {
          return SubCat.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      }

      print("Subcat==XXX=${subCatList.length}");
      for (int i = 0; i < subCatList.length; i++) {
        subCatListNames.add(subCatList[i].name);
      }
      selectedSubCat = subCatListNames[0];
      update();
      print("sub Cat loaded: ${catList.length}.");
      print("sub Cat loaded: ${subCatListNames}.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }

  Future<void> pickMultipleImages() async {
    List<XFile>? selectedImages = [];
    images.clear();
    //while (true) {
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImages.add(pickedFile);
    } else {
      //break; // Break the loop if no image is selected
    }
    // }
    if (selectedImages.isNotEmpty) {
      images.addAll(selectedImages); // Add selected images to the list
    }
    update();
  }

  changeCatValue(String cat) {
    selectedCat = cat;
    update();
    getSubCats(cat);
  }

  Future<void> getCats(int index) async {

  if(index==0){
    catList = [];
    catListNames = [];
    print("....xxxx....HERE CATS.......xxx...");
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('cat').get();
      catList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Cat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      for (int i = 0; i < catList.length; i++) {
        catListNames.add(catList[i].name);
      }
      selectedCat = catList[0].name;
      update();
      catListNames.add('الرئيسية');
      getSubCats(selectedCat);
      print("Cats loaded: ${catList.length}.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }else{
    catList = [];
    catListNames = [];
    print("....xxxx....HERE CATS.......xxx...");
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('cat').get();
      catList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Cat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      for (int i = 0; i < catList.length; i++) {
        catListNames.add(catList[i].name);
      }
      selectedCat = catList[0].name;
      update();
      getSubCats(selectedCat);
      print("Cats loaded: ${catList.length}.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }

  }


  changeSubCatValue(String subCat) {
    selectedSubCat = subCat;
    update();
  }



  Future uploadMultiImageToFirebaseStorage(List<XFile> images) async {
    print("UPLOAD IMAGES....");
    print("UPLOAD IMAGES======${images.length}");
    for (int i = 0; i < images.length; i++) {
      print("HERE==$i");
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference =
        FirebaseStorage.instance.ref().child('imagesAds/$fileName');
        UploadTask uploadTask = reference.putFile(File(images[i].path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        // Handle any errors that occur during the upload process
        // ignore: avoid_print
        print('Error uploading image to Firebase Storage: $e');
      }
      print("DOWNLOAD URLS====${downloadUrls.length}");
      print("DOWNLOAD URLS====$downloadUrls");
    }
    return downloadUrls;
  }

  bool isLoading=false;

  Future<void> addNewAdToFirestore(BuildContext context,String image,String email)
  async {

    String sCat='';
    if(selectedCat=='الرئيسية'){
      sCat='main';
    }else{
      sCat=selectedCat;
    }
    isLoading=true;
    update();
     // uploadMultiImageToFirebaseStorage(images).then((v) {
        Future.delayed(const Duration(seconds: 1), () async {
          // final box=GetStorage();
          // String email=box.read('email')??'admin@gmail.com';
            // Generate a new document ID
            String Id =
                FirebaseFirestore.instance.collection('ads').doc().id;
            Map<String, dynamic> data = {
              "id": Id,
             'image': image,
             // downloadUrls[0],
              "cat": sCat,
              'title': titleController.text,
              'time':selectedDays,
               'price':price,
              'des': desController.text,
              "sub_cat": selectedSubCat,
              'email':email,
              "current_date":startDate,
              'end_date':endDate,
              //"image": images,
            };
            try {
              // Create a reference with the generated document ID
              CollectionReference collection =
              FirebaseFirestore.instance.collection('ads');
              await collection.doc(Id).set(data).then((value) {

                Get.snackbar('', 'تم اضافة اعلانك بنجاح');
               

                isLoading=false;

                Get.back();

                //Get.offAll( MainHome());
                titleController.clear();
                desController.clear();
                images.clear();
                update();
              });
              print("Data added successfully!");
            } catch (e) {
              print("Error adding data: $e");
            }
          }
        );
     // });
    }

  Future<void> updateAdData(String adId,BuildContext context) async {

    isLoading=true;
    update();
     if(images.isNotEmpty){
       try {
         uploadMultiImageToFirebaseStorage(images).then((v) async {
           await FirebaseFirestore.instance.collection
             ('ads').doc(adId).update({
             'title':titleController.text,
             'des':desController.text,
             'image':downloadUrls[0]
           });
           print("Ad data updated successfully.");
            Get.snackbar('', 'تم تعديل اعلانك بنجاح');
          isLoading=false;
          update();
         });

       } catch (e) {
         print("Failed to update ad data: $e");
       }
     }else{



       try {
           await FirebaseFirestore.instance.collection
             ('ads').doc(adId).update({
             'title':titleController.text,
             'des':desController.text,
           });
           print("Ad data updated successfully.");
            print("Ad data updated successfully.");
            Get.snackbar('', 'تم تعديل اعلانك بنجاح');
            
           isLoading=false;
          Get.back();
           update();

       } catch (e) {
         print("Failed to update ad data: $e");
       }

     }

  }

    }












