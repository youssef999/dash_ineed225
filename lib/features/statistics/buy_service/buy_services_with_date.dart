



import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';
import 'package:yemen_services_dashboard/features/orders/model/proposal.dart';
import 'package:yemen_services_dashboard/features/service_providers/prov_details2.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_details.dart';
import 'package:yemen_services_dashboard/features/statistics/buy_service/buy_service_providers.dart';
import 'package:yemen_services_dashboard/features/statistics/cat/st_cat_view.dart';
import 'package:yemen_services_dashboard/features/users/user_details2.dart';
import '../controller/st_controller.dart';

class StDateBuyService extends StatefulWidget {
  const StDateBuyService({super.key});

  @override
  State<StDateBuyService> createState() => _StCatsViewState();
}

class _StCatsViewState extends State<StDateBuyService> {
  DateTime? selectedDate;
  final StController controller = Get.put(StController());

  @override
  void initState() {
    getProposals();
    super.initState();
  }

  Future<void> getProposalsAfterDate(DateTime date) async {
    print("Fetching proposals after date...");
    print('Date: ${date.toIso8601String()}');
    print('Date: ${date.toString()}');

    try {
      controller.proposalList.clear(); // Clear the existing list

      // Convert DateTime to Timestamp
      final Timestamp timestamp = Timestamp.fromDate(date);


      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buyService')
          .where('date3', isGreaterThanOrEqualTo: timestamp) // Compare with Timestamp
          .get();

      setState(() {
        controller.buySerivcesList2 = querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });



      controller.update(); // Notify the UI
      print("Filtered proposals loaded: ${controller.buySerivcesList2.length}");
    } catch (e) {
      print("Error fetching proposals: $e");
    }
  }

  Future<void> getProposals() async {
    print("Fetching all proposals...");
    try {
      controller.proposalList.clear(); // Clear the existing list
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buyService')
          .get();

      setState(() {
        controller.buySerivcesList2 = querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });


      controller.update(); // Notify the UI
      print("All proposals loaded: ${controller.proposalList.length}");
    } catch (e) {
      print("Error fetching proposals: $e");
    }
  }

  void selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
              'الطلبات المباشرة من خلال التاريخ ',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                controller.proposalList.clear();
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          selectedDate == null
                              ? 'اختر تاريخ ( سيتم عرض المهام بعد هذا التاريخ )'
                              : 'التاريخ المختار: ${DateFormat.yMMMd().format(selectedDate!)}',
                          style: const TextStyle(color: Colors.white,fontSize: 17),
                        ),
                       const  SizedBox(height: 8,),
                       const Text('سيتم عرض المهام بعد هذا التاريخ',
                       style:TextStyle(color: Colors.grey,fontSize: 12),
                      
                       ),
                     const  SizedBox(height: 8,),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: controller.buySerivcesList2.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: controller.buySerivcesList2.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left:38.0,right:12,top:12,bottom:10),
                        child: TasksNewWidget2(
                          task: controller.buySerivcesList2[index],
                        ),
                      );
                    },
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.36,
                    ),
                  ),
                )
                    : Center(
                  child: Text(
                    'لا توجد مهام بعد التاريخ المحدد',
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

String getFormattedDateTime(DateTime date) {
      // Format the date as needed, e.g., "October 29, 2024 - 2:30 PM"
      return DateFormat('MMMM dd, yyyy - h:mm a').format(date);
    }
class TasksNewWidget2 extends StatelessWidget {
  final Map<String, dynamic> task;

  const TasksNewWidget2({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: primary, width: 0.3),
          borderRadius: BorderRadius.circular(23),
          color: cardColor.withOpacity(0.2),
        ),
        child: Column(
          children: [
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CachedNetworkImage(
                height: 95,
                width: 222,
                imageUrl: task['image'],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Icon(
                  Icons.ad_units_outlined,
                  size: 44,
                  color: primaryColor,
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.ad_units_outlined,
                  size: 44,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "عنوان العمل المطلوب : ${task['title']}",
              style: const TextStyle(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 9),
            (task['offer']==false)?
             Text(
                              getFormattedDateTime(DateTime.parse(task['date'].toString()))
                                  .replaceAll('- 12:00 AM', ''),
                              //  task.date.replaceAll('00:00:00.000', ''),
                              style: TextStyle(
                                  color: greyTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ):const SizedBox(),
            const SizedBox(height: 9),

            (task['offer']==false)?
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: greyTextColor.withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    const SizedBox(height: 1),
                    Text(
                      'تفاصيل موقع الخدمة',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "اسم الموقع : ${task['locationName']}",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "تفاصيل الموقع : ${task['locationDes']}",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on_rounded,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'عرض الموقع علي الخريطة',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: primary,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        StController controller = Get.put(StController());
                        controller.openMap(
                          double.parse(task['lat']),
                          double.parse(task['lng']),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ):const SizedBox(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'السعر  :   ',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${task['price']} ",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حالة الطلب :',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 9),
                if (task['status'] == 'قيد المراجعة' || task['status'] == 'pending')
                  Text(
                    'مهام مطروحة',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (task['status'] == 'accepted')
                  const Text(
                    'مهام قيد التنفيذ',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (task['status'] == 'canceled')
                  const Text(
                    'مهام ملغاه',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (task['status'] == 'done')
                  const Text(
                    'مهام مكتملة',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'اسم مقدم الخدمة : ${task['worker_email'].toString().replaceAll('@', '')

                        .replaceAll('gmail.com', '').replaceAll('yahoo.com', '')
                        .replaceAll('outlook.com', '').replaceAll('yahoo.com', '')
                        }',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'بريد مقدم الخدمة : ${task['worker_email']}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                  
                  getProviderData(task['worker_email']);

                  Future.delayed(const Duration(seconds: 1)).then((v){
                
                  Get.to(ProviderDetails20(provider: providerData));
                });



              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 6),
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'اسم المستخدم : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    task['user_name'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onTap: () {

                loadUserData(task['user_email']);
                Future.delayed(const Duration(seconds: 1)).then((v){
                
                  Get.to(UserDetails2(user: userData!));
                });
                // Handle user details navigation
              },
            ),
            const SizedBox(height: 22),
            
          
          ],
        ),
      ),
      onTap: () {
        // Handle task tap
      },
    );
  }
}