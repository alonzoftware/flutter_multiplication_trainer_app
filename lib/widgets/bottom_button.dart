import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/helpers/constants.dart';

class BottomButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final Color color;
  BottomButton(
      {required this.text,
      required this.onTap,
      this.color = kBottomContainerColor});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        width: double.infinity,
        height: kBottomContainerHeight,
        child: Center(
          child: Text(
            text,
            style: kMediumLabelTextStyle,
          ),
        ),
      ),
    );
  }
}
