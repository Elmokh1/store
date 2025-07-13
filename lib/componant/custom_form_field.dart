import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef MyValidator = String? Function(String?);

class CustomFormField extends StatelessWidget {
  String? label;
  String? hint;
  bool isPassword;
  TextInputType keyboardType ;
  MyValidator? validator;
  TextEditingController? controller;
  int lines;
  CustomFormField({
     this.label,
     this.hint,
     this.validator,
     this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.lines=1
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(fontSize: 20),
      maxLines: lines,
      minLines: lines,
      controller: controller,
      validator:validator,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true, //<-- SEE HERE
        fillColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        // label: Text(label,style: GoogleFonts.aboreto(
        //     color: Colors.blue,
        //   fontSize: 20,
        //   fontWeight: FontWeight.bold
        // ),),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Theme.of(context).primaryColor,width: 2)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Theme.of(context).primaryColor,width: 2)
        )
      ),
    );
  }
}
