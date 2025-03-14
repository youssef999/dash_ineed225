import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQues extends StatelessWidget {
  const AddQues({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    final TextEditingController titleEnController = TextEditingController();
    final TextEditingController answerEnController = TextEditingController();

    Future<void> addQuestion(String title, String answer) async {
      try {
        await FirebaseFirestore.instance.collection('ques').add({
          'title': title,
          'titleEn': titleEnController.text,
          'answer': answer,
          'answerEn':answerEnController.text
        });
        print('Question added successfully');
      } catch (e) {
        print('Error adding question: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سؤال'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: titleEnController,
              decoration: const InputDecoration(
                labelText: 'عنوان (بالانجليزية)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'الإجابة',
                border: OutlineInputBorder(),
              ),
            ), const SizedBox(height: 16.0),
            TextField(
              controller: answerEnController,
              decoration: const InputDecoration(
                labelText: ' الإجابة (بالانجليزية)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String answer = answerController.text.trim();

                if (title.isNotEmpty && answer.isNotEmpty) {
                  await addQuestion(title, answer);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت الإضافة بنجاح')),
                  );
                  titleController.clear();
                  answerController.clear();
                  titleEnController.clear();
                  answerEnController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
