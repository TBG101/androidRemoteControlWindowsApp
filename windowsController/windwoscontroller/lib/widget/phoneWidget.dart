import 'package:flutter/material.dart';

class PhoneWidget extends StatelessWidget {
  const PhoneWidget(
      {super.key,
      required this.id,
      required this.width,
      required this.index,
      required this.callbackFunction});
  final void Function(int x) callbackFunction;
  final double width;
  final String id;
  final int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callbackFunction(index);
      },
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: width,
            child: Image.asset(
              "assets/images/phone.png",
              fit: BoxFit.fitHeight,
              gaplessPlayback: true,
              cacheHeight: width.toInt(),
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
