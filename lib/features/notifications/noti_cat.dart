import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotiCat extends StatefulWidget {
  const NotiCat({super.key});

  @override
  State<NotiCat> createState() => _NotiCatState();
}

class _NotiCatState extends State<NotiCat> {
  // Controllers for title and body
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _selectedNotificationPlace;
  // ignore: unused_field
  String? _selectedNotificationId;


  final List<Map<String, String>> notificationPlaces = [
    {'id': '         1', 'name': 'الرئيسية'},
    {'id': '         2', 'name': 'الدردشة'},
    {'id': '         3', 'name': 'المهام'},
    {'id': '         4', 'name': 'العروض'},
    {'id': '         5', 'name': 'الاعدادات'},
  ];

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Categories List
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  // Selected category
  String? selectedCategoryId;
  String? selectedCategoryTopic;

  @override
  void initState() {
    super.initState();
   
    _fetchCategories();
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('cat').get();
      setState(() {
        categories = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'], // Arabic name
            'topic': doc['name'], // Topic name for FCM
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: 'Failed to fetch categories: $e',
        backgroundColor: Colors.red,
      );
    }
  }



 String newCat='';

  Future<void> fetchNameEnByName(String name) async {
    print("NAME==="+name);
    try {
      // Query Firestore for a document with the specified name
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cat')
          .where('name', isEqualTo: name)
          .get();

      // Ensure at least one document is found
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the 'nameEn' field from the first document
      //  setState(() {
          newCat = querySnapshot.docs.first['nameEn'] ?? 'No translation found';
        
          

        //});
      } else {
        //setState(() {
          newCat = 'No translation found';
       // });
      }
    } catch (e) {
      print('Error fetching nameEn by name: $e');
     
    }
  }

  // Function to send notification
  static Future<void> sendNotificationWithCat(String title, String body, String selected,String loc) async {

    print("S==$selected");

    String newCat=selected.replaceAll(' ', '');

    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/servicesapp2024/messages:send';
    final Map<String, dynamic> message = {
      "message": {
        "topic": newCat,// Use a topic to send to all subscribers
        "notification": {"title": title+loc, "body": body+loc},
        "data": {
          "route": "serviceScreen",
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print('Notification sent to all successfully');
      Fluttertoast.showToast(
        msg: "تم إرسال الإشعار إلى الجميع بنجاح",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      print(response.statusCode);
      print('Failed to send notification to all');
      Fluttertoast.showToast(
        msg: "فشل في إرسال الإشعار إلى الجميع",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Example function to get Access Token (replace this with a working implementation)
  static Future<String> getAccessToken() async {

    /*
    "type": "service_account",
  "project_id": "servicesapp2024",
  "private_key_id": "895b93908e33c72631e02ebdc5b19dad9d0dfb92",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCoywsEZZV2UKCU\n++mGXknAr/AWe7/09nLjFt8DFravT/PdHBO+cn2qWejmrKAbRtFjWPvMEE37f2oa\n5Aj2XeRJ1u5lDYqQ8ho90LFiJ8G0IBj9fGMnALSzfI9DOXvyIqoFBBtdjF1zXSVL\n3zH+ZMYBBi4t9lPk8gMkHo5g/BpZyea4RA4M+9TME2VoVTAK7F1R0lRfr5nACrLE\nXzPi1sVu7LieBd4skz4/N8R5bBfeoXEI25EOZUYLNsZuwl7PGnqJ9ZxoXHC0WzpS\nUG+nc7tufhtLI5N2449amfUAGAdhgClbVvb3z4wkThCi2L7FVR2OfuZCtsgl/KMZ\n+SrVqOP9AgMBAAECggEAFDnyecYnfRxHxdqS/vY8/cFHcpZFKBhBJ5u1wRO/c+4P\ngaMr7YIgM2HfQgcVD3eyvyYqVCdvBNBdmVfSiB0zrjJ6cjMHc/uC7/3aR7IOaOSA\nwh1d705LGQf3zd0tUFRdjcjSc6kOiLS0c61M+xg9zuEb9weBwZlLjZA4zP/gs3oH\neaJopg916Y3QwzAR+1Lq94QAJXc74W6o1CwNHoKvwD8HbXRt/RvpgMK9U1/1S/gT\noRhQOX/So3hAqSKyaO/OLKBmR0ANIwv2kvlDhTl+ER3kqLN/D72Y9wBbgXlorNFz\nfx8HV+5N0LKXVkeHnVXSeMsqsVUO6b/3jcU/+Yx3SQKBgQDg6Zo8+toeVHzp1WIH\nceRdQsyxqN7OX7MOH2HzOOaPuPeuki4ubk8wRVMneb7ZA0fm3yS7oBxt2yXbvrqO\namf40dXD0rX32Xp7T5PH4VysklirwoTxH3j/RFtcAZ6UphRiWzSpzE+4+SI44krm\nH2Gt7YBeamCLDgAzoGsuV+NtiQKBgQDAH7B7XRZQAMscJsl+K7/1F3UyZh+MSSOy\nqseBXmgxxMOKranbCDWcK8a8AxDZ5z52wN9y0eTtXe1EQRJZj63I15IlULgivofd\nJDQ7qbq7KT3iIPYR07Lwn1+o7olqk0GV1yY9Ig6xmc/TY2S4IMYjqefA1aGWyP0i\ncjwRWCF51QKBgQCGZA99kIb0yJc7Qf2pZSyHbXrSTY2U0yoyrh3hL4bVKjkVXtOp\netBmj4X4eI7JLWSxV3SjiDB0lBYzD+x5XKtzyi5pLGb/CjxdolczgD3YADprp3e4\nfI3YOgg9GdqgB/z2KHl3XFXmuTbxtoX6q5W6T8f8oqO9c0g7kQd6UZnbwQKBgQC2\nfmN5Cxcir14/Q2ip/Iy+FqYwVWkqLF9IW4hejnqSq8DCfeuWLtodmkeQV6kuEsX2\nr4aQ3meCQXIbH2R6xkvhN0OPRnliJ3GO0dD7y2GgXrB1l7GlhV23yutm4A6PuYjW\n+CNOdodWlDAhL4yAikErpzyIo2R2gjxQ+Amuv/QscQKBgG8QFt9aJWGBtF9mXTIe\ncQlzu3q0KIY18Pg4ZHgtGkp00PGHcmLW63F9dPsmNp4kLyp6Lp3Tj8bA2LbM20Wl\nF8ia4Ktctu2AzQ9pR6FWaAJCit/+i3y1RhXXhC1ydSh4lnBjrBshuOtULx/7iLE8\nY5LaPACh9TntO7x1lWrXa6xu\n-----END PRIVATE KEY-----\n",
  "client_email": "serviceappfcm@servicesapp2024.iam.gserviceaccount.com",
  "client_id": "115763657468661021643",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/serviceappfcm%40servicesapp2024.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
     */
    final serviceAccountJson ={
      "type": "service_account",
      "project_id": "servicesapp2024",
      "private_key_id": "895b93908e33c72631e02ebdc5b19dad9d0dfb92",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCoywsEZZV2UKCU\n++mGXknAr/AWe7/09nLjFt8DFravT/PdHBO+cn2qWejmrKAbRtFjWPvMEE37f2oa\n5Aj2XeRJ1u5lDYqQ8ho90LFiJ8G0IBj9fGMnALSzfI9DOXvyIqoFBBtdjF1zXSVL\n3zH+ZMYBBi4t9lPk8gMkHo5g/BpZyea4RA4M+9TME2VoVTAK7F1R0lRfr5nACrLE\nXzPi1sVu7LieBd4skz4/N8R5bBfeoXEI25EOZUYLNsZuwl7PGnqJ9ZxoXHC0WzpS\nUG+nc7tufhtLI5N2449amfUAGAdhgClbVvb3z4wkThCi2L7FVR2OfuZCtsgl/KMZ\n+SrVqOP9AgMBAAECggEAFDnyecYnfRxHxdqS/vY8/cFHcpZFKBhBJ5u1wRO/c+4P\ngaMr7YIgM2HfQgcVD3eyvyYqVCdvBNBdmVfSiB0zrjJ6cjMHc/uC7/3aR7IOaOSA\nwh1d705LGQf3zd0tUFRdjcjSc6kOiLS0c61M+xg9zuEb9weBwZlLjZA4zP/gs3oH\neaJopg916Y3QwzAR+1Lq94QAJXc74W6o1CwNHoKvwD8HbXRt/RvpgMK9U1/1S/gT\noRhQOX/So3hAqSKyaO/OLKBmR0ANIwv2kvlDhTl+ER3kqLN/D72Y9wBbgXlorNFz\nfx8HV+5N0LKXVkeHnVXSeMsqsVUO6b/3jcU/+Yx3SQKBgQDg6Zo8+toeVHzp1WIH\nceRdQsyxqN7OX7MOH2HzOOaPuPeuki4ubk8wRVMneb7ZA0fm3yS7oBxt2yXbvrqO\namf40dXD0rX32Xp7T5PH4VysklirwoTxH3j/RFtcAZ6UphRiWzSpzE+4+SI44krm\nH2Gt7YBeamCLDgAzoGsuV+NtiQKBgQDAH7B7XRZQAMscJsl+K7/1F3UyZh+MSSOy\nqseBXmgxxMOKranbCDWcK8a8AxDZ5z52wN9y0eTtXe1EQRJZj63I15IlULgivofd\nJDQ7qbq7KT3iIPYR07Lwn1+o7olqk0GV1yY9Ig6xmc/TY2S4IMYjqefA1aGWyP0i\ncjwRWCF51QKBgQCGZA99kIb0yJc7Qf2pZSyHbXrSTY2U0yoyrh3hL4bVKjkVXtOp\netBmj4X4eI7JLWSxV3SjiDB0lBYzD+x5XKtzyi5pLGb/CjxdolczgD3YADprp3e4\nfI3YOgg9GdqgB/z2KHl3XFXmuTbxtoX6q5W6T8f8oqO9c0g7kQd6UZnbwQKBgQC2\nfmN5Cxcir14/Q2ip/Iy+FqYwVWkqLF9IW4hejnqSq8DCfeuWLtodmkeQV6kuEsX2\nr4aQ3meCQXIbH2R6xkvhN0OPRnliJ3GO0dD7y2GgXrB1l7GlhV23yutm4A6PuYjW\n+CNOdodWlDAhL4yAikErpzyIo2R2gjxQ+Amuv/QscQKBgG8QFt9aJWGBtF9mXTIe\ncQlzu3q0KIY18Pg4ZHgtGkp00PGHcmLW63F9dPsmNp4kLyp6Lp3Tj8bA2LbM20Wl\nF8ia4Ktctu2AzQ9pR6FWaAJCit/+i3y1RhXXhC1ydSh4lnBjrBshuOtULx/7iLE8\nY5LaPACh9TntO7x1lWrXa6xu\n-----END PRIVATE KEY-----\n",
      "client_email": "serviceappfcm@servicesapp2024.iam.gserviceaccount.com",
      "client_id": "115763657468661021643",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/serviceappfcm%40servicesapp2024.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);
    client.close();
    return credentials.accessToken.data;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'إرسال إشعار للقسم',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            // Dropdown to select category
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اختر القسم',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedCategoryId,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']), // Display Arabic name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                  selectedCategoryTopic = categories
                      .firstWhere((cat) => cat['id'] == value)['topic'];
                });
              },
            ),
            const SizedBox(height: 16),

            // Title input
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان الإشعار',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Body input
            TextFormField(
              controller: _bodyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'نص الإشعار',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

          // Add spacing before dropdown

            DropdownButtonFormField<String>(
              value: _selectedNotificationPlace, // Currently selected value
              decoration: InputDecoration(
                labelText: 'مكان الإشعار',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              items: notificationPlaces.map((place) {
                return DropdownMenuItem<String>(
                  value: place['id'],
                  child: Text(place['name']!, style: GoogleFonts.cairo()),
                );
              }).toList(),
              onChanged: (value) {
                print("v===${value!}");
                setState(() {
                  _selectedNotificationPlace = value;
                  // _selectedNotificationId = place['id'];
                  print("Selected Notification Place: $_selectedNotificationPlace");
                });
              },
              hint: Text('اختر مكان الإشعار', style: GoogleFonts.cairo()),
            ),

            const SizedBox(height: 16),

            // Send Notification Button
            ElevatedButton(
              onPressed:() {

   fetchNameEnByName(selectedCategoryTopic!);

    Future.delayed(const Duration(seconds: 1), () {
      
                sendNotificationWithCat(_titleController.text,
                    _bodyController.text, newCat,
                    _selectedNotificationPlace.toString());
    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'أرسل الإشعار للعاملين بهذا القسم',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
