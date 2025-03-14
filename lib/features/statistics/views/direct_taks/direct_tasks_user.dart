// ignore_for_file: must_be_immutable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/statistics/controller/st_controller.dart';
import 'package:yemen_services_dashboard/features/users/user_details.dart';

class DirectTaskUser extends StatefulWidget {
  String statusType;
  String title;
  DirectTaskUser({super.key, required this.statusType, required this.title});

  @override
  State<DirectTaskUser> createState() => _DirectTaskUserState();
}

class _DirectTaskUserState extends State<DirectTaskUser> {
  String? selectedUserEmail;
  List<QueryDocumentSnapshot> usersList = [];
  List<dynamic> filteredTasks = [];
  StController controller = Get.put(StController(), permanent: true);

  @override
  void initState() {
    super.initState();
    controller.getAllUsers();
    controller.getTasks();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        usersList = querySnapshot.docs;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void filterTasks() {
    setState(() {
      if (selectedUserEmail == null) {
        filteredTasks = controller.tasksList;
      } else {
        filteredTasks = controller.tasksList
            .where((task) => task['user_email'] == selectedUserEmail)
            .toList();
      }
    });
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
            title: Text(widget.title, style: const TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: selectedUserEmail,
                  hint: const Text('اختر المستخدم'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUserEmail = newValue;
                      filterTasks();
                    });
                  },
                  items: usersList.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['email'],
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: user['image'],
                            width: 30,
                            height: 30,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          const SizedBox(width: 10),
                          Text(user['name']),
                          const SizedBox(width: 10),
                          Text(user['email']),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filteredTasks.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(top:18.0,right:15,left:15
                            ,bottom:15),
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

Future<void> updateWorkerStatus(String status, String id) async {
  StController controller = Get.put(StController());
  try {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('tasks');
    QuerySnapshot querySnapshot = await collectionRef.where('id', isEqualTo: id).get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'status': status});
    }
    controller.getWorkerProposal();
  } catch (e) {
    print("Error updating status: $e");
  }
}

StController controller = Get.put(StController(), permanent: true);

QueryDocumentSnapshot? user;
QueryDocumentSnapshot? provider;

Future<QueryDocumentSnapshot?> getUserDataByEmail(String email) async {
  try {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await usersCollection.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      user = querySnapshot.docs.first;
      return querySnapshot.docs.first;
    } else {
      print('No user found with email: $email');
      return null;
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}

Future<QueryDocumentSnapshot?> getProviderDataByEmail(String email) async {
  try {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('serviceProviders');
    QuerySnapshot querySnapshot = await usersCollection.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      provider = querySnapshot.docs.first;
      return querySnapshot.docs.first;
    } else {
      print('No user found with email: $email');
      return null;
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}