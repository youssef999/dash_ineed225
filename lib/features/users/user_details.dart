import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

// ignore: must_be_immutable
class UserDetails extends StatefulWidget {
  //Map<String, dynamic> user;
  final QueryDocumentSnapshot user;

  const UserDetails({super.key, required this.user});
  @override
  State<UserDetails> createState() => _UserDetailsState();
}


int numDirectRequests = 0;
int numDirectRequestsDone = 0;
int numDirectRequestsPending = 0;
int numDirectRequestsAccepted = 0;
int numDirectRequestsCanceled = 0;

class _UserDetailsState extends State<UserDetails> {
  int numTasks = 0;
  int numTasksDone = 0;
  int numTasksPending = 0;
  int numTasksAccepted = 0;
  int numTasksFailed = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> commentsList = [];

  @override
  void initState() {
    print("USER====${widget.user}");
    super.initState();
    fetchUserStats();
    fetchUserComments();
    fetchDirectRequestsStats();
  }

  Future<void> fetchUserStats() async {
    String email = widget.user['email'];

    try {
      // Fetch task stats by status
      QuerySnapshot allTasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email', isEqualTo: email)
          .get();

      QuerySnapshot doneTasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'done')
          .get();

      QuerySnapshot pendingTasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'pending')
          .get();

      QuerySnapshot acceptedTasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'accepted')
          .get();

      QuerySnapshot failedTasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'canceled')
          .get();

      setState(() {
        numTasks = allTasks.size;
        numTasksDone = doneTasks.size;
        numTasksPending = pendingTasks.size;
        numTasksAccepted = acceptedTasks.size;
        numTasksFailed = failedTasks.size;
      });
    } catch (e) {
      print("Error fetching task stats: $e");
    }
  }

  Future<void> fetchUserComments() async {
    try {
      String email = widget.user['email'];
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('email', isEqualTo: email)
          .get();

      setState(() {
        commentsList = querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  Future<void> fetchDirectRequestsStats() async {
    String email = widget.user['email'];

    try {
      // Fetch direct requests stats by status
      QuerySnapshot allDirectRequests = await FirebaseFirestore.instance
          .collection('buyService')
          .where('user_email', isEqualTo: email)
          .get();

      QuerySnapshot doneDirectRequests = await FirebaseFirestore.instance
          .collection('buyService')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'done')
          .get();

      QuerySnapshot pendingDirectRequests = await FirebaseFirestore.instance
          .collection('buyService')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'pending')
          .get();

      QuerySnapshot acceptedDirectRequests = await FirebaseFirestore.instance
          .collection('buyService')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'accepted')
          .get();

      QuerySnapshot canceledDirectRequests = await FirebaseFirestore.instance
          .collection('buyService')
          .where('user_email', isEqualTo: email)
          .where('status', isEqualTo: 'canceled')
          .get();

      setState(() {
        numDirectRequests = allDirectRequests.size;
        numDirectRequestsDone = doneDirectRequests.size;
        numDirectRequestsPending = pendingDirectRequests.size;
        numDirectRequestsAccepted = acceptedDirectRequests.size;
        numDirectRequestsCanceled = canceledDirectRequests.size;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching direct requests stats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          widget.user['name'],
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.only(left:28.0,right:11),
            child: SingleChildScrollView(
                padding: const EdgeInsets.only(left:26.0,right:9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfileCard(),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left:18.0,right:18),
                      child: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceAround,
                        children: [
                          _buildTaskStatsCard(),
                          _buildDirectRequestsStatsCard(),
                        ],
                      ),
                    ),
                    //const SizedBox(height: 16.0),
                    
                    const SizedBox(height: 20.0),
                    Padding(
                     padding: const EdgeInsets.only(left:18.0,right:18),
                      child: _buildCommentsSection(),
                    ),
                  ],
                ),
              ),
          ),
    );
  }

  // User Profile Card
  Widget _buildUserProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: widget.user['image'].length > 1
                  ? NetworkImage(widget.user['image'])
                  : const AssetImage('assets/images/default_avatar.png')
              as ImageProvider,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user['name'],
                    style: GoogleFonts.cairo(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.user['email'],
                    style: GoogleFonts.cairo(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.user['phone'],
                    style: GoogleFonts.cairo(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user['country'],
                        style: GoogleFonts.cairo(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 20,),
                      Text(
                        widget.user['city'],
                        style: GoogleFonts.cairo(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Task Stats Card
  Widget _buildTaskStatsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "إحصائيات الوظائف",
              style: GoogleFonts.cairo(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildStatRow("عدد المهام"+" = ", numTasks),
            _buildStatRow("عدد المهام المكتملة"+" = ", numTasksDone),
            _buildStatRow("عدد المهام بانتظار الموافقة"+" = ", numTasksPending),
            _buildStatRow("عدد المهام قيد التنفيذ"+" = ", numTasksAccepted),
            _buildStatRow("عدد المهام المرفوضة"+" = ", numTasksFailed),
          ],
        ),
      ),
    );
  }

  // Direct Requests Stats Card
  Widget _buildDirectRequestsStatsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "إحصائيات الطلبات المباشرة",
              style: GoogleFonts.cairo(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildStatRow("عدد الطلبات المباشرة"+" = ", numDirectRequests),
            _buildStatRow("عدد الطلبات المكتملة"+" = ", numDirectRequestsDone),
            _buildStatRow("عدد الطلبات بانتظار الموافقة"+" = ", numDirectRequestsPending),
            _buildStatRow("عدد الطلبات المقبولة"+" = ", numDirectRequestsAccepted),
            _buildStatRow("عدد الطلبات المرفوضة"+" = ", numDirectRequestsCanceled),
          ],
        ),
      ),
    );
  }

  // Comments Section
  Widget _buildCommentsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "التعليقات",
              style: GoogleFonts.cairo(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            if (commentsList.isEmpty)
              Center(
                child: Text(
                  "لا توجد تعليقات",
                  style: GoogleFonts.cairo(color: Colors.grey[700]),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commentsList.length,
                separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) =>
                    _buildCommentTile(commentsList[index]),
              ),
          ],
        ),
      ),
    );
  }

  // Comment Tile
  Widget _buildCommentTile(Map<String, dynamic> comment) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        child: const Icon(Icons.comment, color: Colors.blueAccent),
      ),
      title: Text(
        comment['comment'] ?? '',
        style: GoogleFonts.cairo(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "التقييم: ${comment['rate'] ?? 'N/A'}",
        style: GoogleFonts.cairo(color: Colors.grey[600]),
      ),
    );
  }

  // Stats Row
  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 16.0, color: Colors.black87),
          ),
          Text(
            value.toString(),
            style: GoogleFonts.cairo(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}