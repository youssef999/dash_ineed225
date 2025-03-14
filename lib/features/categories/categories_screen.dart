// ignore_for_file: depend_on_referenced_packages, library_prefixes, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:path/path.dart'
    as Path; // Ensure to import this for path manipulation
import 'package:uuid/uuid.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/categories/cat_market_text.dart';
import 'package:yemen_services_dashboard/features/categories/edit_cat.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';

import 'cat_model.dart';
import 'get_sub_cat.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _imageUrl;
  final _nameController = TextEditingController();
  TextEditingController coinsController = TextEditingController();
  TextEditingController nameEnController = TextEditingController();

  bool _isLoading = false;
  String? _uploadedFileURL;

  Future<void> imgFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Immediately set the image URL to display in the dialog
      setState(() {
        _imageUrl = pickedFile.path; // Set the picked image path
      });
      // Read the image as bytes for upload
      Uint8List imageData = await pickedFile.readAsBytes();
      // ignore: avoid_print
      print('picked');
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
    print(downloadUrl);
    return downloadUrl;
  }


String getRandomString(int length) {
  const characters = '0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ),
  );
}






  Future<int> getCollectionLength(String collectionPath) async {
    try {
      // Reference the collection
      CollectionReference collection = FirebaseFirestore.instance.collection(collectionPath);

      // Fetch all documents in the collection
      QuerySnapshot snapshot = await collection.get();
      setState(() {
        catLength=snapshot.docs.length;
      });
      getCategoryNums();
      // Return te number of documents
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting collection length: $e');
      return 0; // Return 0 if there's an error
    }
  }

  List<int>catNumList=[];

  int selectedItem=1;

  getCategoryNums(){
    catNumList=[];
    print("catLength=$catLength");
    for(int i=0;i<catLength;i++){
      catNumList.add(i);
    }
    catNumList.add(catLength);
    catNumList.add(catLength+1);
    setState((){
    });
    print("CAT LIST NUM==$catNumList");
  }


  Future<void> _addCategory() async {
    String numb=getRandomString(4);
    if (_uploadedFileURL == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اضافة الصورة واسم التصنيف')),
      );
      return;
    }

    // Check the number of existing categories
    final categoryCount =
        await FirebaseFirestore.instance.collection('cat').get();

    if (categoryCount.docs.length >= 230) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:
         Text('لا يمكن إضافة أكثر من 12 تصنيف')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Add category to Firestore
      await FirebaseFirestore.instance.collection('cat').add({
        'name': _nameController.text,
        'nameEn': nameEnController.text,
        'image': _uploadedFileURL,
       // 'coins':coinsController.text,
        'num':selectedItem
        //int.parse(numb)
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت اضافة التصنيف بنجاح')),
      );
      _nameController.clear();
      setState(() {
        _imageUrl = null; // Clear the image URL
        _uploadedFileURL = null; // Clear uploaded file URL
      });
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
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _deleteCategory(String docId, String imageUrl) async {
    // Show a confirmation dialog before deletion
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا التصنيف؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    // If the user confirmed, proceed with deletion
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('cat').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف التصنيف بنجاح')));
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحذف')));
      }
    }
  }

  Future<void> _showAddCategoryDialog() async {


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(16.0),
              content: SingleChildScrollView(
                child: Align(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('صورة القسم الجديد',
                            style: GoogleFonts.cairo(fontSize: 18)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          width: 200,
                          child: GestureDetector(
                            onTap: () async {
                              await imgFromGallery();
                              setState(
                                  () {}); // Call setState inside dialog to update the UI after image is picked
                            },
                            child: _imageUrl == null
                                ? Container(
                                    width: double.infinity,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image,
                                        color: Colors.grey[600]),
                                  )
                                : Image.network(
                              Uri.encodeFull(_imageUrl!),
                                  //  _imageUrl!, // Display selected image
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'اسم القسم',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ))),
                          style: GoogleFonts.cairo(),
                        ), const SizedBox(height: 20),
                        TextField(
                          controller: nameEnController,
                          decoration: const InputDecoration(
                              labelText: 'اسم القسم بالانجليزية ',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ))),
                          style: GoogleFonts.cairo(),
                        ),
                        const SizedBox(height: 20),
                    Center(
                      child: DropdownButton<int>(
                        value: selectedItem,
                        hint: const Text('ترتيب القسم '),
                        items: catNumList.map((int item) {
                          return DropdownMenuItem<int>(
                            value: item,
                            child: Text(item.toString()),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            selectedItem = value!;
                          });
                        },
                      )),
                        // TextField(
                        //   controller: coinsController,
                        //   decoration: const InputDecoration(
                        //       labelText: 'ترتيب القسم  ',
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(15.0),
                        //           ))),
                        //   style: GoogleFonts.cairo(),
                        // ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () async {
                                  await _addCategory();
                                  Navigator.pop(
                                      context); // Close dialog after adding
                                },
                                child:
                                    Text('اضافة', style: GoogleFonts.cairo()),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  int catLength=0;

  @override
  void initState() {
   getCollectionLength('cat');
    super.initState();
  }

  Future<void> addIndexToSubCatDocuments() async {
    print('ADD INDES SUBCATSS....');
    try {
      final firestore = FirebaseFirestore.instance;

      // Get all documents in the 'sub_cat' collection where 'cat' is an empty string
      final querySnapshot = await firestore
          .collection('sub_cat')
          .where('cat', isEqualTo: 'خدمات الموبايل و الكمبيوتر')
          .get();

      final documents = querySnapshot.docs;

      // Ensure the number of documents does not exceed the index range (1-9)
      // if (documents.length > 9) {
      //   throw Exception('More than 9 documents found. Index range exceeded.');
      // }

      // Loop through the documents and add an index
      for (int i = 0; i < documents.length; i++) {
        final doc = documents[i];
        final index = i + 1; // Index starts from 1

        // Update the document with the index
        await firestore.collection('sub_cat').doc(doc.id).update({
          'index': index,
        });

        print('Updated document ${doc.id} with index $index');
      }

      print('All documents updated successfully!');
    } catch (e) {
      print('An error occurred: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(child: Text('الأقسام', style: GoogleFonts.cairo()),
        onTap:(){
         // addIndexToSubCatDocuments();
        }
          ,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom
                      (backgroundColor: primaryColor),
                  onPressed: (){
                    getCollectionLength('cat');
                    _showAddCategoryDialog();

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('إضافة قسم جديد',
                    style: GoogleFonts.cairo(
                            color: Colors.white, fontSize: 18)),
                  ),
                ),

                 ElevatedButton(
                  style:
                      ElevatedButton.styleFrom
                      (backgroundColor: primaryColor),
                  onPressed: (){
                  Get.to(const CatMarkrtView());

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(' إضافة نص اعلاني للقسم ',
                    style: GoogleFonts.cairo(
                            color: Colors.white, fontSize: 18)),
                  ),
                ),


                //
              ],
            ),
            const SizedBox(height: 20),
            // Categories List
            _buildCategoriesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cat').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('لا توجد تصنيفات', style: GoogleFonts.cairo()));
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
             // _calculateCrossAxisCount(context),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,

              childAspectRatio: 1.0, // Adjust this based on your design needs
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var category = snapshot.data!.docs[index];
              return _buildCategoryCard(category);
            },
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 2; // 2 columns for small screens
    } else if (width < 900) {
      return 4; // 4 columns for medium screens
    } else {
      return 6; // 6 columns for large screens
    }
  }

  Widget _buildCategoryCard(QueryDocumentSnapshot category) {
    String docId = category.id;
    String name = category['name'];
    String imageUrl = category['image'];

    Cat cat = Cat.fromFirestore(category.data() as Map<String, dynamic>, docId);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a percentage of the available width for responsiveness
        double cardWidth = constraints.maxWidth * 0.4; // 40% of available width
        double imageHeight = cardWidth * 0.91; // Aspect ratio 2:3

        return InkWell(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: imageHeight, // Use calculated height
                        fit: BoxFit.cover, // Cover the area appropriately
                        errorWidget: (context, url, error) {
                     //     log(error.toString());
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                            fontSize: 14), // Adjusted for better readability
                        textAlign: TextAlign.center,
                      ),
                    ),

                    CustomButton(
                        width: 333,
                        text: 'عرض الاقسام الفرعية ', onPressed:(){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)
                        => GetSubCat(cat: name)),
                      );
                    } ),


                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteCategory(docId, imageUrl);
                      },
                    ), IconButton(
                      icon: const Icon(Icons.edit, color: Colors.red),
                      onPressed: () {
                        Get.to(EditCat(
                          cat: cat,
                        ));
                       // _deleteCategory(docId, imageUrl);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap:(){

        //  Get.toNamed('/next');
        //      Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context)
        //       => GetSubCat(cat: name)),
        //     );


            // Get.to(GetSubCat(
            //   cat: name
            // ));
          },
        );
      },
    );
  }
}
