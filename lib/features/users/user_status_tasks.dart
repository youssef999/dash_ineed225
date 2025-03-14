import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/users/user_details2.dart';

class UsersWithDoneTasksScreen extends StatefulWidget {
  const UsersWithDoneTasksScreen({super.key});

  @override
  _UsersWithDoneTasksScreenState createState() =>
      _UsersWithDoneTasksScreenState();
}

class _UsersWithDoneTasksScreenState extends State<UsersWithDoneTasksScreen> {
  List<Map<String, dynamic>> usersWithDoneTasks = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsersWithDoneTasks();
  }

  Future<void> fetchUsersWithDoneTasks() async {
    print("Fetching users with done tasks...");
    try {
      // Fetch all tasks with status 'done'
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('status', isEqualTo: 'done')
          .get();

      // Group tasks by user_email and count them
      Map<String, int> userTaskCount = {};
      for (var task in tasksSnapshot.docs) {
        final userEmail = task['user_email'];
        userTaskCount[userEmail] = (userTaskCount[userEmail] ?? 0) + 1;
      }

      // Fetch user details for each user_email
      List<Map<String, dynamic>> userList = [];
      for (String userEmail in userTaskCount.keys) {
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          final userData = userQuerySnapshot.docs.first.data();
          userList.add({
            'id': userQuerySnapshot.docs.first.id,
            'name': userData['name'],
            'email': userData['email'],
            'phone': userData['phone'],
            'fcmToken': userData['fcmToken'] ?? '',
             'country': userData['country'] ?? '',
            'city': userData['city'] ?? '',
            
            'image': userData['image'] ?? '',
            'doneTasks': userTaskCount[userEmail],
          });
        }
      }

      setState(() {
        usersWithDoneTasks = userList;
        filteredUsers = userList;
        isLoading = false;
      });
      print('Users fetched: ${usersWithDoneTasks.length}');
    } catch (error) {
      print('Error fetching users with done tasks: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = usersWithDoneTasks;
      });
    } else {
      setState(() {
        filteredUsers = usersWithDoneTasks.where((user) {
          final lowerQuery = query.toLowerCase();
          return user['name'].toLowerCase().contains(lowerQuery) ||
              user['email'].toLowerCase().contains(lowerQuery) ||
              user['phone'].toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'المستخدمين ذوي المهام المكتملة',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ابحث هنا',
                hintText: 'ابحث باسم المستخدم او البريد الالكتروني او رقم الهاتف',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    filterUsers('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: filterUsers,
            ),
          ),
          // Users list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          'لا يوجد مستخدمين',
                          style: GoogleFonts.cairo(fontSize: 18),
                        ),
                      )
                    : Padding(
                      padding: const EdgeInsets.only(left:28.0,right:19),
                      child: ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildUserCard(user, user['doneTasks'].toString()),
                            );
                          },
                        ),
                    ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: fetchUsersWithDoneTasks,
      //   backgroundColor: primary,
      //   child: const Icon(Icons.refresh, color: Colors.white),
      // ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildUserCard(Map<String, dynamic> user, String doneTasks) {
    String email = user['email'] ?? 'لا يوجد بريد';
    String imageUrl = user['image'] ?? '';
    String name = user['name'] ?? 'لا يوجد اسم';
    String phone = user['phone'] ?? 'لا يوجد رقم';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.to(UserDetails2(user: user));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عدد المهام المكتملة: $doneTasks',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 30,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  showDeleteDialog(context, user['id']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المستخدم؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();
                Navigator.of(context).pop();
                Get.snackbar(
                  'تم الحذف',
                  'تم حذف المستخدم بنجاح',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                fetchUsersWithDoneTasks(); // Refresh the list
              },
            ),
          ],
        );
      },
    );
  }
}