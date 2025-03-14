import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yemen_services_dashboard/notification_service.dart';
import '../../orders/model/proposal.dart';
import '../../orders/model/task.dart';



class UserTasksController extends GetxController {


  List<Task> userTaskList = [];
  List<Proposal> userProposalList = [];

  bool isTaskLoading=false;



  Future<String?> getWorkerFcmTokenByEmail(String email) async {
    try {
      // Query Firestore for a user document where the 'email' field matches the provided email
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('serviceProviders')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Document found, retrieve the FCM token
        DocumentSnapshot doc = snapshot.docs.first;
        String fcmToken = doc['fcmToken'] ?? '';
        return fcmToken;
      } else {
        print("No worker found with email: $email");
        return null;
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
      return null;
    }
  }



  Future<void> showDeleteConfirmationDialog(
      BuildContext context, dynamic value) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تاكيد الحذف'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('هل انت متاكد من حذف هذا العمل ؟ '),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('الغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('احذف الان '),
              onPressed: () async {
                await deleteTask(value, context);
                Navigator.of(context).pop(); // Dismiss the dialog
                // Call deleteTask if confirmed
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showCancelConfirmationDialog(
      BuildContext context, String taskId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الالغاء'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('هل تريد الغاء هذا العمل؟'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('لا'),
              onPressed: () {


                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('الغاء الان '),
              onPressed: () async {
                await cancelTask(taskId);
                Navigator.of(context).pop(); // Dismiss the dialog
                // Call deleteTask if confirmed
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelTask(String taskId) async {
    try {
      // Reference to the Firestore tasks collection
      final tasksCollection = FirebaseFirestore.instance.collection('tasks');

      // Fetch the task document by ID and update its status
      await tasksCollection.doc(taskId).update({
        'status': 'canceled',
      });

      print('Task status updated to canceled.');
      getUserTaskList();
    } catch (e) {
      print('Failed to update task status: $e');
    }
  }

  Future<void> deleteTask(dynamic value, BuildContext context) async {
    print("delete task $value");
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('id', isEqualTo: value)
          .get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('Deleted task with ID: ${doc.id}');
      //  appMessage(text: 'تم الحذف بنجاح ', fail: false, context: context);
        getUserTaskList();
      }
      print('All matching tasks deleted successfully.');
    } catch (e) {
      print('Error deleting task(s): $e');
    }
  }

  String getArabicStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Tasks at hand'.tr;
      case 'accepted':
        return 'Tasks in progress'.tr;
      case 'done':
        return 'Completed tasks'.tr;
      case 'canceled':
        return 'Canceled tasks'.tr;
      default:
        return 'حالة غير معروفة'; // "Unknown status" if the input doesn't match any case
    }
  }

  String selectedStatus= 'Tasks at hand'.tr;


  int doneTasks=0;
  int refusedTasks=0;
  int pendingTasks=0;
  int acceptedTasks=0;
  int allTasks=0;


  Future<void> getUserTaskList() async {
    doneTasks=0;
    refusedTasks=0;
    pendingTasks=0;
    acceptedTasks=0;
    allTasks=0;
    userTaskList = [];
    isTaskLoading=false;
    update();

    try {
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('user_email',
          isEqualTo: GetStorage().read('email'))
          .orderBy('date',descending: false)
          .get();

      userTaskList = querySnapshot.docs.map
        ((DocumentSnapshot doc) {
        return Task.fromFirestore(doc.data() as
        Map<String, dynamic>, doc.id);

      }).toList();

      for(int i=0;i<userTaskList.length;i++){
        if(userTaskList[i].status=='done'){
          doneTasks++;
        }
        if(userTaskList[i].status=='canceled'){
          refusedTasks++;
        }
        if(userTaskList[i].status=='accepted'){
          acceptedTasks++;
        }
        if(userTaskList[i].status=='قيد المراجعة'){
          pendingTasks++;
        }
        allTasks=userTaskList.length;
      }
      isTaskLoading=true;
      update();
      print("Tasks loaded: ${userTaskList.length} Tasks found.");
    } catch (e) {
      // Handle any errors
      print("Error fetching ads: $e");
    }
  }


  List<String>statusList=[
    'Tasks at hand'.tr,
    'Tasks in progress'.tr,
    'Canceled tasks'.tr, 'Completed tasks'.tr,
    // 'جميع المهام',
  ];

  changeSelectedStatus(String status){
    isTaskLoading=false;
    selectedStatus=status;
    update();
    String st='';
    if(status=='جميع المهام'){
      st='x';
    }
    if( status=='مهام مطروحة'){
      st='pending';
      //'قيد المراجعة';
    }

    if( status=='مهام ملغاه'){
      st='canceled';
    }
    if( status=='مهام قيد التنفيذ'){
      st='accepted';
    }
    if( status=='مهام مكتملة'){
      st='done';
    }
    isTaskLoading=true;
    update();
    getUserTasksWithStatus(st);
  }


  getUserTasksWithStatus(String status)async{

    print("ST====="+status);
    if(status=='x'){
      getUserTaskList();
    }



    else{
      String st='';
      if(status=='جميع المهام'){
        st='x';
      }
      else if( status=='مهام مطروحة'){
        st='pending';
        //'قيد المراجعة';
      }

      else  if( status=='مهام ملغاه'){
        st='canceled';
      }
      else if( status=='مهام قيد التنفيذ'){
        st='accepted';
      }
      else if( status=='مهام مكتملة'){
        st='done';
      }
      print("GET PROPOSALS...............");
      userTaskList=[];
      final box=GetStorage();
      String email=box.read('email');
      print("EMAIL=="+email);
      try {
        print("GET PROPOSALS");
        // Fetch all documents from the 'ads' collection
        QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('tasks')
            .where('user_email',isEqualTo:email).
        where('status',isEqualTo: st)
            .orderBy('current_date',descending: true)
        // .where('user_email',isEqualTo: 'test@gmail.com')
            .get();
        userTaskList = querySnapshot.docs.map((DocumentSnapshot doc) {
          return Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();


        update();
        print("Tasks loaded: ${userTaskList.length} Tasks found.");
      } catch (e) {
        print("Error fetching ads: $e");
      }
    }

  }


  // Future<List<Proposal>>
  // fetchProposals
  //     (String taskId) async {
  //   print("fetching proposals $taskId");
  //   userProposalList = [];
  //   try {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     final CollectionReference proposalsCollection =
  //     firestore.collection('proposals');
  //     // Query Firestore for proposals with the given taskId and order by task_date
  //     final QuerySnapshot querySnapshot = await proposalsCollection
  //         .where('task_id', isEqualTo: taskId)
  //         .orderBy('task_date',
  //         descending: true) // Order by task_date (latest first)
  //         .get();
  //     // Convert the query snapshot into a list of Proposal objects
  //     return querySnapshot.docs
  //         .map((doc) => Proposal.fromDocument(doc))
  //         .toList();
  //   } catch (e) {
  //     // Handle any errors that occur during the fetch
  //     print('Error fetching proposals: $e');
  //     return []; // Return an empty list in case of error
  //   }
  // }



}
