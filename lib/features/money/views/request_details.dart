import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class RequestDetails extends StatefulWidget {
  final String payId;

  const RequestDetails({super.key, required this.payId});

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  Map<String, dynamic>? requestData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequestDetails();
  }

Future<void> fetchRequestDetails() async {
  try {
    // Query the collection for documents where 'payId' matches widget.payId
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('moneyRequests')
        .where('payId', isEqualTo: widget.payId)
        .get();

    // Check if any documents were returned
    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document (assuming payId is unique)
      final doc = querySnapshot.docs.first;
      final data = doc.data(); // Get the data as Map<String, dynamic>

      setState(() {
        requestData = data; // Store the data in requestData
        isLoading = false; // Update loading state
      });
    } else {
      // No documents found
      setState(() {
        isLoading = false;
      });
      print("No documents found with payId: ${widget.payId}");
    }
  } catch (e) {
    // Handle any errors
    print("Error fetching request details: $e");
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          'عرض تفاصيل التحويل',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requestData == null
              ? const Center(child: Text('لا توجد بيانات'))
              : Padding(
                  padding: const EdgeInsets.only(left:38.0,right:15),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:38.0,right:15),
                        child: Column(
                          children: [
                            _buildDetailItem('الصورة الأمامية', requestData!['frontImage']),
                             _buildDetailItem('الصورة الخلفية', requestData!['backImage']),
                        _buildDetailItem('رقم الحساب الدولي (IPAN)', requestData!['IPANNumber']),
                        _buildDetailItem('المبلغ الإجمالي', requestData!['totalAmount'].toString()),
                        _buildDetailItem('طريقة التحويل', requestData!['transferMethod']),
                        _buildDetailItem('الاسم', requestData!['name']),
                        _buildDetailItem('البريد الإلكتروني', requestData!['email']),
                        _buildDetailItem('الهاتف', requestData!['phone']),
                        _buildDetailItem('المبلغ', requestData!['amount'].toString()),
                          ],
                        ),
                      ),
                     
                    ],
                  ),
                ),
    );
  }

//   Widget _buildDetailItem(String label, String value) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: ListTile(
//         title: Text(
//           label,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           value,
//           style: const TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }
Widget _buildDetailItem(String label, String value) {
  if (label == 'الصورة الأمامية' || label == 'الصورة الخلفية') {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Image.network(value, width: double.infinity, height: 200, fit: BoxFit.contain),
        ],
      ),
    );
  } else {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}}