import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? title;
  final TextInputType? inputType;

  const CustomTextField(
      {Key? key, this.controller, this.hintText, this.title, this.inputType})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: FocusScope(
            onFocusChange: (v) {
              setState(() {
                isSelected = v;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.inputType,
              // expands: true,
              maxLines: null,
              decoration: InputDecoration(
                //icon: Icon(Icons.person),
                hintText: widget.hintText,
                labelText: widget.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
