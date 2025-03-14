import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/features/users/user_details.dart';
import 'package:yemen_services_dashboard/features/users/user_name2.dart';
import 'package:yemen_services_dashboard/features/users/users_country.dart';
import 'package:yemen_services_dashboard/features/users/users_name.dart';
import '../../core/theme/colors.dart';
import 'user_status_tasks.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
 
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'المستخدمين',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        actions: [
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 30),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white, size: 30),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          const SizedBox(width: 32),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase(); // Convert to lowercase for case-insensitive search
                  });
                },
                decoration: InputDecoration(
                  labelText: 'ابحث عن مستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
                style: GoogleFonts.cairo(),
              ),
            ),
         
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد مستخدمين',
                      style: GoogleFonts.cairo(),
                    ),
                  );
                }

                var filteredUsers = _removeDuplicateUsers(snapshot.data!.docs).where((user) {
                  String name = user['name']?.toLowerCase() ?? '';
                  String email = user['email']?.toLowerCase() ?? '';
                  String phone = user['phone']?.toLowerCase() ?? '';

                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      phone.contains(_searchQuery);
                }).toList();

                return Padding(
                  padding: const EdgeInsets.only(left:18.0,right:16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Adjust the number of columns as needed
                      crossAxisSpacing: 9.0,
                      mainAxisSpacing: 9.0,
                      childAspectRatio: 0.92, // Adjust the aspect ratio for better spacing
                    ),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(left:28.0,right:15,top:11,bottom:6),
                        child: Column(
                          children: [

                            (index==0)?
                             
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Text('عدد المستخدمين'+" = "+filteredUsers.length.toString(),
                           style:const TextStyle(color:Colors.black,
                           fontSize: 21,fontWeight: FontWeight.bold
                           ),
                           ),
                         ):  
                         const Padding(
                           padding: EdgeInsets.all(8.0),
                           child: Text(" ",
                           style:TextStyle(color:Colors.black,
                           fontSize: 21,fontWeight: FontWeight.bold
                           )),
                         ),
                       
                            buildUserCard(user),
                          ],
                        ),
                      );
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

  List<QueryDocumentSnapshot> _removeDuplicateUsers(List<QueryDocumentSnapshot> users) {
    final seenEmails = <String>{};
    return users.where((user) {
      final email = user['email'] ?? '';
      if (seenEmails.contains(email.toLowerCase())) { // Case-insensitive check
        return false;
      } else {
        seenEmails.add(email.toLowerCase()); // Store lowercase email
        return true;
      }
    }).toList();
  }


  Future<void> deleteUserByEmail(String email, BuildContext context) async {
  // Show confirmation dialog
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تأكيد الحذف', style: TextStyle(fontSize: 18)),
        content: Text('هل أنت متأكد أنك تريد حذف مقدم الخدمة؟', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              // Return false if the user cancels
              Navigator.of(context).pop(false);
            },
            child: Text('إلغاء', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              // Return true if the user confirms
              Navigator.of(context).pop(true);
            },
            child: Text('حذف', style: TextStyle(color: Colors.green)),
          ),
        ],
      );
    },
  );

  // If the user confirms, proceed with deletion
  if (confirmDelete == true) {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the 'serviceProviders' collection for documents where 'email' matches the provided email
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Loop through the matching documents and delete them
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.delete();
          print('Document with email $email deleted successfully.');
          Get.snackbar(
            'تم الحذف',
            'تم حذف مقدم الخدمة بنجاح',
            colorText: Colors.white,
            backgroundColor: Colors.green,
          );
        }
      } else {
        print('No documents found with email $email.');
        Get.snackbar(
          'خطأ',
          'لا يوجد مستخدم بهذا البريد الإلكتروني',
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Error deleting user: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء محاولة الحذف: $e',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  } else {
    // User canceled the deletion
    print('Deletion canceled by user.');
  }
}

  Widget buildUserCard(QueryDocumentSnapshot user) {

    String email = user['email'] ?? 'لا يوجد بريد';
    String imageUrl = user['image'] ?? '';
    String name = user['name'] ?? 'لا يوجد اسم';
    String phone = user['phone'] ?? 'لا يوجد رقم';

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {

          Get.to(UserDetails(user: user));
      
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    ),
                  ),
                  IconButton(onPressed: (){
                    deleteUserByEmail(user['email'],context);
                  }, icon: const Icon(Icons.delete,color: Colors.red,),)
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                name,
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 7.0),
              Text(
                email,
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 7.0),
              Text(
                phone,
                style: GoogleFonts.cairo(fontSize: 14),
              ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(user['country']),
                 const SizedBox(width: 42,),
                 
                  Text(user['city']),
                ],
              ),
              const SizedBox(height: 9.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<Map<String, int>>(
                    future: _fetchBuyServiceCounts(email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final buyServiceCounts = snapshot.data ?? {};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow('طلب مباشر مطروح', buyServiceCounts['pending'] ?? 0, Colors.orange),
                          _buildStatusRow('طلب مباشر قيد التنفيذ', buyServiceCounts['accepted'] ?? 0, Colors.blue),
                          _buildStatusRow('طلب مباشر مكتمل', buyServiceCounts['done'] ?? 0, Colors.green),
                          _buildStatusRow('طلب مباشر ملغي', buyServiceCounts['canceled'] ?? 0, Colors.red),
                        ],
                      );
                    },
                  ),
                  FutureBuilder<Map<String, int>>(
                    future: _fetchTaskCounts(email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final taskCounts = snapshot.data ?? {};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow('مهام مطروحة', taskCounts['pending'] ?? 0, Colors.orange),
                          _buildStatusRow('مهام قيد التنفيذ', taskCounts['accepted'] ?? 0, Colors.blue),
                          _buildStatusRow('مهام مكتملة', taskCounts['done'] ?? 0, Colors.green),
                          _buildStatusRow('مهام مرفوضة', taskCounts['canceled'] ?? 0, Colors.red),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 9.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8.0),
          Text(
            '$status: $count',
            style: GoogleFonts.cairo(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _fetchBuyServiceCounts(String userEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buyService')
          .where('user_email', isEqualTo: userEmail)
          .get();

      int pendingCount = 0;
      int acceptedCount = 0;
      int doneCount = 0;
      int canceledCount = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc['status'] ?? '';
        if (status == 'pending') {
          pendingCount++;
        } else if (status == 'accepted') {
          acceptedCount++;
        } else if (status == 'done') {
          doneCount++;
        } else if (status == 'canceled') {
          canceledCount++;
        }
      }

      return {
        'pending': pendingCount,
        'accepted': acceptedCount,
        'done': doneCount,
        'canceled': canceledCount,
      };
    } catch (e) {
      print('Error fetching buyService counts: $e');
      return {};
    }
  }

  Future<Map<String, int>> _fetchTaskCounts(String userEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email', isEqualTo: userEmail)
          .get();

      int pendingTasks = 0;
      int acceptedTasks = 0;
      int doneTasks = 0;
      int canceledTasks = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc['status'] ?? '';
        if (status == 'pending') {
          pendingTasks++;
        } else if (status == 'accepted') {
          acceptedTasks++;
        } else if (status == 'done') {
          doneTasks++;
        } else if (status == 'canceled') {
          canceledTasks++;
        }
      }

      return {
        'pending': pendingTasks,
        'accepted': acceptedTasks,
        'done': doneTasks,
        'canceled': canceledTasks,
      };
    } catch (e) {
      print('Error fetching task counts: $e');
      return {};
    }
  }

  void _showFilterDialog(BuildContext context) {
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'اختر نوع البحث',
            style: GoogleFonts.cairo(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ListTile(
              //   leading: const Icon(Icons.sort_by_alpha),
              //   title: Text('البحث المتقدم', style: GoogleFonts.cairo()),
              //   onTap: () {
              //     Navigator.of(context).pop();
              //     // Navigate to Advanced Search Screen
              //     //Get.to(const AdvSearchView());
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text('البحث بالترتيب الابجدي من a to z' , style: GoogleFonts.cairo()),
                onTap: () {

                  Navigator.of(context).pop();
                  Get.to(const ArabicUsersSearchScreen());
              
                },
              ),

               ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text('  البحث بالترتيب الابجدي من z to a' , style: GoogleFonts.cairo()),
                onTap: () {

                  Navigator.of(context).pop();
                  Get.to(const ArabicUsersSearchScreen2());
              
                },
              ),

              //
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('البحث بالبلد', style: GoogleFonts.cairo()),
                onTap: () {

                  Navigator.of(context).pop();
                  Get.to(const UsersByCountryScreen());
              
                },
              ),
              ListTile(
                leading: const Icon(Icons.task_alt),
                title: Text('الاكثر المستخدمين مهام مكتملة', style: GoogleFonts.cairo()),
                onTap: () {

                  Navigator.of(context).pop();
                  Get.to(const UsersWithDoneTasksScreen());
                
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo(
                fontSize: 21
              )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}