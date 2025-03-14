

// import 'dart:typed_data';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';



// class ImageController extends GetxController{

//   String? uploadedFileURL;
//  final ImagePicker picker = ImagePicker();
//   bool isImageUploading = false; 
//   List<XFile> images = [];
//     String? imageUrl;

//   Future<void> pickMultipleImages() async {
   
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       // Immediately set the image URL to display in the dialog
//      // setState(() {
//         imageUrl = pickedFile.path; // Set the picked image path
//      // });
//       // Read the image as bytes for upload
//       Uint8List imageData = await pickedFile.readAsBytes();
//       // ignore: avoid_print
//       print('picked');
//       update();
//       uploadImage(imageData);
//     }
//   }
//    Future<String> uploadImage(Uint8List xfile) async {
//     Reference ref = FirebaseStorage.instance.ref().child('Folder');
//     String id = const Uuid().v1();
//     ref = ref.child(id);

//     UploadTask uploadTask = ref.putData(
//       xfile,
//       SettableMetadata(contentType: 'image/png'),
//     );
//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();
//    // setState(() {
//       uploadedFileURL = downloadUrl;
//       update();
//    // });
//     print(downloadUrl);
//     return downloadUrl;
//   }

//    Future<void> imgFromGallery() async {
//     final pickedFile =
//         await ImagePicker().
//         pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//     //  setState(() {
//         imageUrl = pickedFile.path; // Set the picked image path
//         isImageUploading = true; // Set uploading status to true
//        update();
//       // Read the image as bytes for upload
//       Uint8List imageData = await pickedFile.readAsBytes();
//       print('picked');
//       await uploadImage(imageData); // Await the image upload
//     }
//   }





  

// }