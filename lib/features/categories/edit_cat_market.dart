import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/categories/cat_market_text.dart';

class EditCatMarketText extends StatefulWidget {
  final String cat;
  final String txt;

  const EditCatMarketText({super.key, required this.cat, required this.txt});

  @override
  State<EditCatMarketText> createState() => _EditCatMarketTextState();
}

class _EditCatMarketTextState extends State<EditCatMarketText> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the text field with the existing text
    _textController.text = widget.txt;
  }

  Future<void> _updateCatMarketText() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Find the document where 'cat' matches the provided category
      QuerySnapshot querySnapshot = await _firestore
          .collection('catMarketText')
          .where('cat', isEqualTo: widget.cat)
          .get();

      // If a document is found, update its 'text' field
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'text': _textController.text,
          });
        }
      }

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تعديل النص بنجاح"),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to the previous screen
      Get.off(const CatMarkrtView());
      
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء التعديل: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "تعديل نص اعلاني للاقسام",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: "النص الحالي",
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Allow multiple lines for longer text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _updateCatMarketText,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("تعديل"),
            ),
          ],
        ),
      ),
    );
  }
}