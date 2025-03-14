import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvProvTasks extends StatefulWidget {
  final bool desc;
  final List<QueryDocumentSnapshot> filteredProviders;

  const AdvProvTasks({
    super.key,
    required this.filteredProviders,
    required this.desc,
  });

  @override
  State<AdvProvTasks> createState() => _AdvProvTasksState();
}

class _AdvProvTasksState extends State<AdvProvTasks> {
  // Map to store the number of completed tasks for each provider
  final Map<String, int> _completedTasksCount = {};

  @override
  void initState() {
    super.initState();
    // Fetch the number of completed tasks for each provider
    _fetchCompletedTasksCount();
  }

  // Fetch the number of completed tasks for each provider
  Future<void> _fetchCompletedTasksCount() async {
    for (final provider in widget.filteredProviders) {
      final String email = provider['email'] ?? '';
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: 'done')
          .get();

      setState(() {
        _completedTasksCount[email] = snapshot.size;
      });
    }
  }

  // Sort providers based on the number of completed tasks
  List<QueryDocumentSnapshot> _sortProviders(List<QueryDocumentSnapshot> providers, bool desc) {
    providers.sort((a, b) {
      final int countA = _completedTasksCount[a['email'] ?? ''] ?? 0;
      final int countB = _completedTasksCount[b['email'] ?? ''] ?? 0;
      return desc ? countB.compareTo(countA) : countA.compareTo(countB);
    });
    return providers;
  }

  @override
  Widget build(BuildContext context) {
    // Sort the providers based on the number of completed tasks
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
          final String email = provider['email'] ?? '';
          final int completedTasks = _completedTasksCount[email] ?? 0;

          return _buildProviderCard(provider, completedTasks);
        },
      ),
    );
  }

  Widget _buildProviderCard(QueryDocumentSnapshot provider, int completedTasks) {
    String name = provider['name'] ?? 'لا يوجد اسم';
    String imageUrl = provider['image'] ?? '';
    String email = provider['email'] ?? 'لا يوجد بريد';
    String phone = provider['phone'] ?? '';
    double rating = provider['rating'] ?? 0.0;

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
            Text('البريد: $email', style: GoogleFonts.cairo()),
            const SizedBox(height: 6),
            Text('الهاتف: $phone', style: GoogleFonts.cairo()),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  "التقييم: ",
                  style: GoogleFonts.cairo(),
                ),
                RatingBar.builder(
                  initialRating: rating,
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
                  " (${rating.toStringAsFixed(1)})",
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'عدد المهام المكتملة: $completedTasks',
              style: GoogleFonts.cairo(
                fontSize: 24,fontWeight:FontWeight.bold,color:Colors.blue
              ),
            ),
          ],
        ),
      ),
    );
  }
}