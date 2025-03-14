
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/service_providers/adv/adv_prov_alpha.dart';
import 'package:yemen_services_dashboard/features/service_providers/adv/adv_prov_rate.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_country.dart';
import 'package:yemen_services_dashboard/features/service_providers/providers_alpha_view.dart';

import '../../service_providers/provider_details.dart';
import '../adv/adv_prov_tasks.dart';

class AdvProvidersScreen extends StatefulWidget {
  final String cat;
  final String subCat;
  final String country;

  const AdvProvidersScreen({
    super.key,
    required this.cat,
    required this.subCat,
    required this.country,
  });

  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<AdvProvidersScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  var filteredProviders;
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
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Icons.search, size: 40, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list_alt,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              showFilterDialog(context,filteredProviders);
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Update the search query
                  });
                },
                decoration: InputDecoration(
                  labelText: 'ابحث عن مقدم خدمة',
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
              stream: FirebaseFirestore.instance
                  .collection('serviceProviders')
              .where('cat',isEqualTo: widget.cat)
              .where('country',isEqualTo: widget.country)
              .where('subCat',isGreaterThanOrEqualTo: widget.subCat)
                 // .where('compositeKey', isEqualTo: '${widget.cat}_${widget.subCat}_${widget.country}')
                  .orderBy('rating', descending: true) // Sort by rating (highest first)
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

                // Filter providers based on the search query
                 filteredProviders = snapshot.data!.docs.where((provider) {
                  String name = provider['name'] ?? '';
                  String email = provider['email'] ?? '';
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredProviders.length,
                  itemBuilder: (context, index) {
                    var provider = filteredProviders[index];
                    return _buildProviderCard(provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showFilterDialog(BuildContext context,List<QueryDocumentSnapshot<Object?>> filteredProviders2) {
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
                leading: const Icon(Icons.star_rate),
                title: Text('البحث الاعلي تقييما من الاعلي للاقل ', style: GoogleFonts.cairo()),
                onTap: () {

                  Get.to(AdvRatingProviders(desc: true, filteredProviders: filteredProviders,
                  ));
                  //Get.to(const ProvidersWithRatingsScreen());
                },
              ),   ListTile(
                leading: const Icon(Icons.star_rate),
                title: Text('البحث الاعلي تقييما من الاقل للاعلي ', style: GoogleFonts.cairo()),
                onTap: () {
                  Get.to(AdvRatingProviders(desc: false, filteredProviders: filteredProviders,


                  ));
                 // Get.to(const ProvidersWithRatingsScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text(' البحث بالترتيب الابجدي من z to a ', style: GoogleFonts.cairo()),
                onTap: () {

                  Get.to(AdvAlphaProviders(desc: true, filteredProviders: filteredProviders,

                  ));

                },
              ), ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text(' البحث بالترتيب الابجدي من a to z  ', style: GoogleFonts.cairo()),
                onTap: () {

                  Get.to(AdvAlphaProviders(desc: false, filteredProviders: filteredProviders,
                  ));

                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(' البحث بالمهام المكتملة من الاعلي للاقل', style: GoogleFonts.cairo()),
                onTap: () {

                  Get.to(AdvProvTasks(filteredProviders:filteredProviders, desc: true,));

                },
              ), ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('البحث بالمهام المكتملة من الاقل للاعلي ', style: GoogleFonts.cairo()),
                onTap: () {
                  Get.to( AdvProvTasks(filteredProviders: filteredProviders, desc: false,));
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.task_alt),
              //   title: Text('الاكثر المستخدمين مهام مكتملة', style: GoogleFonts.cairo()),
              //   onTap: () {
              //     Get.to(const ProvidersScreenDoneTasks());
              //   },
              // ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo()),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderCard(QueryDocumentSnapshot provider) {
    String name = provider['name'] ?? 'لا يوجد اسم';
    String imageUrl = provider['image'] ?? '';
    String email = provider['email'] ?? 'لا يوجد بريد';
    String phone = provider['phone'] ?? '';
    String country = provider['country'] ?? '';

    return InkWell(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage('assets/images/default_avatar.png')
            as ImageProvider,
          ),
          title: Text(
            name,
            style: GoogleFonts.cairo(),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(email, style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text(phone, style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text(country, style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
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
              // Display task counts
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
                        Text(
                          'إحصائيات المهام',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTaskStatItem(Icons.check_circle, 'المهام المكتملة', taskCounts['done'] ?? 0),
                        _buildTaskStatItem(Icons.cancel, 'المهام الملغاة', taskCounts['canceled'] ?? 0),
                        _buildTaskStatItem(Icons.access_time, 'المهام قيد الانتظار', taskCounts['pending'] ?? 0),
                        _buildTaskStatItem(Icons.assignment, 'إجمالي المهام', taskCounts['all'] ?? 0),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              size: 33,
              color: Colors.redAccent,
            ),
            onPressed: () {
              showDeleteDialog(context, provider.id);
            },
          ),
        ),
      ),
      onTap: () {
        Get.to(ProviderDetails(provider: provider));
      },
    );
  }

  Widget _buildTaskStatItem(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
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

  Future<Map<String, int>> _fetchTaskCounts(String providerEmail) async {
    try {
      // Fetch all proposals for the provider
      final querySnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('email', isEqualTo: providerEmail)
          .get();

      // Count proposals by status
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
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}