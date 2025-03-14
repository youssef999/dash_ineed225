import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/colors.dart';

class AdPriceView extends StatefulWidget {
  const AdPriceView({super.key});

  @override
  State<AdPriceView> createState() => _AdPriceViewState();
}

class _AdPriceViewState extends State<AdPriceView> {
  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('adsPrice');

  // Controllers for editing fields
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _timeArController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // For identifying which document is being edited
  String? editingDocId;

  @override
  void dispose() {
    _timeController.dispose();
    _timeArController.dispose();
    _daysController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _editDocument(DocumentSnapshot doc) {
    setState(() {
      editingDocId = doc.id;
      _timeController.text = doc['time'];
      _timeArController.text = doc['timeAr'];
      _daysController.text = doc['days'].toString();
      _priceController.text = doc['price'].toString();
    });
  }

  void _saveDocument() async {
    if (editingDocId != null) {
      await adsCollection.doc(editingDocId).update({
        'time': _timeController.text,
        'timeAr': _timeArController.text,
        'days': int.tryParse(_daysController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
      });
    } else {
      await adsCollection.add({
        'time': _timeController.text,
        'timeAr': _timeArController.text,
        'days': int.tryParse(_daysController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
      });
    }
    setState(() {
      editingDocId = null;
      _timeController.clear();
      _timeArController.clear();
      _daysController.clear();
      _priceController.clear();
    });
  }

  void _deleteDocument(String docId) async {
    await adsCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('الاعلانات ',
        style:TextStyle(
          color:Colors.white,
        ),
        ),
        backgroundColor:primary,
      ),
      body: Column(
        children: [
          // Form for Adding/Editing Ads
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'مدة الاعلان بالانجليزية'),
                ),
                  const SizedBox(height: 10),
                TextField(
                  controller: _timeArController,
                  decoration: const InputDecoration(labelText: 'مدة الاعلان بالعربية'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _daysController,
                  decoration: const InputDecoration(labelText: 'عدد الايام للاعلان'),
                  keyboardType: TextInputType.number,
                ),
                  const SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'سعر الاعلان'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveDocument,
                  child: Text(editingDocId == null ? 'اضافة' : 'تعديل'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Display List of Ads
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: adsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          title: Text('  مدة الاعلان بالانجليزية : ${doc['time']} | مدة الاعلان بالايام  : ${doc['days']}'),
                          subtitle: Text(
                              ' مدة الاعلان بالعربية  : ${doc['timeAr']} | السعر ${doc['price']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editDocument(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDocument(doc.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
