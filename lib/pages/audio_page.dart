import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_navbar.dart';

class AudioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Page'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            BottomNavBar(),
          ],
        ),
      ),
    );
  }
}
