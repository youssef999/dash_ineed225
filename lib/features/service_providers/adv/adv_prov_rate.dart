import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvRatingProviders extends StatefulWidget {
  final bool desc;
  final List<QueryDocumentSnapshot> filteredProviders;

  const AdvRatingProviders({
    super.key,
    required this.desc,
    required this.filteredProviders,
  });

  @override
  State<AdvRatingProviders> createState() => _AdvRatingProvidersState();
}

class _AdvRatingProvidersState extends State<AdvRatingProviders> {
  // Sort providers based on rating
  List<QueryDocumentSnapshot> _sortProviders(List<QueryDocumentSnapshot> providers, bool desc) {
    providers.sort((a, b) {
      final double ratingA = a['rating'] ?? 0.0;
      final double ratingB = b['rating'] ?? 0.0;
      return desc ? ratingB.compareTo(ratingA) : ratingA.compareTo(ratingB);
    });
    return providers;
  }

  @override
  Widget build(BuildContext context) {
    // Sort the providers based on the `desc` parameter
    final sortedProviders = _sortProviders(widget.filteredProviders, widget.desc);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقدمين الخدمات',
          style: GoogleFonts.cairo(),
        ),
      ),
      body: ListView.builder(
        itemCount: sortedProviders.length,
        itemBuilder: (context, index) {
          final provider = sortedProviders[index];
          return _buildProviderCard(provider);
        },
      ),
    );
  }

  Widget _buildProviderCard(QueryDocumentSnapshot provider) {
    String name = provider['name'] ?? 'لا يوجد اسم';
    String imageUrl = provider['image'] ?? '';
    String email = provider['email'] ?? 'لا يوجد بريد';
    String phone = provider['phone'] ?? '';
    String country = provider['country'] ?? '';

    return Card(
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
                  initialRating: provider['rating'] ?? 0.0,
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
          ],
        ),
      ),
    );
  }
}