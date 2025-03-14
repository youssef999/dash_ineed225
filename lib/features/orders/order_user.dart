


 import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class UserOrderDetails extends StatefulWidget {

   const UserOrderDetails({super.key});

   @override
   State<UserOrderDetails> createState() => _UserOrderDetailsState();
 }

 class _UserOrderDetailsState extends State<UserOrderDetails> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         backgroundColor:primaryColor,
         title: const Text('',
         style:TextStyle(color:Colors.white,
         fontWeight: FontWeight.bold,
           fontSize: 21
         ),
         ),
       ),
       body:Padding(
         padding: const EdgeInsets.all(8.0),
         child: ListView(children: const [
           SizedBox(height: 19,),

         ],),
       ),
     );
   }
 }
