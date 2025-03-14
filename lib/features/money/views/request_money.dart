import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/money/views/request_details.dart';
import 'package:yemen_services_dashboard/features/offers/cutom_button.dart';
import 'package:yemen_services_dashboard/features/service_providers/prov_details2.dart';
import 'package:yemen_services_dashboard/features/service_providers/provider_details.dart';
import 'package:yemen_services_dashboard/features/statistics/buy_service/buy_service_providers.dart';

class RequestMoney extends StatefulWidget {
  const RequestMoney({super.key});

  @override
  State<RequestMoney> createState() => _RequestMoneyState();
}

class _RequestMoneyState extends State<RequestMoney> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'طلبات سحب الأموال',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('wallet')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No pending requests found.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;

                // Format the timestamp
                String formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                    .format((data['date'] as Timestamp).toDate());

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(left:44,right:12,top:32,bottom:16),
                  child: ListTile(
                    title: Text(
                      'قيمة السحب  ${data['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12,),
                        Text('بريد الكتروني خاص بمقدم الخدمة :  ${data['email']}',
                        
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                        ),
                        ),
                           const SizedBox(height: 12,),
                        Text('التاريخ  $formattedDate',style:const TextStyle(color: primaryColor,
                        fontSize: 13
                        )),
const SizedBox(height: 12,),
                        (isLoading==false)?

                        CustomButton(
                             width: 300,
                           color1:Colors.red,
                          text: 'عرض مقدم الخدمة', onPressed: (){


                          setState(() {
                            isLoading=true;
                          });



                          getProviderData(data['email']);
                          Future.delayed(const Duration(seconds: 2), () {
                            
                             setState(() {
                            isLoading=false;
                          });

                            Get.to(ProviderDetails20(provider: providerData));


                          });

                        }):const Center(child: CircularProgressIndicator()),


                        const SizedBox(height: 12,),


                        CustomButton(
                          width: 300,
                          color1:Colors.red,
                          text: 'عرض تفاصيل التحويل ', onPressed: (){

                          Get.to(RequestDetails(payId: data['payId'],));

                        }),
                         const SizedBox(height: 12,),

                         CustomButton(
                          width: 300,
                          color1:Colors.green,
                          text: 'هل تم التحويل بنجاح ؟  ', onPressed: (){

                          _showConfirmationDialog(data['payId']);

                        }),
                      ],
                    ),
                   
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  Future<void> updateWalletStatus(String payId) async {
    try {
      // Update the document in the 'wallet' collection where payId matches
      await FirebaseFirestore.instance
          .collection('wallet')
          .where('payId', isEqualTo: payId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          doc.reference.update({'status': 'done'});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على المستند')),
          );
        }
      });
    } catch (e) {
      print("Error updating wallet status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التحديث: $e')),
      );
    }
  }
  // Function to show confirmation dialog
  Future<void> _showConfirmationDialog(String payId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد التحويل'),
          content: const Text('هل انت متاكد انه تم التحويل بنجاح؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('موافق'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await updateWalletStatus(payId); // Update Firestore
              },
            ),
          ],
        );
      },
    );
  }
}