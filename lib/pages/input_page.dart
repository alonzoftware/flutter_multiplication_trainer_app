import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/helpers/constants.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_button.dart';
import 'package:flutter_multiplication_trainer_app/widgets/reusable_card.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  int factor1 = 0;
  int factor2 = 0;
  int result = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplication Trainer'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: FactorCard(factor: factor1),
                    ),
                    Expanded(
                      flex: 1,
                      child: FactorCard(factor: factor2),
                    )
                  ],
                ),
                Center(
                  child: Text(
                    'X',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 55),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: FactorCard(factor: result),
          ),
          BottomButton(
              text: 'GENERATE',
              color: Colors.blueAccent,
              onTap: () => generateFactor),
          BottomButton(text: 'RESULT', onTap: () => calculate),
        ],
      )),
    );
  }

  void generateFactor() {
    Random rnd;
    int min = 5;
    int max = 99;
    rnd = new Random();
    setState(() {
      factor1 = min + rnd.nextInt(max - min);
      factor2 = min + rnd.nextInt(max - min);
      result = 0;
    });
  }

  void calculate() {
    setState(() {
      result = factor1 * factor2;
    });
  }
}

class FactorCard extends StatelessWidget {
  const FactorCard({
    required this.factor,
  });

  final int factor;

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      onPress: () {},
      color: kActiveCardColor,
      cardChild: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Text((factor > 0) ? factor.toString() : '',
                style: kBigLabelTextStyle)),
      ),
    );
  }
}
