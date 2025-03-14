
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/categories/cat_controller.dart';

class FirestoreService {
  final CollectionReference countriesCollection =
      FirebaseFirestore.instance.collection('country');

  // Get all countries
  Stream<QuerySnapshot> getCountries() {
    return countriesCollection.snapshots();
  }

  // Add a new country
  Future<void> addCountry(String name, String nameEn, String imageUrl) async {

    CatController controller = Get.put(CatController());
    Future.delayed(const Duration(seconds: 4)).then((v){
  return countriesCollection.add({
      'name': name,
      'nameEn': nameEn,
      'image':controller.uploadedFileURL.toString(),
    });
    });
  
  }

  // Update a country
  Future<void> updateCountry(String docId, String name, String nameEn, String imageUrl) {

    
    return countriesCollection.doc(docId).update({
      'name': name,
      'nameEn': nameEn,
      'image': imageUrl,
    });
  }

  // Delete a country
  Future<void> deleteCountry(String docId) {
    return countriesCollection.doc(docId).delete();
  }
}