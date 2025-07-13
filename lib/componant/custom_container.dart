import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  Color color;
  String text;
  Color textColor;
  Function ontap;
  CustomContainer({required this.color, required this.text,required this.textColor,required this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        ontap();
      },
      child: Container(
        width: 342,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
