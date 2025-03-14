import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<Map<String, int>> fetchStatistics() async {
    final doc = await FirebaseFirestore.instance
        .collection('statistics')
        .doc('1')
        .get();

    return {
      'acceptedServices': doc['numberOfAcceptedServices'] ?? 0,
      'canceledServices': doc['numberOfCanceledServices'] ?? 0,
      'serviceProviders': doc['numberOfServiceProviders'] ?? 0,
      'users': doc['numberOfUsers'] ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('احصائيات', style: GoogleFonts.cairo()),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final stats = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: _buildStatisticCard('خدمات مقبولة',
                        stats['acceptedServices']!, primaryColor),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: _buildStatisticCard('خدمات ملغية',
                        stats['canceledServices']!, Colors.black),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: _buildStatisticCard('مقدمي الخدمات',
                        stats['serviceProviders']!, primaryColor),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: _buildStatisticCard(
                        'عدد المستخدمين', stats['users']!, Colors.black),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatisticCard(String title, int value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            '$value',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
