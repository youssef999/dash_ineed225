import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  String? _selectedUserId;
  String? _selectedPrvoiderId;
  String? _selectedToken;
  String? _selectedProviderToken;
  // ignore: unused_field
  String? _selectedUserName;
  // ignore: unused_field
  String? _selectedProviderName;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إشعارات', style: GoogleFonts.cairo()),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إرسال إشعار',
              style:
                  GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان الإشعار',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'وصف الإشعار',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final users = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    decoration: InputDecoration(
                      labelText: 'اختر مستخدم',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    items: users.map((user) {
                      final userId = user.id;
                      final userName = user['name'] ?? 'Unnamed User';
                      return DropdownMenuItem<String>(
                        value: userId,
                        child: Text(userName, style: GoogleFonts.cairo()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                        _selectedToken = users.firstWhere(
                                (user) => user.id == value)['fcmToken'] ??
                            'Non';
                        _selectedUserName = users.firstWhere(
                                (user) => user.id == value)['name'] ??
                            'Unnamed User';
                      });
                    },
                    hint: Text('اختر مستخدم', style: GoogleFonts.cairo()),
                  );
                }
              },
            ),
            const SizedBox(height: 16), // Add spacing before dropdown

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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectedToken != null
                        ? () {
                          
                      print("notiii...");
                      NotificationService.sendNotification(
                        _selectedToken!,
                        _titleController.text,
                        _messageController.text, _selectedNotificationPlace.toString()
                      );
                    }
                        : (){
                      print("NO TOKEN SELECTED");
                    }, // Disable the button if no token is selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedToken != null
                          ? primaryColor
                          : Colors.grey, // Change color when disabled
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'إرسال لمستخدم',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  ElevatedButton(
                    onPressed: () {
                      NotificationService.sendNotificationToAll(
                        _titleController.text,
                        _messageController.text,
                        0,
                          _selectedNotificationPlace.toString()
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'إرسال للجميع',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),


                ],
              ),
            ),


            const SizedBox(height: 16),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('serviceProviders').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final users = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedPrvoiderId,
                    decoration: InputDecoration(
                      labelText: 'اختر مقدم الخدمة  ',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    items: users.map((user) {
                      final userId = user.id;
                      final userName = user['name'] ?? 'Unnamed User';
                      return DropdownMenuItem<String>(
                        value: userId,
                        child: Text(userName, style: GoogleFonts.cairo()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPrvoiderId = value;
                        _selectedProviderToken = users.firstWhere(
                                (user) => user.id == value)['fcmToken'] ??
                            'Non';
                        _selectedProviderName = users.firstWhere(
                                (user) => user.id == value)['name'] ??
                            'Unnamed User';
                      });
                    },
                    hint: Text('اختر مقدم الخدمة  ', style: GoogleFonts.cairo()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectedProviderToken != null
                        ? () {
                      print("notiii...");
                      NotificationService.sendNotification(
                        _selectedProviderToken!,
                        _titleController.text,
                        _messageController.text, _selectedNotificationPlace.toString()
                      );
                    }
                        : (){
                      print("NO TOKEN SELECTED");
                    }, // Disable the button if no token is selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedToken != null
                          ? primaryColor
                          : Colors.grey, // Change color when disabled
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'إرسال لمقدم خدمة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      NotificationService.sendNotificationToAll(
                        _titleController.text,
                        _messageController.text,
                        1,
                        _selectedNotificationPlace.toString()
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'إرسال للجميع',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )


          ],
        ),
      ),
    );
  }
}
