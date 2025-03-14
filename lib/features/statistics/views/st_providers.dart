




// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_details.dart';
import 'package:yemen_services_dashboard/features/statistics/controller/st_controller.dart';
import 'package:yemen_services_dashboard/features/users/user_details.dart';
import '../../orders/model/proposal.dart';
import '../../users/users_screen.dart';
import 'users_view.dart';

class StProvidersView extends StatefulWidget {

String email;

StProvidersView({super.key,required this.email});

  @override
  State<StProvidersView> createState() => _WorkerTasksState();
}

void showDeleteDialog(BuildContext context,String id,String status) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('تأكيد العملية'),
        content: const Text('هل أنت متأكد أنك الغاء الطلب ؟'),
        actions: <Widget>[
          TextButton(
            child: const Text('الغاء', style: TextStyle(color: Colors.red)),
            onPressed: () {
              updateWorkerStatus(status,id);
              Navigator.of(context).pop();
              Get.snackbar('', 'تم  بنجاح',
                  backgroundColor:Colors.green,
                  colorText:Colors.white);
            },
          ),
          TextButton(
            child: const Text('الغاء', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

String getFormattedDateTime(DateTime date) {
  // Format the date as needed, e.g., "October 29, 2024 - 2:30 PM"
  return DateFormat('MMMM dd, yyyy - h:mm a').format(date);
}


Future<void> updateWorkerStatus(String status,String id)
async {
  StController controller
  =Get.put(StController());
  try {
    // Reference the 'buyService' collection
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('proposals');
    // Query documents where 'worker_email' matches the provided email
    QuerySnapshot querySnapshot =
    await collectionRef
        .where('id', isEqualTo: id)
        .get();
    // Loop through the documents to update each one's status to 'done'
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'status': status});
    }
    controller.getWorkerProposal();
  } catch (e) {
    print("Error updating status: $e");
  }
}

StController controller =
Get.put(StController());


QueryDocumentSnapshot ?user;
QueryDocumentSnapshot ?provider;

Future<QueryDocumentSnapshot?> getUserDataByEmail(String email) async {
  try {
    // Reference to the collection
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    // Query Firestore to find the user by email
    QuerySnapshot querySnapshot =
    await usersCollection.where('email', isEqualTo: email).get();

    // Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {

      user=querySnapshot.docs.first;
      // Return the first matching document
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
    // Reference to the collection
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('serviceProviders');

    // Query Firestore to find the user by email
    QuerySnapshot querySnapshot =
    await usersCollection.where('email', isEqualTo: email).get();

    // Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {

      provider=querySnapshot.docs.first;
      // Return the first matching document
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


// ignore: must_be_immutable
class TasksNewWidget extends StatelessWidget {
  Proposal task;
  TasksNewWidget({super.key,required this.task});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration:BoxDecoration(
          border: Border.all(color:primary,
              width: 0.3
          ),
          borderRadius: BorderRadius.circular(23),
          color:cardColor.withOpacity(0.2),
        ),
        child:Column(children: [
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius:BorderRadius.circular(13),
            child: CachedNetworkImage(
                height: 95,
                width: 222,
                imageUrl: task.image,
                fit:BoxFit.contain,
                placeholder: (context, url) =>
                const Icon(Icons.ad_units_outlined,
                  size: 44,color:primaryColor,
                ),

                errorWidget: (context, url, error) =>
                const Icon(Icons.ad_units_outlined,
                  size: 44,color:primaryColor,
                )
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "عنوان العمل المطلوب : ${task.title}",
            style: const TextStyle(
                color: primaryColor,
                fontSize: 17,fontWeight:FontWeight.w600
            ),
          ),
          // getFormattedDateTime(DateTime.parse(task.date))
          //                                   .replaceAll('- 12:00 AM', ''),
          const SizedBox(height: 8),
          Text(
              getFormattedDateTime(DateTime.parse(task.date)).replaceAll('- 12:00 AM', ''),
            style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,fontWeight:FontWeight.w400
            ),
          ),


          (task.dateEndTask.length>2)?
           Text(
             "تاريخ الانتهاء : "+task.dateEndTask.substring(0,10),
            //"تاريخ الانتهاء : " + getFormattedDateTime(DateTime.parse(task.endDate)).replaceAll('- 12:00 AM', ''),
            style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,fontWeight:FontWeight.w400
            ),
          ): Text(
            '',
            //"تاريخ الانتهاء : " +   getFormattedDateTime(DateTime.parse(task.date2)).replaceAll('- 12:00 AM', ''),
            style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,fontWeight:FontWeight.w400
            ),
          ),
          const SizedBox(height: 9,),
          Container(
            decoration:BoxDecoration(
              borderRadius:BorderRadius.circular(12),
              color:greyTextColor.withOpacity(0.4),
            ),
            child:Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  const SizedBox(height: 1,),
                  Text('تفاصيل موقع الخدمة ',
                    style:TextStyle(
                        color: secondaryTextColor,fontSize: 18
                    ),
                  ),


                  Text("اسم الموقع : ${task.locationName}",
                    style:TextStyle(
                        color:secondaryTextColor,
                        fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text(" تفاصيل الموقع  : ${task.locationDes}",
                    style:TextStyle(
                        color:secondaryTextColor,
                        fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 5,),

                  InkWell(
                    child: Row(

                      children: [
                        const SizedBox(width: 12,),
                        Icon(Icons.location_on_rounded,
                          color:secondaryTextColor,
                        ),
                        const SizedBox(width: 12,),
                        Text
                          ('عرض الموقع علي الخريطة',
                          style:TextStyle(
                              decoration: TextDecoration.underline,
                              color:primary,
                              fontSize: 20
                          ),
                        ),
                      ],
                    ),
                    onTap:(){
                      StController controller
                      =Get.put(StController());

                      controller.openMap(double.parse(task.lat),
                          double.parse(task.lng));
                    },
                  )


                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Text('السعر  :   ',
                style:TextStyle(
                    color:secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
              Text("${task.price} ",
                style:TextStyle(
                    color:secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text( ' حالة الطلب :',
                style:TextStyle(
                    fontWeight: FontWeight.w600,
                    color:secondaryTextColor,
                    fontSize: 18
                ),
              ),

              const   SizedBox(width: 9,),
              if (task.status == 'قيد المراجعة'
                  || task.status == 'pending'
              )
                Text('مهام مطروحة ',
                  style:TextStyle(
                      color:secondaryTextColor,
                      fontSize: 17,fontWeight: FontWeight.w600
                  ),
                ),


              if (task.status == 'accepted'
              )
                const Text('مهام قيد التنفيذ',
                  style:TextStyle(
                      color:Colors.green,
                      fontSize: 22,fontWeight: FontWeight.w600
                  ),
                ),
              if (task.status == 'canceled')
                const Text('مهام ملغاه',
                  style:TextStyle(
                      color:Colors.red,
                      fontSize: 22,fontWeight: FontWeight.w600
                  ),
                ),
              //done
              if (task.status == 'done')
                const Text('مهام مكتملة',
                  style:TextStyle(
                      color:Colors.green,
                      fontSize: 22,fontWeight: FontWeight.w600
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          InkWell(
            child: Container(
              decoration:BoxDecoration(
                  borderRadius:BorderRadius.circular(13),
                  color:Colors.grey[200]
              ),
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text('اسم مقدم الخدمة : ${task.name}',
                    style:const TextStyle(color:Colors.black,
                        fontSize: 17,fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 6,),
                  Text('بريد مقدم الخدمة : ${task.email}',
                    style:const TextStyle(color:Colors.black,
                        fontSize: 17,fontWeight: FontWeight.bold
                    ),
                  )
                ],),
              ),
            ),
            onTap:(){
              getProviderDataByEmail(task.email).then((v){
                Get.to(ProviderDetails(provider: provider!
                ));
              });
            },
          ),
          const SizedBox(height: 12),
          const  Divider(),
          const SizedBox(height: 6),

           InkWell(
             child: Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                const Text('اسم المستخدم : ',
                  style:TextStyle(color:Colors.black,fontSize: 21,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12,),
                Text(task.user_name,
                  style:const TextStyle(color:Colors.black,fontSize: 17,fontWeight: FontWeight.bold),),
              ],
          ),
             onTap:(){

               getUserDataByEmail(task.user_email).then((v){
                 Get.to(UserDetails(user: user!));
               });
               // QueryDocumentSnapshot user=task.user;



             },
           ),
          // const SizedBox(height: 12),
          //  (task.status != 'done'&& task.status=='canceled')?
          // CustomButton(text: 'الغاء الطلب', onPressed: (){
          //   showDeleteDialog(
          //       context,
          //       task.id,
          //       'canceled'
          //   );

          // }):const SizedBox(),
          const SizedBox(height: 13),



        ],),
      ),
      onTap:(){

      
      },
    );
  }
}



class _WorkerTasksState extends State<StProvidersView> {



  @override
  void initState() {
    controller.getPropWithProviderEmail(widget.email);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return
      GetBuilder<StController>(
          builder: (_) {
            return Scaffold(
              backgroundColor:backgroundColor,

              appBar: AppBar(
                toolbarHeight: 90,
                elevation: 0.2,
                backgroundColor: primary,
                title: const Text(' فلتر من خلال مقدمين الخدمات ',
                style: TextStyle(color: Colors.white),
                ),
                leading: Row(
                  children: [
                    IconButton(
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

                     
                //      DropdownButton<String>(
                //   value: controller.selectedUser['name'],
                //   hint: const Text("اختر المستخدم"),
                //   items:controller.users.map((user) {
                //     return DropdownMenuItem(
                //       value: user['email'].toString(),
                //       //user['email'].toString(),
                //       child: Text(user['name'].toString()),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //  controller.filterByUser(value!);
                //   },
                // ),

                  ],
                ),

              ),
              body:
              (controller.proposalList.isNotEmpty)
                  ? Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [


                
               
                const SizedBox(height:12),



                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child:GridView.builder(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: controller.proposalList.length,
                          itemBuilder: (context, index) {
                            return
                              Padding(
                                padding: const EdgeInsets.only(left:28.0,right:28,bottom:17),
                                child: TasksNewWidget(
                                  task: controller.proposalList[index],
                                ),
                              );
                            //   ProposalWidget(
                            //   task: controller.proposalList[index],
                            // );
                          }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns in the grid
                            mainAxisSpacing: 10.0, // Spacing between rows
                            crossAxisSpacing: 10.0, // Spacing between columns
                            childAspectRatio: 1.22, // Aspect ratio of each item
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                color:backgroundColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [


                        const SizedBox(height: 40),


                        const SizedBox(height: 10),
                        Text(
                          'لا مهام قيد التنفيذ الان',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      );


  }


}







