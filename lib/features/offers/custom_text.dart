
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';


class CustomTextFormField extends StatefulWidget {
  final String hint;
  bool obs;
  bool obx;
  bool? input;
  IconData icon;
  TextInputType type;
  String validateMessage;
  final Color? color;
  int ? max;

  TextEditingController controller;

  CustomTextFormField({
    Key? key,
    required this.hint,
    this.max=2,
    this.obx=false,
  this.validateMessage='',
  this.icon=Icons.person,
    this.type=TextInputType.text,
    this.input,
    required this.obs,
     this.color,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    if (widget.obx == true) {
      return  TextFormField(
        
                      keyboardType: TextInputType.visiblePassword,
                      controller: widget.controller,
        style: TextStyle(color: secondaryTextColor),
                      onSaved: (value) {
                       widget.controller.text = value!;
                      },
                      // validator: (value) {
                      //   if (value!.length > 100) {
                      //     return widget.validateMessage;
                      //   }
                      //   if (value.length < 4) {
                      //     return widget.validateMessage;
                      //   }else{
                      //     return null;

                      //   }
                      // },
                      obscureText: widget.obs,
                      decoration: InputDecoration(

                         fillColor: cardColor,
                        filled: true,
                          border: OutlineInputBorder(
                              borderSide:  BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder:OutlineInputBorder(
                              borderSide:  BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                         
                           suffixIcon: IconButton(
              icon: Icon(
                color: primary,
                widget.obs ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  widget.obs = !widget.obs;
                });
              }),
                          hintText:'كلمة المرور',
                          hintStyle: const TextStyle(color: Colors.grey),
                          labelStyle:
                          TextStyle(color: secondaryTextColor),
                        //  labelText: 'Password',
                          focusColor: primary),
                    );
      
    
    }

    if (widget.obx == false) {
      if(widget.max!>2){
        return    TextFormField(
          maxLines: widget.max,
          keyboardType:widget.type,
                      controller: widget.controller, style: TextStyle(color: secondaryTextColor),
                      onSaved: (value) {
                        widget.controller.text= value!;
                      },
                      // validator: (value) {
                      //   if (value!.length > 100) {
                      //     return widget.validateMessage;
                      //     //return 'Email Cant Be Larger Than 100 Letter';
                      //   }
                      //   if (value.length < 4) {
                      //     return widget.validateMessage;
                      //    // return 'Email Cant Be Smaller Than 4 Letter';
                      //   }
                      //   return null;
                      // },
                      decoration: InputDecoration(

                          fillColor: cardColor,
                        filled: true,
                          border:OutlineInputBorder(
                              borderSide:  BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                         
                          hintText: widget.hint,
                          hintStyle: const TextStyle(color: Colors.grey),
                          labelStyle:  TextStyle(color:secondaryTextColor),
                        //  labelText: widget.hint
                          ),
                      cursorColor: primary
                    );
      }
      else{
        return 
        
          TextFormField(
             keyboardType:widget.type,
                      controller: widget.controller,  style: const TextStyle(color: Colors.black),
                  //    maxLines: widget.max,
                      onSaved: (value) {
                        widget.controller.text= value!;
                      },
                      // validator: (value) {
                      //   if (value!.length > 100) {
                      //     return widget.validateMessage;
                      //     //return 'Email Cant Be Larger Than 100 Letter';
                      //   }
                      //   if (value.length < 4) {
                      //     return widget.validateMessage;
                      //    // return 'Email Cant Be Smaller Than 4 Letter';
                      //   }
                      //   return null;
                      // },
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200]!,
                        filled: true,
                          border: OutlineInputBorder(
                              borderSide:  BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder:OutlineInputBorder(
                              borderSide:  BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                        labelStyle:  const TextStyle(color:Colors.black),
                          hintText: widget.hint,
                          hintStyle: const TextStyle(color: Colors.grey),
                          ),
                      cursorColor: Colors.blue
                    );
      }

    }

    if (widget.input == true) {
      return Container(
        padding: const EdgeInsets.all(11),
        decoration:BoxDecoration(
            border:Border.all(color:Colors.white),
            borderRadius: BorderRadius.circular(2),
            color:Colors.white),
        child: TextFormField(
          obscureText: widget.obs,
          keyboardType: TextInputType.number,
          maxLines: widget.max,
          controller: widget.controller,
          style: const TextStyle(color: Colors.black),

          decoration: InputDecoration(
            label: Text(widget.hint,style:const TextStyle(color:Colors.grey)),
            hintStyle:  TextStyle(color: Colors.grey[700]!),
            fillColor: Colors.white,
          ),
        ),
      );
    }

    return Container();
  }
}
