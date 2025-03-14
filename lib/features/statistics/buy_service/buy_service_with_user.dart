


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';
import 'package:yemen_services_dashboard/features/statistics/buy_service/buy_service_providers.dart';
import 'package:yemen_services_dashboard/features/statistics/controller/st_controller.dart';
import 'package:yemen_services_dashboard/features/users/user_details2.dart';
import '../../orders/model/proposal.dart';
import '../../service_providers/prov_details2.dart';




class ServicesBuyWithUser extends StatefulWidget {
  String email;
  ServicesBuyWithUser({super.key,required this.email});

  @override
  State<ServicesBuyWithUser> createState() => _WorkerTasksState();
}

class _WorkerTasksState extends State<ServicesBuyWithUser> {

  StController controller =
  Get.put(StController());

  @override
  void initState() {
    controller.getBuyServicesWithUserEmail(widget.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StController>(
        builder: (_) {
          if(controller.isBuyServicesLoading==false){
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                  elevation: 0.2,
                  backgroundColor: appBarColor,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  title: const Column(
                    children: [


                      SizedBox(
                        height: 10,
                      ),

                    ],
                  )),
              body:const Center(child:
              CircularProgressIndicator()
                ,),
            );
          }else{
            return Scaffold(
              backgroundColor:backgroundColor,
              //AppColors.backgroundColor,
              appBar: AppBar(
                elevation: 0.2,
                title: Text("طلبات مباشرة فلتر المستخدم",
                style: GoogleFonts.cairo(
                  fontSize: 21,color:Colors.white
                ),
                ),
                backgroundColor: appBarColor,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              body: controller.buySerivcesList.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Container(
                      height: 9,
                      color: primary,
                    ),

                   

                    const SizedBox(height: 22,),

                    Expanded(
                      child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: controller.buySerivcesList.length,
                          itemBuilder: (context, index) {
                            return
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TasksNewWidget2(
                                  task: controller.buySerivcesList[index],
                                  controller: controller,
                                ),
                              );
                          }, gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.45,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      )
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                color:backgroundColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [



                        const SizedBox(height: 34),


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

        }
    );
  }
}

String getFormattedDateTime(DateTime date) {
  // Format the date as needed, e.g., "October 29, 2024 - 2:30 PM"
  return DateFormat('MMMM dd, yyyy - h:mm a').format(date);
}

class TasksNewWidget2 extends StatelessWidget {
  StController controller;
  Proposal task;
  TasksNewWidget2({super.key,required this.task
    ,required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration:BoxDecoration(
            border:Border.all(color:primary,
                width: 0.4
            ),
            borderRadius: BorderRadius.circular(23),
            color:cardColor.withOpacity(0.2)
          //.withOpacity(0.5)
        ),
        child:Column(children: [

          ClipRRect(
            borderRadius:BorderRadius.circular(13),
            child: CachedNetworkImage(
                height: 95,
                width: 222,
                imageUrl: task.image2,
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
            "عنوان العمل المطلوب : ${task.title2}",
            style: TextStyle(
                color: secondaryTextColor,
                fontSize: 17,fontWeight:FontWeight.w600
            ),
          ),
          const SizedBox(height: 8),
          (task.date2!='null')?
          Text(
            getFormattedDateTime(DateTime.parse(task.date2))
                .replaceAll('- 12:00 AM', ''),
            style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,fontWeight:FontWeight.w400
            ),
          ):const SizedBox(),

          //  Text(
          //  "تاريخ الانتهاء :${getFormattedDateTime(DateTime.parse(task.dateEndTask))
          //       .replaceAll('- 12:00 AM', '')}",
          //   style: TextStyle(
          //       color: secondaryTextColor,
          //       fontSize: 14,fontWeight:FontWeight.w400
          //   ),
          // ),

          
          const SizedBox(height: 8),

          (task.locationName.length>1)?
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
                      controller.openMap(double.parse(task.lat),
                          double.parse(task.lng));
                    },
                  )


                ],
              ),
            ),
          ):const SizedBox(),

          const SizedBox(height: 8),
          Text("السعر : ${task.price} ",
            style:TextStyle(
                color:secondaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 15
            ),
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
                Text('مهام مطروحة',
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
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("اسم المستخدم : ${task.user_name}",
                    style:const TextStyle(color:Colors.black,fontSize: 17,fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            onTap:(){
              loadUserData(task.user_email);
              Future.delayed(const Duration(seconds: 1)).then((v){
          
            Get.to(UserDetails2(user: userData!,
              ));
              });
             

            },
          ),
          const SizedBox(height: 12,),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("مقدم الخدمة : ${task.workerEmail}",
                style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 17,fontWeight: FontWeight.w600
                ),
              ),
            ),
            onTap:(){
              getProviderData(task.workerEmail);
              Future.delayed(const Duration(seconds: 1)).then((v){
                Get.to(ProviderDetails20(provider: providerData,));
              });
            },
          ),



          // if (task.status == 'قيد المراجعة')
          //   Container(
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: Colors.red,
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: Center(
          //         child: Text( 'الغاء الطلب',
          //           style:TextStyle(
          //               color:mainTextColor,
          //               fontSize: 17,fontWeight: FontWeight.w600
          //           ),
          //         )),
          //   ),
        ],),
      ),
      onTap:(){
        //
        // Get.to(ViewTask2
        //   (proposal: task
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

