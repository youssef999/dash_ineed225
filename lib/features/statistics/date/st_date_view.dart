import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/orders/model/proposal.dart';
import 'package:yemen_services_dashboard/features/statistics/cat/st_cat_view.dart';
import '../controller/st_controller.dart';

class StDateView extends StatefulWidget {
  const StDateView({super.key});

  @override
  State<StDateView> createState() => _StCatsViewState();
}

class _StCatsViewState extends State<StDateView> {
  DateTime? selectedDate;
  final StController controller = Get.put(StController());

  @override
  void initState() {
    super.initState();
    getProposalsAfterDate(null); // Fetch all proposals initially
  }

  Future<void> getProposalsAfterDate(DateTime? date) async {
    try {
      // Clear the existing list
      controller.proposalList.clear();

      QuerySnapshot querySnapshot;

      if (date != null) {
        // Subtract one day from the provided date
        DateTime previousDate = date.subtract(Duration(days: 1));

        // Query Firestore for proposals with 'task_date' greater than or equal to the previous day
        querySnapshot = await FirebaseFirestore.instance
            .collection('proposals')
            .where('task_date', isGreaterThanOrEqualTo: previousDate.toIso8601String())
            .get();
      } else {
        // If no date is selected, fetch all proposals
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

      // Print the number of filtered proposals loaded
      print("Proposals loaded: ${controller.proposalList.length}");
    } catch (e) {
      // Handle any errors
      print("Error fetching proposals: $e");
    }
  }

  void selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      // Remove the locale parameter for web compatibility
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      // Display localized date using intl package for formatting
      String localizedDate = DateFormat.yMMMd().format(pickedDate);
      print("Selected Date (localized): $localizedDate");

      await getProposalsAfterDate(pickedDate);
    }
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
              'فلتر حسب التاريخ',
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
              // Date Picker Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: selectDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'عرض جميع المهام (اختر تاريخًا للتصفية)'
                        : 'التاريخ المختار: ${DateFormat.yMMMd().format(selectedDate!)}',
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
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
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