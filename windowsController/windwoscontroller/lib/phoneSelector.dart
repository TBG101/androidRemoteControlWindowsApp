import 'package:flutter/material.dart';
import 'package:windwoscontroller/widget/phoneWidget.dart';

class PhoneSelectorPage extends StatelessWidget {
  PhoneSelectorPage(
      {super.key, required this.myPhones, required this.callbackFunction});

  final void Function(int x) callbackFunction;
  final List myPhones;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return myPhones.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: w > 700
                ? GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: myPhones.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GridTile(
                        child: PhoneWidget(
                          id: index.toString(),
                          width: (w / 4),
                          index: index,
                          callbackFunction: callbackFunction,
                        ),
                      );
                    },
                  )
                : Scrollbar(
                    controller: scrollController,
                    
                    thumbVisibility: true,
                    thickness: 10,
                    child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return PhoneWidget(
                          id: index.toString(),
                          width: (w / 2),
                          index: index,
                          callbackFunction: callbackFunction,
                        );
                      },
                    ),
                  ))
        : const Center(
            child: Text(
              "You have no phones connected",
              style: TextStyle(fontSize: 22),
            ),
          );
  }
}
