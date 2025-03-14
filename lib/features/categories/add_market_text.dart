import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class AddCatMarketText extends StatefulWidget {

  String cat;

 AddCatMarketText({super.key,required this.cat});

  @override
  State<AddCatMarketText> createState() => _AddCatMarketTextState();
}

class _AddCatMarketTextState extends State<AddCatMarketText> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String? selectedCat;
  // List<String> cats = [];

  @override
  void initState() {
    super.initState();
    //fetchCats();
  }



  Future<void> _addCatMarketText() async {
    if ( _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى إدخال النص"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('catMarketText').add({
        'cat': widget.cat,
        'text': _textController.text,
       // 'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تمت إضافة النص بنجاح"),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the form after successful submission
      _textController.clear();
      setState(() {
        selectedCat = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء الإضافة: $e"),
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
          "إضافة نص اعلاني للاقسام",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           
            const SizedBox(height: 50),
            // Text field for marketing text
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: "النص الاعلاني",
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Allow multiple lines for longer text
            ),
            const SizedBox(height: 20),
            // Add button
            ElevatedButton(
              onPressed: isLoading ? null : _addCatMarketText,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("اضف النص"),
            ),
          ],
        ),
      ),
    );
  }
}