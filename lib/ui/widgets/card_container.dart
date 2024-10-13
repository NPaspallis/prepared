import 'package:flutter/material.dart';

import '../styles/style.dart';

///A card container widget with special background color and padding.
class CardContainer extends StatelessWidget {

  final Widget child;


  const CardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: screenPadding,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Card(
          child: Padding(
            padding: standardPadding,
            child: child
          ),
        ),
      ),
    );
  }
}
