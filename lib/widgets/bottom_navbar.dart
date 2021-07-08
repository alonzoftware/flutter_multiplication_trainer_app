import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final double iconSize = 44;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(
              Icons.home,
              size: iconSize,
            ),
            onPressed: () {
              print('Camera Pressed');
            }),
        IconButton(
            icon: Icon(
              Icons.camera,
              size: iconSize,
            ),
            onPressed: () {
              print('Camera Pressed');
            }),
        IconButton(
            icon: Icon(
              Icons.print,
              size: iconSize,
            ),
            onPressed: () {
              print('Camera Pressed');
            }),
      ],
    );
  }
}
