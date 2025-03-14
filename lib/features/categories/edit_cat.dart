

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yemen_services_dashboard/features/categories/cat_model.dart';

import '../../core/theme/colors.dart';
import 'cat_controller.dart';
import 'image_widget.dart';

class EditCat extends StatefulWidget {

   Cat cat; // Category object passed via constructor

  EditCat({super.key, required this.cat});

  @override
  State<EditCat> createState() => _EditCatState();
}

class _EditCatState extends State<EditCat> {
  CatController controller = Get.put(CatController());
  bool isLoading = false;

  @override
  void initState() {
    controller.getCatsLength(widget.cat.index);
    super.initState();
    // Initialize the controller with the current category data
    controller.nameController.text = widget.cat.name;
    controller.nameEnController.text = widget.cat.nameEn;
    controller.selectedCatNum = widget.cat.index;
  //  controller.selectedItem = widget.cat.index.toString(); // Assuming there's a parent category
 //   controller.selectCatNum = widget.cat.index; // Assuming there's an index for ordering
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 71,
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GetBuilder<CatController>(
          builder: (_) {
            return ListView(
              children: [
                const SizedBox(height: 12),
                Column(
                  children: [
                    (controller.imageUrl == null)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.cat.imageUrl,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Column(
                          children: [
                            SizedBox(
                              height: 71,
                              child: Image.asset('assets/logoXX.png'),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              maxLines: 7,
                              "هذا يعني ان صورة هذا القسم تعمل ولكنها لا تعمل علي بعض المتصفحات",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        height: 124,
                      ),
                    )
                        : const SizedBox(),
                    const SizedBox(height: 24),
                    const Text(
                      "اضغط هنا لتغيير صورة القسم  ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    ImageWidget(txt: 'اضغط هنا لتغيير صورة القسم  '),
                    const SizedBox(height: 20),
                  ],
                ),

                const Text('اسم القسم',style:TextStyle(color:Colors.black,
                fontSize: 18
                ),),
                const SizedBox(height: 5,),
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    hintText: 'اسم القسم',
                  ),
                ),
                const SizedBox(height: 21),
                const Text('اسم القسم بالغة الانجليزية ',style:TextStyle(color:Colors.black,
                    fontSize: 18
                ),),
                const SizedBox(height: 5,),
                TextField(
                  controller: controller.nameEnController,
                  decoration: const InputDecoration(
                    hintText: 'اسم القسم باللغة الانجليزية',
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  "الترتيب الحالي = ${widget.cat.index}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Center(
                  child: Text("ترتيب الاقسام يعمل بشكل عكسي بمعني اعلي رقم في الاختيار يعني ظهوره اول قسم عند المستخدم ",
                              style:TextStyle(color:Colors.blue,
                              fontSize: 14
                              )),
                ),
              //  const SizedBox(height: 5,),

                const SizedBox(height: 22),
                const Text(
                  "اختر ترتيب هذا القسم ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                DropdownButton<int>(
                  value: controller.selectedCatNum,
                  hint: const Text(
                    'اختر الترتيب : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                    ),
                  ),
                  onChanged: (int? newValue) {
                    controller.changeCatNum(newValue!);
                    //controller.changeSelectedCatNum(newValue!);
                  },
                  items: controller.catNum.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),


                const SizedBox(height: 40),
                (isLoading == false)
                    ? Padding(
                  padding: const EdgeInsets.only(left: 48.0, right: 48),
                  child: InkWell(
                    child: const Card(
                      color: primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(9.0),
                        child: Center(
                          child: Text(
                            "تعديل  ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      if (controller.imageUrl == null) {
                        controller.updateCat(
                          widget.cat.name,
                          {
                            "name": controller.nameController.text,
                            "nameEn": controller.nameEnController.text,
                            "image": widget.cat.imageUrl,
                            'num': controller.selectedCatNum,
                          },
                        );
                      } else {
                        Future.delayed(const Duration(seconds: 7)).then((value) {
                          controller.updateCat(
                            widget.cat.name,
                            {
                              "name": controller.nameController.text,
                              "nameEn": controller.nameEnController.text,
                              "image": controller.uploadedFileURL,
                              'num': controller.selectedCatNum,
                            },
                          );
                        });
                      }
                    },
                  ),
                )
                    : const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}