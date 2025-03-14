


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yemen_services_dashboard/features/model/subCat_model.dart';
import 'package:yemen_services_dashboard/features/offers/model/prov.dart';
import 'package:yemen_services_dashboard/main.dart';

import '../../categories/cat_model.dart';
import '../../statistics/user.dart';
import '../model/ads_model.dart';

class AdController2 extends GetxController{


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
  String selectedDays = 'month'.tr;
  String selectedOption = 'الصفحة الرئيسية';
  String price='500';

  List<String> daysList = ['شهر', '3 شهور', '6 شهور', 'سنة'];
  List<String> priceList = ['500', '1200', '2200', '3000'];
  List<String> optionList =
  ['الصفحة الرئيسية', 'اعلي صفحة الاقسام', 'مقدمي خدمة متميزين اعلي البحث'];

  DateTime   startDate = DateTime.now();
  DateTime ?endDate=DateTime.now();

  List<Ad> adsList = [];
  List<WorkerProvider> workerList = [];

  changeOptionSelected(String val){
    selectedOption=val;
    update();
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
    print("aadsss=="+adsList.length.toString());

  }


  getWorkerWithEmail(String email)async{
    print("....HERE ....WORKERSS......");
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance
          .collection('serviceProviders')
          .where('email', isEqualTo: email)
          .get();
      workerList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return WorkerProvider.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      update();
    } catch (e) {
      print("Error fetching ads: $e");
    }
    print("aadsss=="+adsList.length.toString());
  }

  //
  // changeDayListValue(String value){
  //   selectedDays=value;
  //   if(value=='شهر'){
  //     price='500';
  //       endDate = startDate.add(const Duration(days: 30));
  //   }
  //   if(value=='3 شهور'){
  //     price='1200';
  //     endDate = startDate.add(const Duration(days: 120));
  //   }
  //   if(value=='6 شهور'){
  //     price='2200';
  //     endDate = startDate.add(const Duration(days: 180));
  //   }
  //   if(value=='سنة'){
  //     price='3000';
  //     endDate = startDate.add(const Duration(days: 365));
  //   }
  //   print("END DATE====="+endDate.toString());
  //   update();
  // }

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

      print("Subcat==XXX=" + subCatList.length.toString());
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

  Future<void> getCats() async {
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


  changeSubCatValue(String subCat) {
    selectedSubCat = subCat;
    update();
  }

  List<User>userDataList = [];

  getUserData() async {
    final box = GetStorage();
    String email = box.read('email');
    try {
      print("GET TASKS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      userDataList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      update();
      print("Tasks loaded: ${userDataList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
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

  Future uploadMultiImageToFirebaseStorage(List<XFile> images) async {
    print("UPLOAD IMAGES....");
    print("UPLOAD IMAGES======" + images.length.toString());
    for (int i = 0; i < images.length; i++) {
      print("HERE==" + i.toString());
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
      print("DOWNLOAD URLS====" + downloadUrls.length.toString());
      print("DOWNLOAD URLS====" + downloadUrls.toString());
    }
    return downloadUrls;
  }

  bool isLoading=false;

  Future<void> addNewAdToFirestore(BuildContext context)
  async {
    isLoading=true;
    update();
    uploadMultiImageToFirebaseStorage(images).then((v) {
      Future.delayed(const Duration(seconds: 1), () async {
        final box=GetStorage();
        String email=box.read('email')??'';
        // Generate a new document ID
        String Id =
            FirebaseFirestore.instance.collection('ads').doc().id;
        Map<String, dynamic> data = {
          "id": Id,
          "image": downloadUrls[0],
          "cat": selectedCat,
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

            Get.snackbar('تم اضافة الاعلان بنجاح ', '');


            isLoading=false;
            Get.offAll( const Dashboard ());
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
    });
  }



}












