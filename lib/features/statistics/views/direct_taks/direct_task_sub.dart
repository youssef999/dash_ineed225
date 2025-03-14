// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/statistics/controller/st_controller.dart';
import 'package:yemen_services_dashboard/features/statistics/views/task_details.dart';
import 'package:yemen_services_dashboard/features/users/user_details.dart';

class DirectTaskSub extends StatefulWidget {
  List<String> subCats;
 DirectTaskSub({super.key, required this.subCats});

  @override
  State<DirectTaskSub> createState() => _DirectTaskUserState();
}

class _DirectTaskUserState extends State<DirectTaskSub> {
  List<dynamic> filteredTasks = [];
  StController controller = Get.put(StController(), permanent: true);

  @override
  void initState() {
    super.initState();
    controller. getTasksWithSubCats(widget.subCats);
   // filterTasks();
  }

  void filterTasks() {
    setState(() {
      filteredTasks = controller.tasksList.where((task) {
        List<dynamic> taskCategories = task['sub_cat'] ?? [];
        return widget.subCats.any((subCat) => taskCategories.contains(subCat));
      }).toList();
    });
    print("F===${filteredTasks.length}");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 90,
            elevation: 0.2,
            backgroundColor: primary,
            title: const Text('المهام المتاحة', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: controller.tasksList.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: controller.tasksList.length,
                        itemBuilder: (context, index) {
                          final task = controller.tasksList[index];
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TasksNewWidget(task: task),
                          );
                        },
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 7.0,
                          crossAxisSpacing: 7.0,
                          childAspectRatio: 1.64,
                        ),
                      )
                    : Center(
                        child: Text(
                          'لا يوجد مهام',
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

class TasksNewWidget extends StatelessWidget {
  final Map<String, dynamic> task;

  TasksNewWidget({super.key, required this.task});

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
                  placeholder: (context, url) => const Icon(Icons.ad_units_outlined, size: 44, color: primaryColor),
                  errorWidget: (context, url, error) => const Icon(Icons.ad_units_outlined, size: 44, color: primaryColor)),
            ),
            const SizedBox(height: 8),
            Text(
              "عنوان العمل المطلوب : ${task['title']}",
              style: const TextStyle(color: primaryColor, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              getFormattedDateTime((task['current_date'] as Timestamp).toDate()).replaceAll(' - 12:00 AM', ''),
              style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w400),
            ),
            (task['dateEndTask'] != null)
                ? Text(
                    "تاريخ انتهاء المهمة : ${getFormattedDateTime((task['dateEndTask'] as Timestamp).toDate()).replaceAll(' - 12:00 AM', '')}",
                    style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w400),
                  )
                : const SizedBox(),
            const SizedBox(height: 9),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: greyTextColor.withOpacity(0.4)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    const SizedBox(height: 1),
                    Text(
                      'تفاصيل موقع الخدمة',
                      style: TextStyle(color: secondaryTextColor, fontSize: 18),
                    ),
                    Text(
                      "اسم الموقع : ${task['address']}",
                      style: TextStyle(color: secondaryTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      " تفاصيل الموقع  : ${task['locationDescription']}",
                      style: TextStyle(color: secondaryTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.location_on_rounded, color: secondaryTextColor),
                          const SizedBox(width: 12),
                          Text(
                            'عرض الموقع علي الخريطة',
                            style: TextStyle(decoration: TextDecoration.underline, color: primary, fontSize: 20),
                          ),
                        ],
                      ),
                      onTap: () {
                        StController controller = Get.put(StController());
                        controller.openMap(double.parse(task['lat']), double.parse(task['lng']));
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' حالة الطلب :',
                  style: TextStyle(fontWeight: FontWeight.w600, color: secondaryTextColor, fontSize: 18),
                ),
                const SizedBox(width: 9),
                if (task['status'] == 'قيد المراجعة' || task['status'] == 'pending')
                  Text(
                    'مهام مطروحة',
                    style: TextStyle(color: secondaryTextColor, fontSize: 17, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'اسم المستخدم : ',
                      style: TextStyle(color: Colors.black, fontSize: 21, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      task['user_name'],
                      style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              onTap: () {
                getUserDataByEmail(task['user_email']).then((v) {
                  Get.to(UserDetails(user: user!));
                });
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      onTap: () {
        // Get.to(ViewTask1(proposal: task,));
        //PropsalsNew
        // Get.to(PropsalsNew(
        //   task: task,
        //   proposalIndex: 1,
        // ));
      },
    );
  }
}


String getFormattedDateTime(DateTime date) {
  return DateFormat('MMMM dd, yyyy - h:mm a').format(date);
}