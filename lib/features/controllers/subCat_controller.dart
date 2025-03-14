// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/model/subCat_model.dart';



class SubCatController extends GetxController{

List<SubCat>subCatList=[];

 Future<void> getSubCats(String cat) async {
    subCatList = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection
          ('sub_cat')
          .where('cat',isEqualTo: cat).get();
     subCatList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return SubCat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
       update();
      // ignore: avoid_print
      print("Cats loaded: ${subCatList.length}....found.");
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching ads: $e");
    }
  }


  Future<void> showDeleteConfirmationDialog(
    BuildContext context, String subCatName) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من الحذف؟"),
        actions: <Widget>[
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text("حذف"),
            onPressed: () {
              deleteSubCat(subCatName);
             // onDelete(); // Perform the delete action
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

  Future<void> deleteSubCat(String name) async {
  // Reference to the 'sub_cat' collection in Firestore
  CollectionReference subCatCollection = 
  FirebaseFirestore.instance.collection('sub_cat');
  try {
    // Search for the document with the matching 'name' field
    QuerySnapshot querySnapshot = 
    await subCatCollection.where('name', isEqualTo: name).get();
    // Iterate through the documents returned by the query
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Delete each document that matches the query
      await doc.reference.delete();
    }
    print("Document(s) with name '$name' deleted successfully.");
    Get.back();
    Get.snackbar('جيد','تم الحذف بنجاح',
    backgroundColor:Colors.green,
    snackPosition: SnackPosition.BOTTOM,
    colorText:Colors.white
    );

  } catch (e) {
    print("Error deleting document(s): $e");
  }
}



}