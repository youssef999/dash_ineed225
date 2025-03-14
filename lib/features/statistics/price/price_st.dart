import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/orders/model/proposal.dart';
import 'package:yemen_services_dashboard/features/statistics/cat/st_cat_view.dart';
import '../controller/st_controller.dart';

class StPriceView extends StatefulWidget {
  const StPriceView({super.key});

  @override
  State<StPriceView> createState() => _StPriceViewState();
}

class _StPriceViewState extends State<StPriceView> {
  double? selectedPrice;
  final StController controller = Get.put(StController());

  @override
  void initState() {
    super.initState();
    getProposalsAbovePrice(null); // Fetch all proposals initially
  }

  Future<void> getProposalsAbovePrice(double? price) async {
    try {
      // Clear the existing list
      controller.proposalList.clear();

      QuerySnapshot querySnapshot;

      if (price != null) {
        // Query Firestore for proposals with 'price2' greater than or equal to the selected price
        querySnapshot = await FirebaseFirestore.instance
            .collection('proposals')
            .where('price2', isGreaterThanOrEqualTo: price)
            .get();
      } else {
        // If no price is selected, fetch all proposals
        querySnapshot = await FirebaseFirestore.instance
            .collection('proposals')
            .get();
      }

      // Map the documents to Proposal objects
      controller.proposalList = querySnapshot.docs.map((doc) {
        return Proposal.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Notify the UI
      controller.update();

      // Print the number of proposals loaded
      print("Proposals loaded: ${controller.proposalList.length}");
    } catch (e) {
      // Handle any errors
      print("Error fetching proposals: $e");
    }
  }

  void selectPrice() async {
    TextEditingController priceController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ادخل السعر '),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'السعر سيتم عرض الخدمات فوقه',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('الغاء'),
            ),
            TextButton(
              onPressed: () {
                double? price = double.tryParse(priceController.text);
                if (price != null) {
                  setState(() {
                    selectedPrice = price;
                  });
                  getProposalsAbovePrice(price);
                  Navigator.of(context).pop();
                } else {
                  print("Invalid price entered.");
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            toolbarHeight: 90,
            elevation: 0.2,
            backgroundColor: primary,
            title: const Text(
              'فلتر حسب السعر',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                controller.proposalList.clear();
                controller.usersNames.clear();
                Get.back();
              },
            ),
          ),
          body: Column(
            children: [
              // Price Input Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: selectPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                  ),
                  child: Text(
                    selectedPrice == null
                        ? 'عرض جميع المهام (اختر سعرًا للتصفية)'
                        : 'السعر المختار: $selectedPrice',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: controller.proposalList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: controller.proposalList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TasksNewWidget(
                                task: controller.proposalList[index],
                              ),
                            );
                          },
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            childAspectRatio: 1.21,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'لا توجد مهام',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}