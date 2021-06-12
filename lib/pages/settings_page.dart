import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_button.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplication Trainer'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(child: Container()),
          BottomButton(text: 'RETURN', onTap: () {}),
        ],
      )),
    );
  }
}
