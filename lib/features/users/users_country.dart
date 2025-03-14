import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/features/users/user_details2.dart';
import '../../core/theme/colors.dart';
import 'user_details.dart';

class UsersByCountryScreen extends StatefulWidget {
  const UsersByCountryScreen({super.key});

  @override
  _UsersByCountryScreenState createState() => _UsersByCountryScreenState();
}

class _UsersByCountryScreenState extends State<UsersByCountryScreen> {
  String? selectedCountry;
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = false;
  String searchQuery = '';

  final List<String> countries = ['مصر', 'سعودية', 'الكويت'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'اختر الدولة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 21,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedCountry == null
              ? _buildCountrySelector()
              : _buildUsersList(),
    );
  }

  Widget _buildCountrySelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'اختر الدولة لعرض المستخدمين:',
            style: GoogleFonts.cairo(fontSize: 20),
          ),
          const SizedBox(height: 2),
          ...countries.map((country) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCountry = country;
                    isLoading = true;
                  });
                  fetchUsersByCountry(country);
                },
                child: Text(country, style: GoogleFonts.cairo(fontSize: 18)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Column(
      children: [
        const SizedBox(height: 22,),
        // Search Bar
        Padding(
          padding: const EdgeInsets.only(left: 104,right:14),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'ابحث عن مستخدم',
              hintText: 'ابحث بالاسم أو البريد الإلكتروني أو رقم الهاتف',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
                filterUsers();
              });
            },
          ),
        ),
                const SizedBox(height: 33,),
        // Number of Users
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: Text(
            'عدد المستخدمين: ${filteredUsers.length}',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Users List
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(
                  child: Text(
                    'لا يوجد مستخدمون في هذه الدولة.',
                    style: GoogleFonts.cairo(),
                  ),
                )
              : Padding(
                padding: const EdgeInsets.only(left:25.0,right:20,top:6,bottom: 7),
                child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                
                
                      return Padding(
                        padding: const EdgeInsets.only(left:38.0,right:13,top:6),
                        child: buildUserCard(user),
                      );
                
                     
                    }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 7,
                      childAspectRatio:1.24
                    )
                  ),
              ),
        ),
      ],
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

  Widget buildUserCard(Map<String,dynamic> user) {

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

          Get.to(UserDetails2(user: user));
      
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                name,
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                email,
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 8.0),
              Text(
                phone,
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void filterUsers() {
    if (searchQuery.isEmpty) {
      setState(() {
        filteredUsers = usersList;
      });
    } else {
      setState(() {
        filteredUsers = usersList.where((user) {
          final name = user['name']?.toLowerCase() ?? '';
          final email = user['email']?.toLowerCase() ?? '';
          final phone = user['phone']?.toLowerCase() ?? '';
          return name.contains(searchQuery) ||
              email.contains(searchQuery) ||
              phone.contains(searchQuery);
        }).toList();
      });
    }
  }

  Future<void> fetchUsersByCountry(String country) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('country', isEqualTo: country)
          .get();

      List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
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
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}