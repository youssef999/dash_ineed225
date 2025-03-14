import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/statistics/buy_service/buy_service_providers.dart';

class ProviderBuyScreen extends StatefulWidget {
  const ProviderBuyScreen({super.key});

  @override
  _ProvidersWithRatingsScreenState createState() => _ProvidersWithRatingsScreenState();
}

class _ProvidersWithRatingsScreenState extends State<ProviderBuyScreen> {
  String _searchQuery = '';
  bool _isSearching = true;
  Set<String> buyServiceEmails = {};

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

      setState(() {
        buyServiceEmails = buyServiceSnapshot.docs
            .map((doc) => doc['worker_email'] as String)
            .toSet();
      });
    } catch (e) {
      print('Error fetching buyService emails: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String email) async {
  try {
    // Query the users collection for the document with the matching email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1) // Limit to 1 document since emails are unique
        .get();

    // Check if a document was found
    if (querySnapshot.docs.isNotEmpty) {
      // Return the user data as a Map
      return {
        'id': querySnapshot.docs.first.id, // Document ID
        ...querySnapshot.docs.first.data() as Map<String, dynamic>, // User data
      };
    } else {
      // No user found with the given email
      print('No user found with email: $email');
      return null;
    }
  } catch (e) {
    // Handle any errors
    print('Error fetching user data: $e');
    return null;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'مقدمين الخدمات',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 30, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(left: 96, right: 29,top:34),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase(); // Normalize search query
                  });
                },
                decoration: InputDecoration(
                  labelText: 'ابحث عن مقدم خدمة',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                  suffixIcon: const Icon(Icons.search, color: primaryColor),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: GoogleFonts.cairo(),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('serviceProviders')
                  .orderBy('rating', descending: true) // Sort by rating
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد مقدمي خدمات',
                      style: GoogleFonts.cairo(fontSize: 18),
                    ),
                  );
                }

                // Filter providers based on the buyService emails and search query
                var filteredProviders = snapshot.data!.docs.where((provider) {
                  String email = provider['email'] ?? '';
                  String name = (provider['name'] ?? '').toLowerCase();

                  return buyServiceEmails.contains(email) &&
                      (name.contains(_searchQuery) || email.contains(_searchQuery));
                }).toList();

                return Padding(
                   padding: const EdgeInsets.only(left:38.0,right:18,bottom: 17,top:12),
                  child: ListView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      var provider = filteredProviders[index];
                      return Padding(
                        padding: const EdgeInsets.only(left:38.0,right:18,bottom: 17,top:12),
                        child: _buildProviderCard(provider),
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

  Widget _buildProviderCard(QueryDocumentSnapshot provider) {
    String name = provider['name'] ?? 'لا يوجد اسم';
    String imageUrl = provider['image'] ?? '';
    double rating = (provider['rating'] ?? 0).toDouble();

    return Card(
      elevation: 4, // Add shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(ServicesBuyWithProviders(email: provider['email']));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'التقييم: ${rating.toStringAsFixed(2)}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}