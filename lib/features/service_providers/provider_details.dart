import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class ProviderDetails extends StatefulWidget {
  final QueryDocumentSnapshot provider;

  // ignore: use_super_parameters
  const ProviderDetails({Key? key, required this.provider}) : super(key: key);

  @override
  State<ProviderDetails> createState() => _ProviderDetailsState();
}

class _ProviderDetailsState extends State<ProviderDetails> {
  int numTasks = 0;
  int numTasksDone = 0;
  int numTasksPending = 0;
  int numTasksAccepted = 0;
  int numTasksCancelled = 0;
  int numComments = 0;
  double averageRating = 0.0;
  int numBuyService = 0;
  int numBuyServiceDone = 0;
  int numBuyServicePending = 0;
  int numBuyServiceAccepted = 0;
  int numBuyServiceCanceled = 0;
  List<Map<String, dynamic>> commentsList = [];

  @override
  void initState() {
    super.initState();
    _fetchProviderStats();
    _fetchBuyServiceStats(widget.provider['email']);
  }

  Future<void> _fetchProviderStats() async {
    String email = widget.provider['email'];

    try {
      // Fetch all tasks
      var tasksSnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('email', isEqualTo: email)
          .get();

      var tasks = tasksSnapshot.docs;
      setState(() {
        numTasks = tasks.length;
        numTasksDone = tasks.where((task) => task['status'] == 'done').length;
        numTasksAccepted =
            tasks.where((task) => task['status'] == 'accepted').length;
        numTasksCancelled =
            tasks.where((task) => task['status'] == 'canceled').length;
        numTasksPending =
            tasks.where((task) => task['status'] == 'pending').length;
      });

      // Fetch comments
      var commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('worker_email', isEqualTo: email)
          .get();

      var comments = commentsSnapshot.docs;
      setState(() {
        numComments = comments.length;
        averageRating = comments.isNotEmpty
            ? comments.map((c) => c['rate'] ?? 0).reduce((a, b) => a + b) /
                comments.length
            : 0.0;

        commentsList = comments
            .map((c) => {
                  'email': c['email'] ?? '',
                  'comment': c['comment'] ?? '',
                  'rate': c['rate'] ?? 0.0
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching provider stats: $e");
    }
  }

  Future<void> _fetchBuyServiceStats(String email) async {
    try {
      // Fetch all buyService entries for the provider
      var buyServiceSnapshot = await FirebaseFirestore.instance
          .collection('buyService')
          .where('worker_email', isEqualTo: email)
          .get();

      var buyServices = buyServiceSnapshot.docs;
      setState(() {
        numBuyService = buyServices.length;
        numBuyServiceDone =
            buyServices.where((service) => service['status'] == 'done').length;
        numBuyServicePending =
            buyServices.where((service) => service['status'] == 'pending').length;
        numBuyServiceAccepted =
            buyServices.where((service) => service['status'] == 'accepted').length;
        numBuyServiceCanceled =
            buyServices.where((service) => service['status'] == 'canceled').length;
      });
    } catch (e) {
      print("Error fetching buyService stats: $e");
    }
  }

  Widget _buildStatItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primary,
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
          widget.provider['name'],
          style: const TextStyle(color: Colors.white, fontSize: 21),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left:36,right:22,top:15,bottom:5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile and Stats Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Expanded(
                  flex: 2,
                  child: Card(
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
                                radius: 40,
                                backgroundImage: widget.provider['image'].isNotEmpty
                                    ? NetworkImage(widget.provider['image'])
                                    : const AssetImage(
                                            'assets/images/default_avatar.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.provider['name'] ?? '',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.provider['email'] ?? '',
                                      style: GoogleFonts.cairo(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.provider['country'] ?? '',
                                          style: GoogleFonts.cairo(color: Colors.grey[700]),
                                        ),
                                        const SizedBox(width: 22),
                                        Text(
                                          widget.provider['city'] ?? '',
                                          style: GoogleFonts.cairo(color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem('إجمالي المهام', numTasks),
                          _buildStatItem('مكتملة', numTasksDone),
                          _buildStatItem('قيد الانتظار', numTasksAccepted),
                          _buildStatItem('مطروحة', numTasksPending),
                          _buildStatItem('مرفوضة', numTasksCancelled),
                          const SizedBox(height: 9),
                          _buildStatItem('التعليقات', numComments),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "التقييم : ",
                                style: GoogleFonts.cairo(),
                              ),
                              RatingBar.builder(
                                initialRating: averageRating,
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
                                " (${averageRating.toStringAsFixed(1)})",
                                style: GoogleFonts.cairo(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // BuyService Statistics Card
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إحصائيات الطلبات المباشرة',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem('إجمالي الطلبات', numBuyService),
                          _buildStatItem('مكتملة', numBuyServiceDone),
                          _buildStatItem('قيد الانتظار', numBuyServicePending),
                          _buildStatItem('مقبولة', numBuyServiceAccepted),
                          _buildStatItem('ملغاة', numBuyServiceCanceled),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Comments Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التعليقات والتقييمات',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (commentsList.isEmpty)
                      Center(
                        child: Text(
                          'لا توجد تعليقات',
                          style: GoogleFonts.cairo(color: Colors.grey[700]),
                        ),
                      )
                    else
                      ...commentsList.map((comment) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.person, color: primary),
                              title: Text(
                                comment['email'],
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                comment['comment'],
                                style: GoogleFonts.cairo(),
                              ),
                              trailing: RatingBar.builder(
                                initialRating: (comment['rate'] ?? 0).toDouble(),
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 16.0,
                                ignoreGestures: true,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}