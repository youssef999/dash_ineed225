

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/statistics/user.dart';

import '../../orders/model/proposal.dart';
import '../../orders/model/task.dart';


class StController extends GetxController {


List<Proposal>proposalList=[];
List<Proposal>proposalList2=[];
List<Proposal>buySerivcesList=[];
List<Map<String,dynamic>>buySerivcesList2=[];


Color color = Colors.white;
Color color2 = Colors.white;
Color color3 = Colors.white;


Color textColor = Colors.black;
Color textColor2 = Colors.black;
Color textColor3 = Colors.black;


List<String>statusList=['مهام مطروحة',
  'مهام مكتملة',
  'مهام قيد التنفيذ','مهام ملغاه',
  'جميع المهام'
];

String selectedStatus= 'جميع المهام';


bool isLoading=false;

 Map<String,dynamic>selectedUser={};
  List<User> usersList = [];
  List<Task> allTasksList = []; // All tasks (unfiltered)
  List<Task> filteredTasks = []; // Tasks filtered by user
  
  List<User> userList = []; // List of users fetched from Firestore
 

 List<Map<String, dynamic>> users=[];

 List<String>usersNames=[];

Future<List<Map<String, dynamic>>> getAllUsers() async {
  try {

    users=[];
    usersNames=[];
    
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    
    // Fetch all documents in the collection
    QuerySnapshot querySnapshot = await usersCollection.get();
    
    // Map the documents into a list of maps
    users = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>; // Cast each document to a map
    }).toList();

    for(int i=0;i<users.length;i++){
      usersNames.add(users[i]['name']);
    }
   // setState(() {
       selectedUser = users.isNotEmpty ? users[1]:{};
  //  });
   
    update();
    return users;
  } catch (e) {
    print("Error fetching users: $e");
    return [];
  }
}

  // Method to fetch users
  // Future<void> fetchUsers() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
  //     userList = querySnapshot.docs.map((doc) {
  //       return User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  //     }).toList();

  //     selectedUser = userList.isNotEmpty ? userList[0] : {};
  //     update(); // Notify UI
  //   } catch (e) {
  //     print("Error fetching users: $e");
  //   }
  // }

     void filterByUser(String email) {
       //selectedUser = email;
       update();
getPropWithUserEmail(email);
  }

  // Set the selected user and fetch data
  void setSelectedUser(String email) {
    // selectedUser= email;
    getWorkerProposalWithUser(email); // Fetch proposals for selected user
    getWorkerBuyServicesWithUser(email); // Fetch buy services for selected user
    update(); // Notify UI
  }

  // Fetch proposals for selected user
  Future<void> getWorkerProposalWithUser(String userEmail) async {
    // Similar to existing `getWorkerProposal` but filter by user email
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('email', isEqualTo: userEmail)
          .get();

      proposalList = querySnapshot.docs.map((doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Process stats like doneTasks, pendingTasks, etc.
      // Similar to existing code
      update();
    } catch (e) {
      print("Error fetching proposals for user: $e");
    }
  }

  // Fetch buy services for selected user
  Future<void> getWorkerBuyServicesWithUser(String userEmail) async {
    // Implement similar logic for buy services if required
  }



changeSelectedStatusForBuyServices(String status){
  selectedStatus=status;
  update();
  String st='';
  if(status=='جميع المهام'){
    st='x';
  }
  if( status=='مهام مطروحة'){
    st='pending';
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
  getBuyServicesWithStatus(st);
}

changeSelectedStatus(String status){

  selectedStatus=status;

  String st='';
  if(status=='جميع المهام'){
    st='x';
    //update();
  }
  if(status=='مهام قيد المراجعة'){
    st='قيد المراجعة';
   // update();
  }

  if( status=='المهام المرفوضة'){
    st='canceled';
  //  update();
  }

  if( status=='المهام المقبولة'){
    st='accepted';
   // update();
  }
  if( status=='المهام المنتهية'){
    st='done';
   // update();
  }
  ///update();
  //print("ST====="+st);
  getWorkerProposalWithStatus(st);
}

changeColor(int index){

  String status='قيد المراجعة';
  if(index==0){
    color = primary;
    color2 = Colors.white;
    color3 = Colors.white;
     textColor = Colors.white;
    textColor2 = Colors.black;
     textColor3 = Colors.black;
    status='قيد المراجعة';
  }

  if(index==1){
    color2 = primary;
    color = Colors.white;
    color3 = Colors.white;
    textColor2 = Colors.white;
    textColor = Colors.black;
    textColor3 = Colors.black;
    status='accepted';
  }
  if(index==2){
    color3 = primary;
    color = Colors.white;
    color2 = Colors.white;
    textColor3 = Colors.white;
    textColor2 = Colors.black;
    textColor = Colors.black;
    status='canceled';
  }
  getWorkerProposalWithStatus(status);
update();

}


bool isBuyServicesLoading=false;

int doneBuyTasks=0;
int refusedBuyTasks=0;
int pendingBuyTasks=0;
int acceptedBuyTasks=0;
int acceptedBuyTasks2=0;
int allBuyTasks=0;



Future<void> updateWorkerToken
    () async {

  final box=GetStorage();



String workerDeviceToken
=box.read('WorkerDeviceToken')??'x';

if(workerDeviceToken=='x'){
  try {
    String? token =
    await FirebaseMessaging.instance.getToken();
    String email=box.read('email');
    print("TOKE====${token!}");
    // Reference to the users collection
    final usersCollection =
    FirebaseFirestore.instance.
    collection('serviceProviders');
    // Find the user document by email and update the token field
    await usersCollection
        .where('email', isEqualTo: email)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Update the token field in the document
        snapshot.docs.first.reference.
        update({'fcmToken': token});
      }
      box.write('WorkerDeviceToken', token);
    });
    print("Token updated successfully!");
  } catch (e) {
    print("Error updating token: $e");
  }
}else{
  print("========Token already exists=======");
}

}

getWorkerBuyServices()async{
   doneBuyTasks=0;
   refusedBuyTasks=0;
   pendingBuyTasks=0;
  acceptedBuyTasks=0;
  acceptedBuyTasks2=0;
  allBuyTasks=0;
   isBuyServicesLoading=true;
  // buySerivcesList=[];
  // update();
  print("GET WORKER BUY SERVICES...............");
  try {
    print("GET PROPOSALS");
    // Fetch all documents from the 'ads' collection
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.
    collection('buyService').
        //.where('worker_email',isEqualTo:email)
    // .where('user_email',isEqualTo: 'test@gmail.com')
      get();
    buySerivcesList = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
    update();
    for(int i=0;i<buySerivcesList.length;i++){
      if(buySerivcesList[i].status=='done'){
        doneBuyTasks++;
      }
      if(buySerivcesList[i].status=='canceled'){
        refusedBuyTasks++;
      }
       if(buySerivcesList[i].status=='payDone'){
        acceptedBuyTasks2++;
      }
      //acceptedBuyTasks
      if(buySerivcesList[i].status=='accepted'){
        acceptedBuyTasks++;
      }
      if(buySerivcesList[i].status=='قيد المراجعة'||
      buySerivcesList[i].status=='pending'
      ){
        pendingBuyTasks++;
      }
    }
  } catch (e) {
    print("Error fetching ads: $e");
  }
  isBuyServicesLoading=true;
  update();
}

getBuyServicesWithStatus(String status)async{
  print("ST========$status");
  if(status=='x'){
    getWorkerBuyServices();
  }else{
    print("GET PROPOSALS...............");
    buySerivcesList=[];
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('buyService')
       //   .where('worker_email',isEqualTo:email).
      .where('status',isEqualTo: status)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      buySerivcesList =
          querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      update();
      print("Tasks loaded: ${buySerivcesList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }
}


getBuyServicesWithUserEmail(String email)async{
  print("ST========$email");

    print("GET PROPOSALS...............");
    buySerivcesList=[];
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('buyService')
      //   .where('worker_email',isEqualTo:email).
          .where('user_email',isEqualTo: email)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      buySerivcesList =
          querySnapshot.docs.map((DocumentSnapshot doc) {
            return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      update();
      print("Tasks loaded: ${buySerivcesList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");

  }
}

getBuyServicesWithProvidersEmail(String email)async{
  print("ST========$email");

  print("GET PROPOSALS...............");
  buySerivcesList=[];
  try {
    print("GET PROPOSALS");
    // Fetch all documents from the 'ads' collection
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('buyService')
    //   .where('worker_email',isEqualTo:email).
        .where('worker_email',isEqualTo: email)
    // .where('user_email',isEqualTo: 'test@gmail.com')
        .get();
    buySerivcesList =
        querySnapshot.docs.map((DocumentSnapshot doc) {
          return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

    update();
    print("Tasks loaded: ${buySerivcesList.length} Tasks found.");
  } catch (e) {
    print("Error fetching ads: $e");

  }
}




getWorkerProposalWithStatus(String status)async{
  print("HERE ST=====WITH STATUS.........==$status");

  if(status=='pending'){

    //   .where('status', whereIn: ['pending', 'قيد المراجعة']
    print("GET PROPOSALS...............");
    proposalList=[];
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance
          .collection('proposals')
          .where('status', whereIn: ['pending', 'قيد المراجعة'])
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading=true;
      update();
      print("Tasks loaded: ${proposalList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");

    }

  }else{

    print("GET PROPOSALS...............");
    proposalList=[];

    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance
          .collection('proposals')
          .where('status',isEqualTo: status)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading=true;
      update();
      print("Tasks loaded: ${proposalList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");

    }
  }

}




// List<Proposal>tasksList=[];
List<Map<String, dynamic>> tasksList = [];

// List<Map<String, dynamic>> tasksList = [];

Future<void> getTasks() async {
  print("GET TASKS..............");
  tasksList = []; // Clear the list before fetching new data
  try {
    print("GET TASKS...");

    // Step 1: Fetch all tasks with status 'pending' or 'قيد المراجعة'
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('status', whereIn: ['pending', 'قيد المراجعة'])
        .get();

    // Step 2: Fetch all task_id values from the 'proposals' collection
    QuerySnapshot proposalsSnapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .get();

    // Extract task_id values from proposals
    List<String> proposalTaskIds = proposalsSnapshot.docs
        .map((doc) => doc['task_id'] as String)
        .toList();

    // Step 3: Filter tasks to exclude those with IDs found in proposals
    tasksList = tasksSnapshot.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add the document ID to the map
      return data;
    }).where((task) => !proposalTaskIds.contains(task['id'])).toList();
    isLoading = true;
    update(); // Assuming this is part of a GetX controller
    print("Tasks loaded: ${tasksList.length} Tasks found.");
  } catch (e) {
    print("Error fetching tasks: $e");
  }
}


Future<void> getTasksWithSubCats(List<String> filterList) async {
  print("GET TASKS with filtering...");

  tasksList = []; // Clear the list before fetching new data
  try {
    // Step 1: Fetch all tasks with status 'pending' or 'قيد المراجعة'
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('status', whereIn: ['pending', 'قيد المراجعة'])
        .get();

    // Step 2: Fetch all task_id values from the 'proposals' collection
    QuerySnapshot proposalsSnapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .get();

    // Extract task_id values from proposals
    List<String> proposalTaskIds = proposalsSnapshot.docs
        .map((doc) => doc['task_id'] as String)
        .toList();

    // Step 3: Filter tasks based on the filterList and exclude those with proposals
    tasksList = tasksSnapshot.docs
        .map((DocumentSnapshot doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        })
        .where((task) =>
            !proposalTaskIds.contains(task['id']) &&
            filterList.contains(task['sub_cat'] as String)) // 🔥 التحقق الصحيح
        .toList();

    isLoading = true;
    update(); // Assuming this is part of a GetX controller
    print("Filtered Tasks loaded: ${tasksList.length} tasks found.");
  } catch (e) {
    print("Error fetching filtered tasks: $e");
  }
}


// ignore: non_constant_identifier_names
Future<void> FilterTasks(DateTime date) async {
  print("GET TASKS..............");
  tasksList = []; // Clear the list before fetching new data
  try {
    print("GET TASKS...");

    // Step 1: Fetch all tasks with status 'pending' or 'قيد المراجعة' and date >= specified date
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('status', whereIn: ['pending', 'قيد المراجعة'])
        .where('current_date', isGreaterThanOrEqualTo: date)
        .get();

    // Step 2: Fetch all task_id values from the 'proposals' collection
    QuerySnapshot proposalsSnapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .get();

    // Extract task_id values from proposals
    List<String> proposalTaskIds = proposalsSnapshot.docs
        .map((doc) => doc['task_id'] as String)
        .toList();

    // Step 3: Filter tasks to exclude those with IDs found in proposals
    tasksList = tasksSnapshot.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add the document ID to the map
      return data;
    }).where((task) => !proposalTaskIds.contains(task['id'])).toList();

    isLoading = true;
    update(); // Assuming this is part of a GetX controller
    print("Tasks loaded: ${tasksList.length} Tasks found.");
  } catch (e) {
    print("Error fetching tasks: $e");
  }
}
//
// Future<void> getTasks() async {
//   print("GET TASKS..............");
//   tasksList = []; // Clear the list before fetching new data
//   try {
//     print("GET TASKS...");
//     // Fetch all documents from the 'tasks' collection
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('tasks')
//         .where('status', whereIn: ['pending', 'قيد المراجعة'])
//         .get();

//     // Convert Firestore documents to List<Map<String, dynamic>>
//     tasksList = querySnapshot.docs.map((DocumentSnapshot doc) {
//       // Get the document data as a Map
//       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//       // Add the document ID to the map (optional, if you need it)
//       data['id'] = doc.id;
//       return data;
//     }).toList();

//     isLoading = true;
//     update(); // Assuming this is part of a GetX controller
//     print("Tasks loaded: ${tasksList.length} Tasks found.");
//   } catch (e) {
//     print("Error fetching tasks: $e");
//   }
// }


getPropWithProviderEmail(String email) async {
   proposalList=[];
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance
          .collection('proposals')
          .where('email',isEqualTo: email)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading=true;
      update();
      print("Tasks loaded: ${proposalList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");

    }
}


getPropWithCat(String cat) async {
   proposalList=[];
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance
          .collection('proposals')
          .where('task_cat',isEqualTo:cat)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading=true;
      update();
      print("Tasks loaded: ${proposalList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");

    }
}





getPropWithUserEmail(String email) async {
   proposalList=[];
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance
          .collection('proposals')
          .where('user_email',isEqualTo: email)
      // .where('user_email',isEqualTo: 'test@gmail.com')
          .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading=true;
      update();
      print("Tasks loaded: ${proposalList.length} Tasks found.");
    } catch (e) {
      print("Error fetching ads: $e");

    }
}


 int doneTasks=0;
 int refusedTasks=0;
 int pendingTasks=0;
 int acceptedTasks=0;
 int allTasks=0;
 int pendingTasks2=0;


String name='';
Future<String?> getUserNameFromTask(String taskId) async {
  print("ID===$taskId");
  try {
    // Reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Query the `tasks` collection with the given taskId
    DocumentSnapshot taskSnapshot = await firestore
        .collection('tasks')
        .doc(taskId)
        .get();

    // Check if the document exists
    if (taskSnapshot.exists) {
      // Retrieve the `user_name` from the document
      String userName = taskSnapshot.get('user_name');
      name=userName;
      return userName;
      
    } else {
      print("Task not found");
      return null;
    }
  } catch (e) {
    print("Error retrieving user_name: $e");
    return null;
  }

}




Future<void> openMap(double latitude, double longitude) async {
  String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  if (await canLaunchUrl(Uri.parse(googleUrl))) {
    await launchUrl(Uri.parse(googleUrl));
  } else {
    await launchUrl(Uri.parse(googleUrl));
    //throw 'Could not open the map.';
  }
}


// List<WorkerProvider>workerList=[];

// getWorkerData()async{
//   final box=GetStorage();
//   String email=box.read('email');
//   try {
//     print("GET PROPOSALS");
//     // Fetch all documents from the 'ads' collection
//     QuerySnapshot querySnapshot =
//     await FirebaseFirestore.instance.
//     collection('serviceProviders')
//         .where('email',isEqualTo:email)
//     // .where('user_email',isEqualTo: 'test@gmail.com')
//         .get();
//     workerList = querySnapshot.docs.map
//       ((DocumentSnapshot doc) {
//       return WorkerProvider
//           .fromFirestore(doc.data()
//       as Map<String, dynamic>, doc.id);
//     }).toList();

//     update();
//     print("WORKER DATA loaded: ${workerList.length} .......");
//   } catch (e) {
//     print("Error fetching ads: $e");
//   }
// }

getWorkerProposal()async{
  isLoading=false;
  update();
  doneTasks=0;
  refusedTasks=0;
  pendingTasks=0;
  acceptedTasks=0;
  allTasks=0;
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('proposals')
     // .where('user_email',isEqualTo: 'test@gmail.com')
      .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      for(int i=0;i<proposalList.length;i++){
        if(proposalList[i].status=='done'){
          doneTasks++;
        }
        if(proposalList[i].status=='canceled'){
          refusedTasks++;
        }
        if(proposalList[i].status=='accepted'){
          acceptedTasks++;
        }
        if(proposalList[i].status=='قيد المراجعة'|| proposalList[i].status=='pending'){
          pendingTasks++;
        }
      }
      
      print("Tasks loaded: ${proposalList.length} Tasks found.");
      isLoading=true;
      update();
    } catch (e) {
      print("Error fetching ads: $e");
    }
}



Future<void> getWorkerTask() async {
  isLoading = false;
  update();

  pendingTasks2 = 0;

  try {
    print("..xxxxxxxxxx...........GET........TASKS.........xxxxxxxxx..");

    // Fetch all documents from the 'tasks' collection
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance.collection('tasks').get();
    List<String> taskIds = tasksSnapshot.docs.map((doc) => doc.id).toList();

    // Fetch all documents from the 'proposals' collection
    QuerySnapshot proposalsSnapshot = await FirebaseFirestore.instance.collection('proposals').get();
    List<String> proposalTaskIds = proposalsSnapshot.docs.map((doc) => doc['task_id'] as String).toList();

    // Compare task IDs
    for (String taskId in taskIds) {
      if (!proposalTaskIds.contains(taskId)) {
        pendingTasks2++; // Increment if task_id is not found in proposals
      }
    }

    print("..........Tasks loaded..........: ${taskIds.length} tasks found.");
    print("..........Pending tasks..........: $pendingTasks2 tasks pending.");

    isLoading = true;
    update();
  } catch (e) {
    print("Error fetching tasks: $e");
  }
}



  getWorkerProposalWithSt(String st)async{
    isLoading=false;
    update();
    doneTasks=0;
    refusedTasks=0;
    pendingTasks=0;
    acceptedTasks=0;
    allTasks=0;
    try {
      print("GET PROPOSALS");
      // Fetch all documents from the 'ads' collection
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('proposals')
       .where('status',isEqualTo: st)
          .get();
      proposalList = querySnapshot.docs.map((DocumentSnapshot doc) {
        return Proposal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      print("Tasks loaded: ${proposalList.length} Tasks found.");
      isLoading=true;
      update();
    } catch (e) {
      print("Error fetching ads: $e");
    }
  }

Future<void> updateWorkerStatus(String status,String id) async {
  final box=GetStorage();
  String email=box.read('email');
  print("EMAIL==$email");
  try {
    // Reference the 'buyService' collection
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('buyService');

    // Query documents where 'worker_email' matches the provided email
    QuerySnapshot querySnapshot =
    await collectionRef
        .where('id', isEqualTo: id)
        .get();

    // Loop through the documents to update each one's status to 'done'
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'status': status});
    }
    getWorkerBuyServices();
    print("Status updated to 'done' for worker with email: $email");
  } catch (e) {
    print("Error updating status: $e");
  }
}


}