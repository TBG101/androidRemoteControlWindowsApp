import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.textString,
    this.function,
  });
  final String textString;
  final void Function()? function;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 50,
        width: 150,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5e5a66),
          ),
          onPressed: function,
          child: Text(
            textString,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
