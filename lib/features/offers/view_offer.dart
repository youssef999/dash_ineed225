


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';

// ignore: must_be_immutable
class ViewOfferDetails extends StatefulWidget {
  QueryDocumentSnapshot offer;
   ViewOfferDetails({super.key,required this.offer});

  @override
  State<ViewOfferDetails> createState() => _ViewOfferDetailsState();
}

class _ViewOfferDetailsState extends State<ViewOfferDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:primaryColor,
        title: const Text('الاعلانات',
        style:TextStyle(color:Colors.white,
        fontSize: 21
        ),
        ),
      ),
      body:Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [

          ClipRRect(
            borderRadius:BorderRadius.circular(14),
            child:Image.network(widget.offer['image'],
            height: 424,
            width: 400,
            fit:BoxFit.contain
            ),
          ),
          const SizedBox(height: 21,),
        
          Text(widget.offer['title'],
          style:const TextStyle(color:Colors.black,
          fontSize: 22,fontWeight:FontWeight.bold
          ),
          ),
          const SizedBox(height: 21,),
          Text(widget.offer['des'],
          style:const TextStyle(color:Colors.grey,
          fontSize: 13,fontWeight:FontWeight.bold
          ),
          ),
        
        
        ],),
      )
    );
  }
}