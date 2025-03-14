import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yemen_services_dashboard/features/offers/controller/offers_controller.dart';
import 'package:yemen_services_dashboard/features/offers/edit_ad.dart';
import 'package:yemen_services_dashboard/features/offers/model/ads_model.dart';

import '../../core/theme/colors.dart';

class AdDetails extends StatefulWidget {
  final Ad ad;

  AdDetails({super.key, required this.ad});

  @override
  State<AdDetails> createState() => _AdDetailsState();
}

class _AdDetailsState extends State<AdDetails> {

  final AdController controller = Get.put(AdController());


  @override
  void initState() {
    controller.getProviderNameByEmail(widget.ad.email);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // Convert Timestamp to DateTime
    DateTime dateTime = widget.ad.startDate.toDate();
    DateTime endDateTime = widget.ad.endDate.toDate();

    // Format DateTime to String
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    String endFormattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'تفاصيل الإعلان',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: GetBuilder<AdController>(
          builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image Section with Error Handling
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.ad.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.blue),

                /// Title Section
                _buildInfoRow('الاسم', widget.ad.title, fontSize: 20, fontWeight: FontWeight.bold),
                _buildInfoRow('بريد الالكتروني لمقدم الخدمة  ', widget.ad.email, fontSize: 20, fontWeight: FontWeight.bold),
                _buildInfoRow('اسم مقدم الخدمة ', controller.providerName, fontSize: 20, fontWeight: FontWeight.bold),
                _buildInfoRow('الوصف', widget.ad.des),
                _buildInfoRow('التصنيف', widget.ad.cat, textColor: Colors.blue),
                _buildInfoRow('تاريخ البدء', formattedDate),
                _buildInfoRow('تاريخ نهاية الإعلان', endFormattedDate),

                const SizedBox(height: 24),

                /// Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _editAd(),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('تعديل الإعلان'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteAd(context),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('حذف الإعلان'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  /// Helper Widget for Info Rows
  Widget _buildInfoRow(String label, String value, {double fontSize = 18, FontWeight fontWeight = FontWeight.normal, Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: fontWeight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Edit Ad Function
  void _editAd() {
   Get.to(() => EditAdView(ad: widget.ad)); // Navigate to the Edit Screen
  }

  /// Delete Ad Confirmation
  void _deleteAd(BuildContext context) {
    Get.defaultDialog(
      title: 'حذف الإعلان',
      middleText: 'هل أنت متأكد أنك تريد حذف هذا الإعلان؟',
      textConfirm: 'نعم',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteAdById(widget.ad.id);
        Get.back(); // Close Dialog
        Get.snackbar('نجاح', 'تم حذف الإعلان بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
        Get.back(); // Go back to the previous screen
      },
    );
  }
}
