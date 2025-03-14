import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_details.dart';

import '../statistics/views/st_providers.dart';


class ProvidersWithRatingsScreen extends StatefulWidget {
  const ProvidersWithRatingsScreen({super.key});

  @override
  _ProvidersWithRatingsScreenState createState() => _ProvidersWithRatingsScreenState();
}

class _ProvidersWithRatingsScreenState extends State<ProvidersWithRatingsScreen> {
  String _searchQuery = '';
  bool _isSearching = true;
  Set<String> proposalEmails = {}; // To store emails from proposals collection

  @override
  void initState() {
    super.initState();
    fetchProposalEmails();
  }

  Future<void> fetchProposalEmails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .get();

      setState(() {
        proposalEmails = querySnapshot.docs
            .map((doc) => doc['email'] as String)
            .toSet(); // Collect unique emails
      });
    } catch (e) {
      print('Error fetching proposal emails: $e');
    }
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
              icon: const Icon(Icons.search, size: 40),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
            ),
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
                    _searchQuery = value.toLowerCase(); // Normalize search query
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
                  .orderBy('rating', descending: true) // Sort by rating in descending order
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

                // Filter providers based on the search query and proposals emails
                var filteredProviders = snapshot.data!.docs.where((provider) {
                  String email = provider['email'] ?? '';
                  String name = (provider['name'] ?? '').toLowerCase();
                  bool matchesQuery = name.contains(_searchQuery);
                  bool inProposals = proposalEmails.contains(email);
                  return matchesQuery && inProposals;
                }).toList();

                return Padding(
                  padding: const EdgeInsets.only(left:18.0,right:18),
                  child: GridView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      var provider = filteredProviders[index];
                      return Padding(
                        padding: const EdgeInsets.only(left:28.0,right:9,top:10),
                        child: buildProviderCard(provider),
                      );
                    }, gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                      childAspectRatio: 1.12
                  
                    )
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
          padding: const EdgeInsets.all(16.0),
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
                        Text(
                          country,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
  }