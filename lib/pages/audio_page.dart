import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/models/operation.dart';
import 'package:flutter_multiplication_trainer_app/preferences/shared_preferences.dart';
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
              child: ListOperations(),
            ),
            BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class ListOperations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = sharedPrefsService;
    Random rnd;
    int min = prefs.minLimit;
    int max = prefs.maxLimit;
    int factor1 = 0;
    int factor2 = 0;
    int result = 0;
    int count = 25;
    List<Operation> operations = [];
    for (int i = 0; i < count; i++) {
      rnd = new Random();

      factor1 = min + rnd.nextInt(max - min);
      factor2 = min + rnd.nextInt(max - min);
      result = factor1 * factor2;
      print('$i : $factor1 $factor2 $result');
      Operation opTemp =
          new Operation(factor1: factor1, factor2: factor2, result: result);
      operations.add(opTemp);
    }
    return Container(
      child: ListView.builder(
        itemCount: operations.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text(
                  '${operations[index].factor1} X ${operations[index].factor2} =  ${operations[index].result}'));
        },
      ),
    );
  }
}
