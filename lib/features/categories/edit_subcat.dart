import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/features/categories/cat_controller.dart';
import 'package:yemen_services_dashboard/features/categories/image_widget.dart';
import '../../core/theme/colors.dart';
import '../model/subCat_model.dart';

 class EditSubCat extends StatefulWidget {
  SubCat subCat;

 EditSubCat({super.key,required this.subCat});

  @override
  State<EditSubCat> createState() => _AddSubCatState();
}

class _AddSubCatState extends State<EditSubCat> {



  CatController controller=Get.put(CatController());
  bool isLoading=false;
  @override
  void initState() {

    controller.getCats();
    controller.getSubCatsLength(widget.subCat.cat,widget.subCat.index);
    controller.subCatNameController.text=widget.subCat.name;
    controller.subCatNameEnController.text=widget.subCat.nameEn;
    Future.delayed(const Duration(seconds: 2)).then((value) {
      controller.passCatValue(widget.subCat.cat);
      print("SUB11====${controller.subCatNum}");
      print("SUB22====${controller.selectSubCatNum}");
    });

   // controller.selectedItem=widget.subCat.cat;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          toolbarHeight: 71,
          backgroundColor:primaryColor
      ),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: GetBuilder<CatController>(
          builder: (_) {
            return ListView(children: [

              const  SizedBox(height: 12,),
              Column(
                children: [
                  (controller.imageUrl==null)?
                  ClipRRect(
                    borderRadius:BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl:widget.subCat.image,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>  Column(
                        children: [
                          SizedBox(
                              height: 71,
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
                  ):const SizedBox(),
                  const SizedBox(height: 24),
                  const Text("اضغط هنا لتغيير صورة القسم  ",style:TextStyle(color:Colors.grey),),
                  ImageWidget(txt: 'اضغط هنا لتغيير صورة القسم  '),
                  const SizedBox(height: 20),
                ],
              ),
              TextField(
                controller: controller.subCatNameController,
                decoration:const InputDecoration(
                    hintText: 'اسم القسم الفرعي'
                ),

              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller.subCatNameEnController,
                decoration:const InputDecoration(
                    hintText: 'اسم القسم الفرعي'
                ),

              ),
              const SizedBox(height: 30),

              Text("الترتيب الحالي =  ${widget.subCat.index}",

                 style:const TextStyle(color:Colors.black,fontSize: 22,fontWeight:FontWeight.bold),
              ),




              const SizedBox(height: 12),
              const Text("اختر ترتيب هذا القسم ",
              style:TextStyle(color:Colors.grey,
              fontSize: 14,fontWeight:FontWeight.w500,

              ),
              ),
              const SizedBox(height: 3),
              DropdownButton<int>(
            value: controller.selectSubCatNum, // Currently selected value
            hint: const Text('اختر الترتيب : ',
            style:TextStyle(
            color:Colors.black,fontSize: 21,
            ),
            ), // Hint text when no value is selected
            onChanged: (int? newValue) {

              controller. changeSelectsedNum(newValue!);
            // setState(() {
            //  = newValue; // Update the selected value
            // });
            },
            items: controller.subCatNum.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString(),
            style:const TextStyle(
              color:Colors.black,fontSize: 15,fontWeight:FontWeight.w500
            ),
            ), // Display the integer as text
            );
            }).toList(),
            ),
              const SizedBox(height: 12),

              const Row(
                children: [
                  Text(
                    "اختر القسم ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,fontWeight:FontWeight.w600
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5,),
              Text("القسم الحالي : ${widget.subCat.cat}",style:const TextStyle(color:Colors.black),),
              const SizedBox(height: 5,),
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:Colors.grey[300],
                  ),
                  child: GetBuilder<CatController>(builder: (_) {
                    return DropdownButton<String>(
                      underline: const SizedBox.shrink(),
                      value: controller.selectedItem,
                      onChanged: (newValue) {
                        controller.changeCatValue(newValue!);
                      },
                      items:
                      controller.catListNames.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: primaryColor),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  })),
              const SizedBox(height: 40),

              (isLoading==false)?
              Padding(
                padding: const EdgeInsets.only(left: 48.0,right: 48),
                child: InkWell(
                  child: const Card(
                    color: primaryColor,
                    child:Padding(
                      padding: EdgeInsets.all(9.0),
                      child:  Center(
                        child: Text("تعديل  ",
                          style:TextStyle(
                              color:Colors.white,
                              fontSize: 21
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTap:(){

                    print("S==="+controller.selectSubCatNum.toString());

                    setState(() {
                      isLoading=true;
                    });
                    if(controller.imageUrl==null){
                      controller.updateSubCategoryDocument(
                          widget.subCat.name,
                          {
                            "name": controller.subCatNameController.text,
                            "cat": controller.selectedItem,
                            "image": widget.subCat.image,
                            'index':controller.selectSubCatNum,
                          }
                      );
                    }
                    else{
                      Future.delayed(const Duration(seconds: 7)).then((value) {
                        controller.updateSubCategoryDocument(
                            widget.subCat.name,
                            {
                              "name": controller.subCatNameController.text,
                              "cat": controller.selectedItem,
                              "image": controller.uploadedFileURL,
                              'index':controller.selectSubCatNum,
                              //imageUrl
                            }
                        );
                      });
                    }
                  },
                ),
              ):const Center(
                child: CircularProgressIndicator(),
              )
            ],);
          }
        ),
      ),
    );
  }
}