import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
// ignore: unused_import
import 'package:yemen_services_dashboard/features/orders/model/proposal.dart';
// ignore: unused_import
import 'package:yemen_services_dashboard/features/service_providers/provider_details.dart';
import 'package:yemen_services_dashboard/features/statistics/cat/cats_view.dart';
import 'package:yemen_services_dashboard/features/statistics/date/st_date_view.dart';
import 'package:yemen_services_dashboard/features/statistics/price/price_st.dart';
// ignore: unused_import
import 'package:yemen_services_dashboard/features/statistics/views/st2.dart';
import 'package:yemen_services_dashboard/features/statistics/views/users_view.dart';
import 'package:yemen_services_dashboard/features/users/user_details.dart';
// ignore: unused_import
import '../../offers/cutom_button.dart';
import '../controller/st_controller.dart';
import '../providers_screen.dart';

class WorkerTasks20 extends StatefulWidget {
  const WorkerTasks20({super.key});

  @override
  _WorkerTasksState2 createState() => _WorkerTasksState2();
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
  // Format the date as "October 29, 2024 - 2:30 PM"
  return DateFormat('MMMM dd, yyyy - h:mm a').format(date);
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







// ignore: must_be_immutable
class TasksNewWidget extends StatelessWidget {
 Map<String,dynamic>task;

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
                imageUrl: task['image'],
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
            "عنوان العمل المطلوب : ${task['title']}",
            style: const TextStyle(
                color: primaryColor,
                fontSize: 17,fontWeight:FontWeight.w600
            ),
          ),
          // getFormattedDateTime(DateTime.parse(task.date))
          //                                   .replaceAll('- 12:00 AM', ''),
          const SizedBox(height: 8),
         Text(
  getFormattedDateTime(
    (task['current_date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
  ).replaceAll(' - 12:00 AM', ''), // Remove " - 12:00 AM" if time is midnight
  style: TextStyle(
    color: secondaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
),
//dateEndTask

(task['dateEndTask']!=null)?
 Text(
 "تاريخ انتهاء المهمة"+" : "+ getFormattedDateTime(
    (task['dateEndTask'] as Timestamp).toDate(), // Convert Timestamp to DateTime
  ).replaceAll(' - 12:00 AM', ''), // Remove " - 12:00 AM" if time is midnight
  style: TextStyle(
    color: secondaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
): const SizedBox(),




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


                  Text("اسم الموقع : ${task['address']}",
                    style:TextStyle(
                        color:secondaryTextColor,
                        fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text(" تفاصيل الموقع  : ${task['locationDescription']}",
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

                      controller.openMap(double.parse(task['lat']),
                          double.parse(task['lng']));
                    },
                  )


                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment:MainAxisAlignment.center,
          //   children: [
          //     Text('السعر  :   ',
          //       style:TextStyle(
          //           color:secondaryTextColor,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 15
          //       ),
          //     ),
          //     Text("${task['price']} ",
          //       style:TextStyle(
          //           color:secondaryTextColor,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 15
          //       ),
          //     ),
          //   ],
          // ),
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
              if (task['status'] == 'قيد المراجعة'
                  || task['status'] == 'pending'
              )
                Text('مهام مطروحة ',
                  style:TextStyle(
                      color:secondaryTextColor,
                      fontSize: 17,fontWeight: FontWeight.w600
                  ),
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
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  const Text('اسم المستخدم : ',
                    style:TextStyle(color:Colors.black,fontSize: 21,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12,),
                  Text(task['user_name'],
                    style:const TextStyle(color:Colors.black,fontSize: 17,fontWeight: FontWeight.bold),),
                ],
                         ),
             ),
             onTap:(){

               getUserDataByEmail(task['user_email']).then((v){
                 Get.to(UserDetails(user: user!));
               });
               // QueryDocumentSnapshot user=task.user;



             },
           ),
          const SizedBox(height: 12),
          
          



        ],),
      ),
      onTap:(){

        // Get.to(ViewTask1(proposal: task,
        // ));
        //PropsalsNew
        // Get.to(PropsalsNew(
        //   task: task,
        //   proposalIndex: 1,
        // ));
      },
    );
  }
}



class _WorkerTasksState2 extends State<WorkerTasks20> {

  @override
  void initState() {
    //print("st=======${widget.statusType}");

   controller.getAllUsers();
   controller.getTasks();
    //controller.getWorkerProposalWithStatus(widget.statusType);
    // if(widget.statusType!='x'){
    //   controller.changeSelectedStatus(widget.statusType);
    // }else{
    //   controller.getWorkerProposal();
    //   //controller.getWorkerProposal();
    // }
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
                title: const Text('مهام مطروحة لم يتم التقدم لها',
                style:TextStyle(color: Colors.white),
                ),
                actions: [

                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Show filter dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'اختر نوع الفلتر',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Filter by Date
                                    ListTile(
                                      leading: const Icon(Icons.calendar_today, color: Colors.blue),
                                      title: const Text('فلترة حسب التاريخ'),
                                      onTap: () {
                      Navigator.of(context).pop(); // Close dialog
                      Get.to(const StDateView()); // Navigate to the Date filter screen
                                    
                                      },
                                    ),
                                    const Divider(),

                                    // Filter by Price
                                    ListTile(
                                      leading: const Icon(Icons.attach_money, color: Colors.green),
                                      title: const Text('فلترة حسب السعر'),
                                      onTap: () {
                      Navigator.of(context).pop(); // Close dialog
                      Get.to(const StPriceView()); // Navigate to the Price filter screen
                                      },
                                    ),
                                    const Divider(),

                                    // Filter by User
                                    ListTile(
                                      leading: const Icon(Icons.person, color: Colors.orange),
                                      title: const Text('فلترة حسب المستخدم'),
                                      onTap: () {

                      Navigator.of(context).pop(); // Close dialog
                      Get.to(const UsersSearchScreen()); // Navigate to User search screen
                                      },
                                    ),
                                    const Divider(),

                                    // Filter by Provider
                                    ListTile(
                                      leading: const Icon(Icons.business, color: Colors.purple),
                                      title: const Text('فلترة حسب مقدم الخدمة'),
                                      onTap: () {

                      Navigator.of(context).pop(); // Close dialog
                      Get.to(const ProviderStScreen());
                       // Navigate to Provider filter screen
                                      },
                                    ),
                                    const Divider(),

                                    // Filter by Category
                                    ListTile(
                                      leading: const Icon(Icons.category, color: Colors.teal),
                                      title: const Text('فلترة حسب التصنيف'),
                                      onTap: () {
                                        
                      Navigator.of(context).pop(); // Close dialog
                      Get.to(CatSelectionScreen()); // Navigate to Category selection screen
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.orangeAccent,
                            size: 33,
                          ),
                        ),
                      ),
                      const Text('فلتر البيانات ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,
                      
                      color:Colors.white
                      ),),
                    ],
                  ),
                ],
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
              (controller.tasksList.isNotEmpty)
                  ? Padding(
                padding: const EdgeInsets.only(left:30.0,right:25,top:10),
                child: ListView(
                  children:[

                     // Dropdown for user filtering
               
                    const SizedBox(height:12),

                    SizedBox(
                      height: 222222222,
                      child: Padding(
                        padding: const EdgeInsets.only(left:16.0,right:14,top:5),
                        child:GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.tasksList.length,
                          itemBuilder: (context, index) {
                      
                            print("index===$index"+"xxx===="+controller.tasksList[index]['status'].toString());
                            return
                              Padding(
                                padding: const EdgeInsets.only(left:45.0,right:19,top:15),
                                child: TasksNewWidget(
                                  task: controller.tasksList[index],
                                ),
                              );
                        
                          }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns in the grid
                            mainAxisSpacing: 7.0, // Spacing between rows
                            crossAxisSpacing: 7.0, // Spacing between columns
                            childAspectRatio: 1.55, // Aspect ratio of each item
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


                        const SizedBox(height: 45),

                   
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







