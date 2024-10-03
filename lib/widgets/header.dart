import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/model.dart';



class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<Model>(builder: (context, model, child) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Spacer(),
        TextButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: screenWidth * 0.15,
            height: screenHeight * 0.1,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.white),
              image: DecorationImage(
                image: model.image,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ]);
    });
  }
}
