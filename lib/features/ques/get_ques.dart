import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

import 'add_ques.dart';

class GetQues extends StatefulWidget {
  const GetQues({super.key});

  @override
  State<GetQues> createState() => _GetQuesState();
}

class _GetQuesState extends State<GetQues> {
  // Function to fetch data from Firestore
  Future<List<QueryDocumentSnapshot>> fetchQuestions() async {
    try {
      // Reference to the Firestore collection
      CollectionReference quesCollection = FirebaseFirestore.instance.collection('ques');
      // Get all documents from the collection
      QuerySnapshot snapshot = await quesCollection.get();
      // Return the list of QueryDocumentSnapshot
      return snapshot.docs;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  // Function to delete a document from Firestore
  Future<void> deleteQuestion(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('ques').doc(docId).delete();
      print('Document with ID $docId deleted successfully');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
  // Show confirmation dialog before deleting
  Future<void> showDeleteDialog(String docId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف السؤال'),
          content: const Text('هل تريد حذف هذا السؤال؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await deleteQuestion(docId);
                setState(() {}); // Refresh the UI after deletion
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:primaryColor,
        title: const Text('الاسئلة الشائعة',style:TextStyle(color:Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.red),
            onPressed: () async {
           Get.to(const AddQues());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }

          // Data fetched successfully
          List<QueryDocumentSnapshot> questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final data = question.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text(data['answer'] ?? 'No Answer'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await showDeleteDialog(question.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
