import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_country.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_rates.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_rates2.dart';
import 'adv_serach/adv_search.dart';
import 'done_taks_providers.dart';
import 'done_tasks2.dart';
import 'prov_alpha2.dart';
import 'provider_details.dart';
import 'providers_alpha_view.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<Map<String, int>> _fetchBuyServiceCounts(String providerEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buyService')
          .where('worker_email', isEqualTo: providerEmail)
          .get();

      int done = 0;
      int pending = 0;
      int accepted = 0;
      int canceled = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc['status'] ?? '';
        if (status == 'done') {
          done++;
        } else if (status == 'pending') {
          pending++;
        } else if (status == 'accepted') {
          accepted++;
        } else if (status == 'canceled') {
          canceled++;
        }
      }

      return {
        'all': querySnapshot.size,
        'done': done,
        'pending': pending,
        'accepted': accepted,
        'canceled': canceled,
      };
    } catch (e) {
      print('Error fetching buyService counts: $e');
      return {};
    }
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
          .collection('serviceProviders')
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
  Widget buildProviderCard(QueryDocumentSnapshot provider) {
    String name = provider['name'] ?? 'لا يوجد اسم';
    String imageUrl = provider['image'] ?? '';
    String email = provider['email'] ?? 'لا يوجد بريد';
    String phone = provider['phone'] ?? '';
    String country = provider['country'] ?? '';

    return InkWell(
      onTap: () {
        Get.to(ProviderDetails(provider: provider));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                    radius: 30,
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
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:MainAxisAlignment.center,
                          children: [
                            Text(
                              country,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 21,),
                             Text(
                          provider['city'],
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                          ],
                        ),
                        
                        //provider['country']
                      ],
                    ),
                  ),
                  IconButton(
                    icon:const Icon(Icons.delete,color: Colors.red,),
                    onPressed:(){
                      deleteUserByEmail(email,context);
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "التقييم : ",
                    style: GoogleFonts.cairo(),
                  ),
                  RatingBar.builder(
                    initialRating: double.parse(provider['rating'].toString()),
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20.0,
                    ignoreGestures: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                  Text(
                    " (${provider['rating'].toStringAsFixed(1)})",
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, int>>(
                future: _fetchTaskCounts(email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final taskCounts = snapshot.data ?? {};
                  return _buildStatsCard(
                    title: 'إحصائيات المهام',
                    icon: Icons.assignment,
                    stats: taskCounts,
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, int>>(
                future: _fetchBuyServiceCounts(email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final buyServiceCounts = snapshot.data ?? {};
                  return _buildStatsCard(
                    title: 'إحصائيات الطلبات المباشرة',
                    icon: Icons.shopping_cart,
                    stats: buyServiceCounts,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required IconData icon,
    required Map<String, int> stats,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatItem('إجمالي الطلبات', stats['all'] ?? 0),
          _buildStatItem('مكتملة', stats['done'] ?? 0),
          _buildStatItem('قيد الانتظار', stats['pending'] ?? 0),
          _buildStatItem('مقبولة', stats['accepted'] ?? 0),
          _buildStatItem('ملغاة', stats['canceled'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'مقدمين الخدمات',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 30, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_alt, size: 30, color: Colors.orangeAccent),
            onPressed: () {
              showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'ابحث عن مقدم خدمة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : const Icon(Icons.search),
                ),
                style: GoogleFonts.cairo(),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('serviceProviders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد مقدمي خدمات',
                      style: GoogleFonts.cairo(),
                    ),
                  );
                }

                final providers = snapshot.data!.docs;
                final filteredProviders = providers.where((provider) {
                  String name = provider['name']?.toLowerCase() ?? '';
                  String email = provider['email']?.toLowerCase() ?? '';
                  String phone = provider['phone']?.toLowerCase() ?? '';

                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      phone.contains(_searchQuery);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'عدد مقدمي الخدمات: ${filteredProviders.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left:28.0,right:10,top:9,bottom:9),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredProviders.length,
                          itemBuilder: (context, index) {
                            var provider = filteredProviders[index];
                            return Padding(
                              padding: const EdgeInsets.only(left:38.0,right:15,top:9,bottom: 9),
                              child: buildProviderCard(provider),
                            );
                          }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,mainAxisSpacing: 10,crossAxisSpacing: 10,
                            childAspectRatio: 0.91,
                            ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
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
              ListTile(
                leading: const Icon(Icons.filter_alt),
                title: Text('البحث المتقدم', style: GoogleFonts.cairo()),
                onTap: () {
                  Get.to(const AdvSearchView());
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_rate),
                title: Text('  البحث الاعلي تقييما من الاعلي للاقل' , style: GoogleFonts.cairo()),
                onTap: () {
                  //ProvidersWithRatingsScreen2
                  Get.to(const ProvidersWithRatingsScreen());
                },
              ),
               ListTile(
                leading: const Icon(Icons.star_rate),
                title: Text('  البحث الاعلي تقييما من الاقل الي الاعلي ' , style: GoogleFonts.cairo()),
                onTap: () {
                  //ProvidersWithRatingsScreen2
                  Get.to(const ProvidersWithRatingsScreen2());
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text(' البحث بالترتيب الابجدي'+" من a to z ", style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.of(context).pop();
                  Get.to(const ProvidersScreenAlpha());
                },
              ),
                ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text(' البحث بالترتيب الابجدي'+" من z to a ", style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.of(context).pop();
                  Get.to(const ProvidersScreenAlpha2());
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('البحث بالبلد', style: GoogleFonts.cairo()),
                onTap: () {
                  Get.to(const ProvidersScreenWithCountry());
                },
              ),
              ListTile(
                leading: const Icon(Icons.task_alt),
                title: Text('الاكثر المستخدمين مهام مكتملة من الاعلي الي الاقل', style: GoogleFonts.cairo()),
                onTap: () {
                  Get.to(const ProvidersScreenDoneTasks());
                },
              ),
               ListTile(
                leading: const Icon(Icons.task_alt),
                title: Text('  الاكثر المستخدمين مهام مكتملة من الاقل الي الاعلي' , style: GoogleFonts.cairo()),
                onTap: () {
                  Get.to(const ProvidersScreenDoneTasks2());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, int>> _fetchTaskCounts(String providerEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('email', isEqualTo: providerEmail)
          .get();

      int doneTasks = 0;
      int canceledTasks = 0;
      int pendingTasks = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc['status'] ?? '';
        if (status == 'done') {
          doneTasks++;
        } else if (status == 'canceled') {
          canceledTasks++;
        } else if (status == 'pending') {
          pendingTasks++;
        }
      }

      return {
        'done': doneTasks,
        'canceled': canceledTasks,
        'pending': pendingTasks,
        'all': querySnapshot.size,
      };
    } catch (e) {
      print('Error fetching task counts: $e');
      return {};
    }
  }
}

void showDeleteDialog(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا العامل الان ؟'),
        actions: <Widget>[
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('serviceProviders')
                  .doc(id)
                  .delete();
              Navigator.of(context).pop();
              Get.snackbar('', 'تم الحذف بنجاح',
                  backgroundColor: Colors.green, colorText: Colors.white);
            },
          ),
          TextButton(
            child: const Text('الغاء', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}