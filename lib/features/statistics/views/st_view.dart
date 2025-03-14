import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_services_dashboard/features/statistics/views/st4.dart';
import '../../../core/theme/colors.dart';
import '../controller/st_controller.dart';
import 'st2.dart';
import 'work_task30.dart';

class WorkersHome extends StatefulWidget {
  const WorkersHome({super.key});

  @override
  State<WorkersHome> createState() => _WorkersHomeState();
}

class _WorkersHomeState extends State<WorkersHome> {
  
  StController controller = Get.put(StController());

  @override
  void initState() {
    //controller.fetchUsers();
    controller.getWorkerProposal();
    controller.getWorkerTask();
    controller.getWorkerBuyServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.2,
            backgroundColor: primary,
            title: const Text("احصائيات", style: TextStyle(color: Colors.white)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
               
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[200]!),
                      // Services Statistics Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              "احصائيات عن الخدمات المعروضة",
                              style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),


                      //  buildTaskRow(
                      //         "  مهام  مطروحة لم يتم التقدم لها",
                      //         controller.pendingTasks2.toString(),
                      //         'pending',
                      //         "مهام  مطروحة لم يتم التقدم لها"),

                         

                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildTaskRow(
                              "مهام  مطروحة ",
                              controller.pendingTasks.toString(),
                              'pending',
                              'مهام  مطروحة '),

                              InkWell(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left:2.0,right:2),
                            child: Container(
                              decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(12),
                                color:primary
                              ),
                              child:Padding(
                                padding: const EdgeInsets.only(left:21.0,right:21,top:21,bottom: 22),
                                child: Column(children: [
                              
                                  const Text("مهام  مطروحة لم يتم التقدم لها",
                                  style:TextStyle(color:Colors.white,fontSize: 21
                                  ,fontWeight:FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12,),
                                   Text(controller.pendingTasks2.toString(),
                                  style:const TextStyle(color:Colors.black,fontSize: 24
                                  ,fontWeight:FontWeight.bold),
                                  ),
                            
                                ],),
                              ),
                            ),
                          ),
                        ),
                        onTap:(){
                        Get.to(WorkerTasks30(title: "مهام  مطروحة لم يتم التقدم لها", statusType: '',

                        ));
                        },
                      ), 

                      buildTaskRow("مهام مكتملة", controller.doneTasks.toString(),
                          'done', 'مهام مكتملة'),
                      
                        ],
                      ),
                     
                     
                      
                      
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          buildTaskRow(
                              "مهام قيد التنفيذ",
                              controller.acceptedTasks.toString(),
                              'accepted',
                              'مهام قيد التنفيذ'),


                                             
                      buildTaskRow("مهام ملغاه", controller.refusedTasks.toString(),
                          'canceled', 'مهام ملغاه'),
                     
                        ],
                      ),
     
                     
                     
                     
                      const SizedBox(height: 9),
                      Divider(
                        height: 20,
                        thickness: 0.2,
                        color: greyTextColor,
                      ),
                      // Direct Requests Statistics Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              "احصائيات عن طلباتك المباشرة",
                              style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children: [
                          buildTaskRow(
                              "مهام  مطروحة ",
                              controller.pendingBuyTasks.toString(),
                              'pending',
                              null,
                              isDirectRequest: true),
                               buildTaskRow(
                          "مهام مكتملة",
                          controller.doneBuyTasks.toString(),
                          'done',
                          null,
                          isDirectRequest: true),
                        ],
                      ),
                     
                      Row(
                         mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children: [
                          buildTaskRow(
                              "  بانتظار الدفع مهام قيد التنفيذ",
                              controller.acceptedBuyTasks.toString(),
                              'accepted',
                              null,
                              isDirectRequest: true),

                               buildTaskRow(
                              "مهام قيد التنفيذ مكتملة الدفع",
                              controller.acceptedBuyTasks2.toString(),
                              'accepted',
                              null,
                              isDirectRequest: true),


                               buildTaskRow(
                          "مهام ملغاه",
                          controller.refusedBuyTasks.toString(),
                          'canceled',
                          null,
                          isDirectRequest: true),
                        ],
                      ),
                     
                      const SizedBox(height: 7),
                      Divider(
                        height: 20,
                        thickness: 0.2,
                        color: greyTextColor,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget for building task rows
  Widget buildTaskRow(String title, String number, String statusType,
      String? subtitle,
      {bool isDirectRequest = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          child: StWidget(txt: title, number: number),
          onTap: () {
            if (isDirectRequest) {
              Get.to(ServicesOrders(statusType: statusType,
              title: title,
              ));
            } else {
              Get.to(WorkerTasks2(
                statusType: statusType,
                title: subtitle ?? title,
              ));
            }
          },
        ),
      ],
    );
  }
}

// Widget for an empty task state
Widget _buildEmptyTaskState() {
  return Center(
    child: Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "لا يوجد مهام",
          style: TextStyle(
            color: secondaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ],
    ),
  );
}

// StWidget class
class StWidget extends StatelessWidget {
  final String txt;
  final String number;

  const StWidget({super.key, required this.txt, required this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: 310,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          color: primary.withOpacity(0.9),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            children: [
              Text(
                txt,
                style: TextStyle(
                  color: mainTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                number,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
