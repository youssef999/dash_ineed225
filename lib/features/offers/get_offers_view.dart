


// ignore_for_file: must_be_immutable

  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/offers/ad_details.dart';
import 'package:yemen_services_dashboard/features/offers/controller/offers_controller.dart';
import 'package:yemen_services_dashboard/features/offers/model/ads_model.dart';

class GetOffersView extends StatefulWidget {
  const GetOffersView({super.key});

  @override
  State<GetOffersView> createState() => _GetOffersViewState();
}
class _GetOffersViewState extends State<GetOffersView> {
  
  AdController controller=Get.put(AdController());

  @override
  void initState() {
    controller.getAds();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white10,
      appBar: AppBar(
        leading:IconButton(icon: const Icon(Icons.arrow_back,color:Colors.white),
onPressed:(){Get.back();},
        ),
        title:  const Text('الاعلانات ',
        style:TextStyle(
          color:Colors.white,
        ),
        ),
        backgroundColor:primary,
      ),
      body:Padding(
        padding: const EdgeInsets.all(13.0),
        child: GetBuilder<AdController>(
          builder: (_) {
            return ListView(children:  [
              const SizedBox(height: 22,),
           (controller.adsList.isNotEmpty)?
              GridView.builder(
                shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns in the grid
          mainAxisSpacing: 13.0, // Spacing between rows
          crossAxisSpacing: 13.0, // Spacing between columns
          childAspectRatio: 2.1, // Aspect ratio of each item
        ),
        itemCount: controller.adsList.length, // Total number of items in the grid
        itemBuilder: (BuildContext context, int index) {

          return AdWidget(ad:controller.adsList[index]);


        }):const Center(
          child: CircularProgressIndicator(),
        )
              




              
            ],);
          }
        ),
      ),
    );
  }
}

class AdWidget extends StatelessWidget {
  Ad ad;
   AdWidget({super.key,required this.ad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: InkWell(
        child: Container(
          decoration:BoxDecoration(
            border:Border.all(color:Colors.red,width: 2),
            borderRadius:BorderRadius.circular(14),
            color:Colors.white,
          ),
          child:Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ad.imageUrl,
                  height: 180,
                  width: MediaQuery.of(context).size.width*0.98,
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Show the image if it's loaded successfully
                    }
                    // Show a loading indicator while the image is loading
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback widget when the image fails to load
                    return Container(
                      height: 180,
                      width: 400,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(12),
              //   child:Image.network
              //   (
              //     ad.imageUrl,
              //
              //     height: 180,width: 400,fit: BoxFit.contain,),
              // ),
              const SizedBox(height: 12,),
              Text(ad.title,style:const TextStyle(color:Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        onTap:(){

          Get.to(AdDetails(
            ad: ad,
          ));


        },
      ),
    );
  }
}