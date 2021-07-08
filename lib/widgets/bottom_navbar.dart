import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final double iconSize = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blueGrey[900]),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: Icon(
                Icons.home,
                size: iconSize,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'home');
              }),
          IconButton(
              icon: Icon(
                Icons.headphones,
                size: iconSize,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'audio');
              }),
          IconButton(
              icon: Icon(
                Icons.settings,
                size: iconSize,
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'settings');
              }),
        ],
      ),
    );
  }
}
