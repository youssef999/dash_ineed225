import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class OfferPrice extends StatefulWidget {
  const OfferPrice({super.key});

  @override
  State<OfferPrice> createState() => _OfferPriceState();
}

class _OfferPriceState extends State<OfferPrice> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _dayPriceController = TextEditingController();
  final TextEditingController _weekPriceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOfferPrice();
  }

  // Fetch offer price data from Firestore
  Future<void> _fetchOfferPrice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot offerPriceDoc = await _firestore.collection('offerPrice').doc('HwlRHlk1y8dg1ZSlVglO').get();

      if (offerPriceDoc.exists) {
        setState(() {
          _dayPriceController.text = offerPriceDoc['day'].toString();
          _weekPriceController.text = offerPriceDoc['week'].toString();
        });
      } else {
        print('Offer price document not found');
      }
    } catch (e) {
      print('Error fetching offer price: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update offer price data in Firestore
  Future<void> _updateOfferPrice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('offerPrice').doc('HwlRHlk1y8dg1ZSlVglO').update({
        'day': int.parse(_dayPriceController.text),
        'week': int.parse(_weekPriceController.text),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الأسعار بنجاح')),
      );
      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث الأسعار: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل أسعار العروض'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Day Price
            TextField(
              controller: _dayPriceController,
              decoration: const InputDecoration(
                labelText: 'سعر اليوم (بالدينار)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Week Price
            TextField(
              controller: _weekPriceController,
              decoration: const InputDecoration(
                labelText: 'سعر الأسبوع (بالدينار)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Save Button
            ElevatedButton(
              onPressed: _updateOfferPrice,
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }
}