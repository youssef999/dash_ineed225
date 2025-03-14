
// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/categories/edit_subcat.dart';
import 'package:yemen_services_dashboard/features/model/subCat_model.dart';
import '../controllers/subCat_controller.dart';

// ignore: must_be_immutable
class GetSubCat extends StatefulWidget {
   String cat;
   GetSubCat({super.key,required this.cat});

  @override
  State<GetSubCat> createState() => _GetSubCatState();
}

class _GetSubCatState extends State<GetSubCat> {


SubCatController controller=Get.put(SubCatController());
  @override
  void initState() {
 controller.getSubCats(widget.cat);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor:primaryColor,
        title: const Text('القسم الفرعي',
        style:TextStyle(color:Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GetBuilder<SubCatController>(
          builder: (_) {
            if( controller.subCatList.isEmpty){
              return const Center(
                child:Text("no data",
                style:TextStyle(color:Colors.black,
                fontSize: 25,fontWeight:FontWeight.bold
                ),
                ),
              );

            }else{

 return ListView(
              children: [
                const SizedBox(height: 12,),
          
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: controller.subCatList.length,
                  itemBuilder:(context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SubCatCardWidget(
                      subCat: controller.subCatList[index],
                    ),
                  );
                }, gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0, childAspectRatio: 1.8),
            ),
            
            
              ],
            );
            }
           
          }
        ),
      ),
    );
  }
}

class SubCatCardWidget extends StatelessWidget {

  SubCat subCat;
 
  SubCatCardWidget({super.key,required this.subCat});

  @override
  Widget build(BuildContext context) {
    SubCatController controller=Get.put(SubCatController());
    return Container(
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(14),
        border: Border.all(color:Colors.red,width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const SizedBox(height: 8,),
          ClipRRect(
            borderRadius:BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: subCat.image,
             // Uri.encodeFull(subCat.image),
              //subCat.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>  Column(
                children: [
                  SizedBox(
                      height: 71,
                      width:144,
                      child: Image.asset('assets/logoXX.png')),
                 const SizedBox(height: 5,),
                  const Text(
                    maxLines: 7,
                    "هذا يعني ان صورة هذا القسم تعمل ولكنها لا تعمل علي بعض المتصفحات",
                  style:TextStyle(color:Colors.grey,
                  fontSize: 12
                  ),
                  )
                ],
              ),
            //Image.network(subCat.image,
            height: 124,
            ),
          ),
           const SizedBox(height: 8,),
           Text(subCat.name,
           style:const TextStyle(color:Colors.black,
           fontSize: 21,fontWeight:FontWeight.bold
           ),
           ),
           const SizedBox(height: 8,),
           Text(subCat.cat,
           style:const TextStyle(color:primaryColor,
           fontSize: 13,fontWeight:FontWeight.w300
           ),
           ),    const SizedBox(height: 8,),


      

            Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                InkWell(
                 child: const Card(
                  color: primaryColor,
                  child:Padding(
                    padding: EdgeInsets.all(8.0),
                    child:Text(" تعديل " ,
                    style:TextStyle(color:Colors.white,
                    fontSize: 19
                    ),
                  ),
                  ),
                 ),
                 onTap:(){

                   Get.to(EditSubCat(
                     subCat:subCat
                   ));
                  
                 },
               ),


            InkWell(
             child: const Card(
              color: primaryColor,
              child:Padding(
                padding: EdgeInsets.all(8.0),
                child:Text(" حذف ",
                style:TextStyle(color:Colors.white,
                fontSize: 19
                ),
              ),
              ),
             ),
             onTap:(){

              controller.showDeleteConfirmationDialog(
                context,subCat.name
              );
           
             },
           )



              ],
            ),


          
        ],),
      ),
      
    );
  }
}