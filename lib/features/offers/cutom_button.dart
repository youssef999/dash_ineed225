
// ignore_for_file: file_names

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color? btnColor;
  Color color1;
  Color color2;
  double width;

  CustomButton({
    super.key,
    required this.text,
    this.width = 110,
    required this.onPressed,
    this.color1 = Colors.black,
    this.color2 = Colors.white,
    this.btnColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: 50,
        child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                color: color1,
                borderRadius: const
                BorderRadius.all(Radius.circular(22)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Text(
                    text,
                    style:  TextStyle(
                        color: color2,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
            onTap: () {
              onPressed();
            })

        // RaisedButton(
        //
        //   elevation: 10,
        //   onPressed: onPressed(),
        //   color: color1,
        //   // shape: RoundedRectangleBorder(
        //   //     borderRadius: BorderRadius.circular(30)),
        //   child: Padding(
        //     padding: EdgeInsets.all(10),
        //     child: Text(
        //       text,
        //       style: getRegularStyle(color: color2,fontSize:20)
        //     ),
        //   ),
        // ),
        );
  }
}
