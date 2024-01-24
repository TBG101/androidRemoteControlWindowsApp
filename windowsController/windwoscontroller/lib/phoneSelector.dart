import 'package:flutter/material.dart';
import 'package:windwoscontroller/widget/phoneWidget.dart';

class PhoneSelectorPage extends StatelessWidget {
  const PhoneSelectorPage(
      {super.key, required this.myPhones, required this.callbackFunction});
  final void Function(int x) callbackFunction;
  final List myPhones;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return myPhones.isEmpty
        ? const Center(
            child: Text(
              "You have no phones connected",
              style: TextStyle(fontSize: 22),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ((w / ((w / 4) - 8 * 4 * 2)).floor()).floor(),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: myPhones.length,
              itemBuilder: (BuildContext context, int index) {
                return GridTile(
                  child: PhoneWidget(
                    id: index.toString(),
                    width: (w / 4) - 8 * 4 * 2,
                    index: index,
                    callbackFunction: callbackFunction,
                  ),
                );
              },
            ),
          );
  }
}
