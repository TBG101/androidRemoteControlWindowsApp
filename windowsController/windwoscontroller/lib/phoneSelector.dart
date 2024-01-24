import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwoscontroller/widget/phoneWidget.dart';
import 'package:http/http.dart' as http;

class PhoneSelectorPage extends StatelessWidget {
  const PhoneSelectorPage({super.key, required this.myPhones});
  final List myPhones;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ((w / ((w / 3) - 8 * 3 * 2)).floor())
              .floor(), // Number of columns in the grid
          crossAxisSpacing: 8.0, // Spacing between columns
          mainAxisSpacing: 8.0, // Spacing between rows
        ),
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          // You can customize the grid item here
          return GridTile(
            child: PhoneWidget(id: "zfae", width: (w / 3) - 8 * 3 * 2),
          );
        },
      ),
    );
  }
}
