

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/controller/offers_controller.dart';
import '../../main.dart';
import 'get_offers_view.dart';
import 'model/ads_model.dart';
import 'offers_screen.dart';

class EditAdView extends StatefulWidget {
  final Ad ad;

  const EditAdView({super.key, required this.ad});

  @override
  State<EditAdView> createState() => _EditAdViewState();
}

class _EditAdViewState extends State<EditAdView> {
  final titleController = TextEditingController();
  final desController = TextEditingController();
  String? _imageUrl;
  String? _uploadedFileURL;
  String? selectedCat;
  String? selectedSubCat;
  String? selectedDays;
 String? _selectedServiceProviderEmail;
  AdController controller = Get.put(AdController());
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {

    controller.getCats(0);
    controller.getAdsData();
    super.initState();
    _selectedServiceProviderEmail=widget.ad.email;
    titleController.text = widget.ad.title;
    desController.text = widget.ad.des;
    _imageUrl = widget.ad.imageUrl;
    selectedDays = widget.ad.time;
    controller.firstCatAndSubCatValue(widget.ad.cat,widget.ad.subCat,
    widget.ad.price,widget.ad.time
    );

  print("cooooo====${controller.selectedCat}");
  print("cooooo====${controller.selectedSubCat}");
  }

  Future<List<QueryDocumentSnapshot>> _fetchServiceProviders() async {
    final querySnapshot = await _firestore.collection('serviceProviders').get();
    return querySnapshot.docs;
  }


  Future<void> imgFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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

  // void saveAd() {
  //   if (_uploadedFileURL != null) {
  //     widget.ad.imageUrl = _uploadedFileURL!;
  //   }
  //   widget.ad.title = titleController.text;
  //   widget.ad.des = desController.text;
  //   widget.ad.cat = controller.selectedCat ?? widget.ad.cat;
  //   widget.ad.subCat = controller.selectedSubCat ?? widget.ad.subCat;
  //   widget.ad.time = selectedDays ?? widget.ad.time;
  //
  //   // Update Firestore data here using widget.ad
  //   // Example:
  //   // FirebaseFirestore.instance.collection('ads').doc(widget.ad.id).update(widget.ad.toMap());
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('تم تعديل الاعلان بنجاح ')),
  //   );
  // }


  bool isLoading=false;


  void saveAd() {

    //print("ADD=="+w)
    print("......SAVE.......ADDDDD.....");

    setState(() {
       isLoading=true;
    });
    


    Future.delayed(const Duration(seconds: 5), () {


 setState(() {
       isLoading=false;
    });
    
       print("IMAGE===${_uploadedFileURL.toString()}");
    // Update the widget.ad fields)
    // Update the widget.ad fields
    if (_uploadedFileURL != null) {
      _uploadedFileURL = widget.ad.imageUrl ;
    }

 widget.ad.title= titleController.text    ;
 widget.ad.des = desController.text;
 widget.ad.cat= controller.selectedCat  ;
 widget.ad.subCat= controller.selectedSubCat ;
 widget.ad.time=selectedDays.toString();

    // Add price update if applicable (ensure the price field exists in the Ad model)
    //widget.ad.price = priceController.text;

    // Prepare the data to update
   Map<String,dynamic> updatedData={};

    if( _uploadedFileURL!=null){
    updatedData = {
        'imageUrl':  _uploadedFileURL.toString(),
         'email':  _selectedServiceProviderEmail,
        'image':  _uploadedFileURL.toString(),
        //widget.ad.imageUrl,
        'title': widget.ad.title,
        'des': widget.ad.des,
        'cat':widget.ad.cat,
        'subCat':widget.ad.subCat,
      'sub_cat':widget.ad.subCat,
        'time': widget.ad.time,
        'price': controller.price.toString(),
      };
    }else{
      updatedData = {
        //widget.ad.imageUrl,
        'title': widget.ad.title,
          'email': _selectedServiceProviderEmail,
        'des': widget.ad.des,
        'cat':widget.ad.cat,
        'subCat':widget.ad.subCat,
        'sub_cat':widget.ad.subCat,
        'time': widget.ad.time,
        'price': controller.price.toString(),
      };
    }
   print("DATA===$updatedData");
    // Update Firestore data
    FirebaseFirestore.instance
        .collection('ads')
        .doc(widget.ad.id) // Use the ad ID to locate the document
        .update(updatedData)
        .then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor:Colors.green,
          content: Text('تم تعديل الاعلان بنجاح',
          style:TextStyle(color:Colors.white),
          ),
        ),
      );
      Get.offAll(const Dashboard());
    })
        .catchError((error) {
          print("ERRORR===="+error.toString());
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تعديل الإعلان: $error')),
      );
    });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الاعلان  ', style: TextStyle(color: Colors.white)),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<AdController>(
          builder: (_) {
            return ListView(
              children: [
                const SizedBox(height: 16),
                Text('صورة الاعلان ', style: GoogleFonts.cairo(fontSize: 18)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: imgFromGallery,
                  child: _imageUrl == null
                      ? Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        )
                      : Image.network(
                          _imageUrl!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الاعلان ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _fetchServiceProviders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('لا يوجد مزودي خدمات متاحين');
                  }
                  final serviceProviders = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _selectedServiceProviderEmail,
                    decoration: const InputDecoration(
                      helperMaxLines: 8,
                      labelText: 'اختر مقدم الخدمة',
                      border: OutlineInputBorder(),
                    ),
                    items: serviceProviders.map((provider) {
                      final data = provider.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: data['email'],
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(data['image']),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['name']),
                                //     Text(data['email'], style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedServiceProviderEmail = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء اختيار مقدم الخدمة';
                      }
                      return null;
                    },
                  );
                },
              ),
                const SizedBox(height: 21),
                TextField(
                  controller: desController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'وصف الاعلان  ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 21),



                Row(
                  children: [
                    Text(
                      'القسم الاساسي'.tr,
                      style: TextStyle(
                          color:secondaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                   const SizedBox(width: 14,),
                    Container(
                      decoration:BoxDecoration(
                        borderRadius:BorderRadius.circular(18),
                        color:Colors.grey[200],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(21.0),
                        child: Row(
                          mainAxisAlignment:MainAxisAlignment.center,
                          children:[
                            const Text("القسم المختار "),
                            const SizedBox(width: 22,),
                            Text(widget.ad.cat.replaceAll('main', 'الرئيسية'),
                              style:const TextStyle(color:Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),

                          ],),
                      ),
                    ),
                  ],
                ),




                const SizedBox(
                  height: 13,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.83,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Colors.white),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    value: controller.selectedCat,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.changeCatValue(newValue);
                      }
                    },
                    items: controller.catListNames
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            style: GoogleFonts.cairo(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Text(
                      'القسم الفرعي '.tr,
                      style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                   const SizedBox(width: 12,),
                    Container(
                      decoration:BoxDecoration(
                        borderRadius:BorderRadius.circular(18),
                        color:Colors.grey[200],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(21.0),
                        child: Row(
                          mainAxisAlignment:MainAxisAlignment.center,
                          children:[
                            const Text("القسم المختار "),
                            const SizedBox(width: 22,),
                            Text(widget.ad.subCat.replaceAll('main', 'الرئيسية'),
                              style:const TextStyle(color:Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),

                          ],),
                      ),
                    ),
                  ],
                ),


                const SizedBox(
                  height: 10,
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.83,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Colors.white),
                  child: DropdownButton<String>(
                    underline: const SizedBox.shrink(),
                    isExpanded: true,
                    value: controller.selectedSubCat,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.changeSubCatValue(newValue);
                      }
                    },
                    items: controller.subCatListNames
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            style: GoogleFonts.cairo(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 18),



                Row(
                  children: [
                    Text(
                      'مدة الاعلان'.tr,
                      style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12,),

                    Text(widget.ad.time,
                    style:const TextStyle(color:Colors.grey,fontSize: 22,fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.83,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Colors.white),
                  child: DropdownButton<String>(
                    underline: const SizedBox.shrink(),
                    isExpanded: true,
                    value: controller.selectedDays,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.changeDayListValue(newValue);
                      }
                    },
                    items: controller.daysList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            style: GoogleFonts.cairo(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text('السعر المدفع مسبقا'+"  =  "+widget.ad.price
                      +" "+'DA',
                    style:TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16
                    ),
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                Center(
                  child: Text('السعر'+"  =  "+controller.price
                      +" "+'DA',
                    style:TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),


                const SizedBox(height: 16),

                const SizedBox(height: 16),

                (isLoading==false)?
                ElevatedButton(
                  onPressed: saveAd,
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  child: const Text('حفظ التعديلات ',

                  style:TextStyle(color:Colors.white),),
                ):const Center(
                  child: CircularProgressIndicator()
                ),
                const SizedBox(height: 26),
              ],
            );
          }
        ),
      ),
    );
  }
}