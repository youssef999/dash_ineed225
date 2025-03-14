import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

class AppCommView extends StatefulWidget {
  const AppCommView({super.key});

  @override
  State<AppCommView> createState() => _AppCommViewState();
}

class _AppCommViewState extends State<AppCommView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String documentId = 'p5dFShcyRSpyrmu4VjP0'; // Your Firestore document ID
  int _value = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('appCommetion').doc(documentId).get();
      if (doc.exists) {
        setState(() {
          _value = doc['value']; // Assuming the field name is 'value'
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _updateValue() async {
    try {
      int newValue = int.tryParse(_controller.text) ?? _value;
      await _firestore.collection('appCommetion').doc(documentId).update({
        'value': newValue,
      });
      setState(() {
        _value = newValue;
      });
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعديل نسبة ارباح التطبيق بنجاح')),
      
      );
      Get.back();
    } catch (e) {
      print('Error updating data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update value: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'نسبة ارباح التطبيق',
          style: TextStyle(color: Colors.white, fontSize: 21),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'النسبة الحالية  $_value',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'ادخل النسبة',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateValue,
              child: const Text('تعديل النسبة'),
            ),
          ],
        ),
      ),
    );
  }
}