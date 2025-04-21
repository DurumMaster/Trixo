import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String text;
  final Color color;
  final bool? value;

  const CustomCheckbox({super.key, required this.text, required this.color, this.value = false});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    bool? value = widget.value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CheckboxListTile(
          title: Text(
            widget.text,
            style: TextStyle(color: widget.color)
          ),
          value: value,
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
          activeColor: colors.secondary,
          controlAffinity: ListTileControlAffinity.leading,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: colors.primary, width: 2.0),
          ),
        )
      ]
    );
  }
}