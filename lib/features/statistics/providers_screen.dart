


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

import 'views/st_providers.dart';

class ProviderStScreen extends StatefulWidget {
  const ProviderStScreen({super.key});

  @override
  _ProvidersWithRatingsScreenState createState() => _ProvidersWithRatingsScreenState();
}

class _ProvidersWithRatingsScreenState extends State<ProviderStScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'فلتر حسب المستخدم',
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
                  .orderBy('rating', descending: true) // Sort by rating
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
                  padding: const EdgeInsets.only(left:38.0,right:32,top:42),
                  child: ListView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      var provider = filteredProviders[index];
                      return Padding(
                          padding: const EdgeInsets.only(left:38.0,right:32,bottom:15),
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

    return InkWell(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
          title: Text(
            name,
            style: GoogleFonts.cairo(),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBarIndicator(
                rating: double.parse(rating.toStringAsFixed(2)), // Limit to two decimal places
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
              ),
              Text(
                'التقييم: ${double.parse(rating.toStringAsFixed(2))}',
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      onTap: () {

        Get.to(StProvidersView(
          email: provider['email'],
        ));
      },
    );
  }
}
