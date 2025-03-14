
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/controller/offers_controller.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';
import 'ad_price.dart';
import 'add_ad2.dart';
import 'get_offers_view.dart';

class AddAdView extends StatefulWidget {
  const AddAdView({super.key});

  @override
  State<AddAdView> createState() => _AddAdViewState();
}

class _AddAdViewState extends State<AddAdView> {
  AdController controller = Get.put(AdController());
  String? _imageUrl;
  String? _uploadedFileURL;
  List<Map<String, dynamic>> serviceProviders = [];
  List<Map<String, dynamic>> filteredProviders = [];
  String? selectedProviderEmail;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.getCats(0);
    controller.getAdsData();
    fetchServiceProviders();
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

  void filterProviders(String query) {
    setState(() {
      filteredProviders = serviceProviders
          .where((provider) =>
          provider['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> imgFromGallery() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageUrl = pickedFile.path;
      });
      Uint8List imageData = await pickedFile.readAsBytes();
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
    setState(() {
      _uploadedFileURL = downloadUrl;
    });
    return downloadUrl;
  }

  Future<void> addCountryToAds() async {
    try {
      // Reference Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get all documents in the 'ads' collection
      QuerySnapshot snapshot = await firestore.collection('ads').get();

      // Loop through each document and update the 'country' field
      for (var doc in snapshot.docs) {
        await doc.reference.update({"country": "مصر"});
      }

      print("Country added to all documents in 'ads' collection successfully.");
    } catch (e) {
      print("Failed to add country to ads: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text(
              'إعلانات',
              style: TextStyle(color: Colors.white, fontSize: 21),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(11.0),
            child:

            ListView(
              children: [
                const SizedBox(height: 32),
                CustomButton(
                  color1: primaryColor,
                  text: 'عرض الإعلانات المتاحة',
                  onPressed: () => Get.to(const GetOffersView()),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  color1: primaryColor,
                  text: 'تعديل أسعار الإعلانات',
                  onPressed: () => Get.to(const AdPriceView()),
                ),
              //  const Divider(color: Colors.grey),
                const SizedBox(height: 32),
                CustomButton(
                  color1: primaryColor,
                  text:    'إضافة إعلان جديد',
                  onPressed: () =>

                  Get.to( AddAdScreen3()),
                ),

                // InkWell(
                //   child: const Center(
                //     child: Text(
                //       'إضافة إعلان جديد',
                //       style: TextStyle(color: primaryColor, fontSize: 22),
                //     ),
                //   ),
                //   onTap:(){
                //
                //     Get.to( AddAdScreen3());
                //    // Get.to(const AddAdView2());
                //   },
                // ),
                // const SizedBox(height: 12),
                // Text(
                //   'صورة الإعلان',
                //   style: GoogleFonts.cairo(fontSize: 18),
                // ),
                // const SizedBox(height: 10),
                // SizedBox(
                //   height: 150,
                //   width: 200,
                //   child: GestureDetector(
                //     onTap: () async {
                //       await imgFromGallery();
                //       setState(() {});
                //     },
                //     child: _imageUrl == null
                //         ? Container(
                //       width: double.infinity,
                //       height: 180,
                //       color: Colors.grey[300],
                //       child: Icon(Icons.image, color: Colors.grey[600]),
                //     )
                //         : Image.network(
                //       _imageUrl!,
                //       width: double.infinity,
                //       height: 430,
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),
                // Text(
                //   'اختر مقدم الخدمة',
                //   style: TextStyle(
                //     color: secondaryTextColor,
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 10),
                //
                //
                // Container(
                //   // height: 150,
                //   // width: 333,
                //   child: DropdownButton<String>(
                //
                //    isExpanded: true,
                //     value: selectedProviderEmail,
                //     onChanged: (value) {
                //       setState(() {
                //         selectedProviderEmail = value;
                //       });
                //     },
                //     items: filteredProviders.map((provider) {
                //       return DropdownMenuItem<String>(
                //         value: provider['email'],
                //         child: Column(children: [
                //           Row(
                //             children: [
                //             SizedBox(
                //                 width: 200,
                //                 child: Text(provider['name'])),
                //               CircleAvatar(
                //                 radius: 15,
                //                 backgroundImage:NetworkImage(provider['image']),
                //               ),
                //               const SizedBox(width: 12,),
                //               Text(provider['email'],style:const TextStyle(
                //                   color:Colors.grey,fontSize: 15,fontWeight:FontWeight.w500
                //               ),),
                //             ],
                //           ),
                //        //  const SizedBox(height: ,),
                //
                //          // const SizedBox(height: 10,),
                //       //    const Divider()
                //         ],)
                //
                //        // Text(provider['name']),
                //       );
                //     }).toList(),
                //   ),
                // ),
                // const SizedBox(height: 16),
                //
                //
                //
                // CustomButton(
                //   color1: primaryColor,
                //   text: 'اضف',
                //   onPressed: () async {
                //     if (selectedProviderEmail != null) {
                //       await controller.addNewAdToFirestore(
                //         context,
                //         _uploadedFileURL!,
                //         selectedProviderEmail!,
                //       );
                //       Get.snackbar('', 'تم إضافة الإعلان بنجاح',
                //           backgroundColor: Colors.green,
                //           colorText: Colors.white);
                //     } else {
                //       Get.snackbar('', 'يرجى اختيار مقدم خدمة',
                //           backgroundColor: Colors.red, colorText: Colors.white);
                //     }
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

