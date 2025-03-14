import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import 'st_users_view.dart';

class UsersSearchScreen extends StatefulWidget {
  const UsersSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ArabicUsersSearchScreenState createState() => _ArabicUsersSearchScreenState();
}

class _ArabicUsersSearchScreenState extends State<UsersSearchScreen> {
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      // Fetch all proposals to extract the user emails
      QuerySnapshot proposalsSnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .get();

      // Collect emails from the proposals collection
      final proposalEmails = proposalsSnapshot.docs.map((doc) {
        return doc['user_email'] ?? '';
      }).toSet(); // Use a set to ensure uniqueness

      // Fetch users from the users collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // Filter users based on whether their email exists in the proposals collection
      users = users.where((user) {
        final email = user['email'] ?? '';
        return proposalEmails.contains(email);
      }).toList();

      // Remove duplicates based on email
      final seenEmails = <String>{};
      users = users.where((user) {
        final email = user['email'] ?? '';
        if (seenEmails.contains(email)) {
          return false;
        } else {
          seenEmails.add(email);
          return true;
        }
      }).toList();

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
            final name = (user['name'] ?? '').toLowerCase();
            final email = (user['email'] ?? '').toLowerCase();
            return name.contains(lowerQuery) || email.contains(lowerQuery);
          }).toList(),
        );
      });
    }
  }

  // Helper function to remove duplicate users by email
  List<Map<String, dynamic>> _removeDuplicateUsers(List<Map<String, dynamic>> users) {
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
          'فلترة حسب المستخدم',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                : Padding(
                  padding: const EdgeInsets.only(left: 118.0, right: 22, top: 20, bottom: 9),
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 68.0, right: 11, bottom: 8),
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
                                style: GoogleFonts.cairo(),
                              ),
                              subtitle: Text(
                                user['email'] ?? 'بريد غير متوفر',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          ),
                          onTap: () {
                            Get.to(StUsersView(email: user['email']));
                          },
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}