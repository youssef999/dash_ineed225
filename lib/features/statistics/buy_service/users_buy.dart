

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/features/statistics/buy_service/providers_buy.dart';
import '../../../core/theme/colors.dart';
import 'buy_service_with_user.dart';

class UsersBuyService extends StatefulWidget {
  const UsersBuyService({super.key});

  @override
  _UsersBuyServiceState createState() => _UsersBuyServiceState();
}

class _UsersBuyServiceState extends State<UsersBuyService> {
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  Set<dynamic> buyServiceEmails = {};

  @override
  void initState() {
    super.initState();
    fetchBuyServiceEmails();
  }

  Future<void> fetchBuyServiceEmails() async {
    try {
      QuerySnapshot buyServiceSnapshot = await FirebaseFirestore.instance
          .collection('buyService')
          .get();

      // Extract user_email values and store them in a set
      buyServiceEmails = buyServiceSnapshot.docs.map((doc) {
        return doc['user_email'] ?? '';
      }).toSet();

      // Fetch users after obtaining the relevant emails
      fetchUsers();
    } catch (e) {
      print('Error fetching buyService emails: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      List<Map<String, dynamic>> users = usersSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // Filter users whose emails exist in buyServiceEmails
      users = users.where((user) {
        final email = user['email'] ?? '';
        return buyServiceEmails.contains(email);
      }).toList();

      // Remove duplicates based on email
      users = _removeDuplicateUsers(users);

      // Sort users locally by name in a case-insensitive manner
      users.sort((a, b) {
        String nameA = (a['name'] ?? '').toLowerCase();
        String nameB = (b['name'] ?? '').toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        usersList = users;
        filteredUsers = users;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = _removeDuplicateUsers(usersList);
      });
    } else {
      setState(() {
        filteredUsers = _removeDuplicateUsers(
          usersList.where((user) {
            final lowerQuery = query.toLowerCase();
            return (user['name'] ?? '').toLowerCase().contains(lowerQuery) ||
                (user['email'] ?? '').toLowerCase().contains(lowerQuery);
          }).toList(),
        );
      });
    }
  }

  // Helper function to remove duplicate users by email
  List<Map<String, dynamic>> _removeDuplicateUsers(
      List<Map<String, dynamic>> users) {
    final seenEmails = <String>{};
    return users.where((user) {
      final email = user['email'] ?? '';
      if (seenEmails.contains(email)) {
        return false;
      } else {
        seenEmails.add(email);
        return true;
      }
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختر المستخدم',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.only(left:98.0,right:22,top:18,bottom: 17),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'بحث',
                hintText: 'بحث عن طريق الاسم أو البريد الإلكتروني',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: filterUsers,
            ),
          ),
          // Users list
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('لا يوجد مستخدمون'))
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Padding(
                  padding: const EdgeInsets.only(left:90.0,right:18,top:15,bottom: 12),
                  child: InkWell(
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['image'] != null &&
                              user['image'].isNotEmpty
                              ? NetworkImage(user['image'])
                              : const AssetImage(
                              'assets/images/default_avatar.png')
                          as ImageProvider,
                        ),
                        title: Text(
                          user['name'] ?? 'اسم غير متوفر',
                          style: GoogleFonts.cairo(
                            fontSize: 22,fontWeight: FontWeight.bold
                          ),
                        ),
                        subtitle: Text(
                          user['email'] ?? 'بريد غير متوفر',
                          style: GoogleFonts.cairo(),
                        ),
                      ),
                    ),
                    onTap: () {
                      Get.to(ServicesBuyWithUser(email: user['email']));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
