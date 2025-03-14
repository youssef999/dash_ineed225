import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cat_controller.dart';

// ignore: must_be_immutable
class ImageWidget extends StatefulWidget {

  String txt;
  ImageWidget({super.key,required this.txt});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {

  
  @override
  Widget build(BuildContext context) {
     
    CatController controller =Get.put(CatController());

           return   GetBuilder<CatController>(
             builder: (_) {
               return Column(
                    children: [
                      SizedBox(
                          height: 210,
                          width: 200,
                          child: GestureDetector(
                            onTap: () async {
                              await controller.imgFromGallery();
                              setState(
                                  () {}); // Call setState inside dialog to update the UI after image is picked
                            },
                            child: controller.imageUrl == null
                                ? Container(
                                    width: double.infinity,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image,
                                        color: Colors.grey[600]),
                                  )
                                : Image.network(
                                    controller.imageUrl!, // Display selected image
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),






                      // (controller.images.isEmpty)?
                      // InkWell(
                      //   child: Container(
                      //     decoration:BoxDecoration(
                      //       borderRadius:BorderRadius.circular(12),
                      //       border: Border.all(color:  Colors.grey[200]!),
                      //       color: Colors.white,
                      //     ),
                      //     child:Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Column(
                      //         children: [
                      //           const   SizedBox(height: 6,),
                      //           ClipRRect(
                      //               borderRadius:BorderRadius.circular(12),
                      //               child: Image.asset('assets/images/',height: 90,)),

                      //       const   SizedBox(height: 6,),
                      //           Text(widget.txt,
                      //           style:const TextStyle(
                      //             color:Colors.black,
                      //             fontSize: 18
                      //           ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      //   onTap:(){
                      //     controller.pickMultipleImages();
                      //   },
                      // ): buildGridView(controller)
                    ],
                  );
             }
           );
           
  }
}



  Widget buildGridView(CatController controller) {
  
    return InkWell(
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: controller.images.length,
        gridDelegate: const
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
                decoration:BoxDecoration(
                  borderRadius:BorderRadius.circular(7),
                  color:Colors.grey[200]
                ),
                child: Image.file(File(controller.images[index].path))),
          );
        },
      ),
      onTap:(){
        controller.pickMultipleImages();
      },
    );
  }
