import 'dart:math';
import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/backgrounds/audio_background.dart';

import 'package:flutter_multiplication_trainer_app/helpers/constants.dart';
import 'package:flutter_multiplication_trainer_app/preferences/shared_preferences.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_button.dart';
import 'package:flutter_multiplication_trainer_app/widgets/reusable_card.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final prefs = sharedPrefsService;
  int factor1 = 0;
  int factor2 = 0;
  int result = 0;
  @override
  Widget build(BuildContext context) {
    factor1 = prefs.factor1;
    factor2 = prefs.factor2;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Multiplication Trainer'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 5),
            child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'settings');
                },
                icon: Icon(Icons.settings)),
          )
        ],
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
              onTap: generateFactor),
          BottomButton(text: 'RESULT', onTap: calculate),
        ],
      )),
    );
  }

  void generateFactor() {
    Random rnd;
    int min = prefs.minLimit;
    int max = prefs.maxLimit;
    rnd = new Random();

    factor1 = min + rnd.nextInt(max - min);
    factor2 = min + rnd.nextInt(max - min);
    prefs.factor1 = factor1;
    prefs.factor2 = factor2;
    result = 0;
    setState(() {});
    AudioService.stop();
  }

  void calculate() {
    setState(() {
      result = factor1 * factor2;
    });
    // AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
    AudioService.start(backgroundTaskEntrypoint: textToSpeechTaskEntrypoint);
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
