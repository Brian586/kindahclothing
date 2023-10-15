import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

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
              // validator: (value) {
              //   if (value!.isEmpty) {
              //     return "Fill this";
              //   } else {
              //     return null;
              //   }
              // },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPhoneField extends StatefulWidget {
  final void Function(PhoneNumber) onChanged;
  final TextEditingController controller;

  const CustomPhoneField({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
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
            child: IntlPhoneField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              onChanged: widget.onChanged,
              initialCountryCode: "KE",
              decoration: const InputDecoration(
                hintText: "700-000-000",
                labelText: "Phone Number",
              ),
              validator: (phone) {
                if (phone!.number.startsWith("7") ||
                    phone.number.startsWith("1")) {
                  return "";
                } else {
                  return "Wrong Format. Start with '7' i.e '7xx-xxx-xxx'";
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
