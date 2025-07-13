import 'package:flutter/material.dart';

typedef MyValidator = String? Function(String?);

class CustomTextFormField extends StatelessWidget {
  String Label;
  TextEditingController controller;
  MyValidator validator;
  bool isPassword;
  int lines ;
  int maxlines ;

  CustomTextFormField(
      {required this.Label,
      this.isPassword = false,
      required this.controller,
      required this.validator,
         this.lines=1,
        this.maxlines = 1,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:20.0,top: 15,),
      child: TextFormField(
        minLines: lines,
        maxLines: maxlines,
        obscureText: isPassword,
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          label: Text("$Label"),
        ),
      ),
    );
  }
}
