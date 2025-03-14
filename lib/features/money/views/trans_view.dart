import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

import '../../offers/cutom_button.dart';
import 'app_comm.dart';

class TransView extends StatefulWidget {
  const TransView({super.key});

  @override
  State<TransView> createState() => _TransViewState();
}

class _TransViewState extends State<TransView> {
  List<Map<String, dynamic>> transactions = [];
  double totalAmount = 0.0;
  double appAmountTotal = 0.0;
  bool isLoading = true;
  String selectedFilter = "الكل"; // Default filter

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions({String? filter}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (filter) {
        case "آخر 24 ساعة":
          startDate = now.subtract(const Duration(days: 1));
          break;
        case "آخر أسبوع":
          startDate = now.subtract(const Duration(days: 7));
          break;
        case "آخر شهر":
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = DateTime(1970); // Fetch all data
          break;
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('wallet')
              .where('status', isEqualTo: 'x')
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
              .orderBy('date', descending: true)
              .get();

      double total = 0.0;
      double appTotal = 0.0;
      List<Map<String, dynamic>> data = [];

      for (var doc in querySnapshot.docs) {
        final transaction = doc.data();
        data.add(transaction);

        if (transaction['total'] != null) {
          total += double.parse(transaction['total']);
        }
        if (transaction['appCommotion'] != null) {
          appTotal += double.parse(transaction['appCommotion'].toString());
        }
      }

      setState(() {
        transactions = data;
        totalAmount = total;
        appAmountTotal = appTotal;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() => isLoading = false);
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("اختر الفلتر"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("الكل"),
                onTap: () {
                  setState(() => selectedFilter = "الكل");
                  fetchTransactions();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("آخر 24 ساعة"),
                onTap: () {
                  setState(() => selectedFilter = "آخر 24 ساعة");
                  fetchTransactions(filter: "آخر 24 ساعة");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("آخر أسبوع"),
                onTap: () {
                  setState(() => selectedFilter = "آخر أسبوع");
                  fetchTransactions(filter: "آخر أسبوع");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("آخر شهر"),
                onTap: () {
                  setState(() => selectedFilter = "آخر شهر");
                  fetchTransactions(filter: "آخر شهر");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 99,
        backgroundColor: primaryColor,
        title: const Text(
          "المعاملات المالية",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          Row(
            children: [
              const Text("فلتر ",style: const TextStyle(color: Colors.white),),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              width: 288,
              text: 'تعديل نسبة ارباح التطبيق', onPressed: (){
            
              Get.to(const AppCommView ());
            
            
            
            },
            
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Filter
                  Text(
                    "الفلتر المحدد: $selectedFilter",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Total Amount
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "إجمالي المعاملات المالية: ${totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // App Amount Total
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "إجمالي أرباح التطبيق: ${appAmountTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Transactions List
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final total = transaction['total'] ?? 0.0;
                        final amount = transaction['amount'] ?? 0.0;
                        final appCommotion = transaction['appCommotion'] ?? 'N/A';
                        final date = transaction['date'] != null
                            ? (transaction['date'] as Timestamp).toDate()
                            : DateTime.now();

                        return Padding(
                          padding: const EdgeInsets.only(left: 48.0, right: 12, top: 10, bottom: 9),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // Amount and App Commission
                                  Row(
                                    children: [

                                      Text(transaction['title'],
                                      style: const TextStyle(
                                        color:Colors.black,fontSize: 20,
                                        fontWeight: FontWeight.w400
                                      ),
                                      ),
                                      const SizedBox(height: 8,),

                                      // Amount
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.attach_money, color: Colors.green, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              "المبلغ: $total",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Service Provider Profit
                                  Row(
                                    children: [
                                      const Icon(Icons.business_center, color: Colors.orange, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "أرباح مقدم الخدمة: $amount",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.android, color: primaryColor, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "عمولة التطبيق: $appCommotion",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Date
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.purple, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "التاريخ: ${_formatDate(date)}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Format date to display in Arabic
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
  }
}