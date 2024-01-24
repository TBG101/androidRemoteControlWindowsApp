import 'package:flutter/material.dart';

class PhoneWidget extends StatelessWidget {
  const PhoneWidget({super.key, required this.id, required this.width});
  final double width;
  final String id;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: SizedBox(
                width: width,
                child: Image.asset(
                  "assets/images/phone.png",
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(id),
          ),
        ],
      ),
    );
  }
}
