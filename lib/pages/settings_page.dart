import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiplication_trainer_app/preferences/shared_preferences.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_button.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final prefs = sharedPrefsService;

  TextEditingController textEditingControllerMinLimit =
      new TextEditingController(text: 0.toString());

  TextEditingController textEditingControllerMaxLimit =
      new TextEditingController(text: 0.toString());

  TextEditingController textEditingControllerNumRepetitions =
      new TextEditingController(text: 0.toString());

  TextEditingController textEditingControllerNumOperations =
      new TextEditingController(text: 0.toString());

  late int _opcionSeleccionada;

  List<int> _bases = [5, 10, 20, 50, 100, 200];

  @override
  void initState() {
    _opcionSeleccionada = prefs.base;
    textEditingControllerMinLimit.text = prefs.minLimit.toString();
    textEditingControllerMaxLimit.text = prefs.maxLimit.toString();
    textEditingControllerNumRepetitions.text = prefs.numRepetitions.toString();
    textEditingControllerNumOperations.text = prefs.numOperations.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplication Trainer'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _crearDropdown(),
            Expanded(
              child: ListView(
                children: [
                  TextFieldLimit(
                    labelText: 'Min. Limit',
                    textEditingController: textEditingControllerMinLimit,
                    onChanged: (value) {
                      //textEditingControllerMinLimit.text = value;
                      //FocusScope.of(context).unfocus();
                    },
                  ),
                  TextFieldLimit(
                    labelText: 'Max. Limit',
                    textEditingController: textEditingControllerMaxLimit,
                    onChanged: (value) {
                      //textEditingControllerMaxLimit.text = value;
                      //FocusScope.of(context).unfocus();
                    },
                  ),
                  TextFieldLimit(
                    labelText: 'Num. Operations',
                    textEditingController: textEditingControllerNumOperations,
                    onChanged: (value) {
                      //textEditingControllerMaxLimit.text = value;
                      //FocusScope.of(context).unfocus();
                    },
                  ),
                  TextFieldLimit(
                    labelText: 'Num. Repetitions',
                    textEditingController: textEditingControllerNumRepetitions,
                    onChanged: (value) {
                      //textEditingControllerMaxLimit.text = value;
                      //FocusScope.of(context).unfocus();
                    },
                  )
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: BottomButton(
                      text: 'CANCEL',
                      onTap: () {
                        cancel(context);
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: BottomButton(
                      text: 'SAVE',
                      color: Colors.green.shade800,
                      onTap: () {
                        save(context);
                      }),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }

  void cancel(BuildContext context) {
    Navigator.pop(context);
  }

  void save(BuildContext context) {
    prefs.minLimit = int.parse(textEditingControllerMinLimit.text);
    prefs.maxLimit = int.parse(textEditingControllerMaxLimit.text);
    prefs.numRepetitions = int.parse(textEditingControllerNumRepetitions.text);
    prefs.numOperations = int.parse(textEditingControllerNumOperations.text);
    prefs.base = _opcionSeleccionada;
    Navigator.pop(context);
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];

    _bases.forEach((base) {
      final width = MediaQuery.of(context).size.width;
      lista.add(DropdownMenuItem(
        child: Container(
          child: Center(
              child: Text(
            base.toString(),
            style: TextStyle(fontSize: 25),
          )),
          width: width * 0.6,
        ),
        value: base.toString(),
      ));
    });

    return lista;
  }

  Widget _crearDropdown() {
    return Row(
      children: <Widget>[
        Text(
          'Base',
          style: TextStyle(color: Colors.grey, fontSize: 20),
        ),
        SizedBox(width: 30.0),
        Expanded(
          child: DropdownButton(
            value: _opcionSeleccionada.toString(),
            items: getOpcionesDropdown(),
            onChanged: (opt) {
              print(opt);
              //_opcionSeleccionada = int.parse(opt.toString());
              setState(() {
                _opcionSeleccionada = int.parse(opt.toString());
                switch (_opcionSeleccionada) {
                  case 5:
                    textEditingControllerMinLimit.text = '1';
                    textEditingControllerMaxLimit.text = '10';
                    break;
                  case 10:
                    textEditingControllerMinLimit.text = '1';
                    textEditingControllerMaxLimit.text = '20';
                    break;
                  case 20:
                    textEditingControllerMinLimit.text = '10';
                    textEditingControllerMaxLimit.text = '30';
                    break;
                  case 50:
                    textEditingControllerMinLimit.text = '40';
                    textEditingControllerMaxLimit.text = '60';
                    break;
                  case 100:
                    textEditingControllerMinLimit.text = '90';
                    textEditingControllerMaxLimit.text = '110';
                    break;
                  case 200:
                    textEditingControllerMinLimit.text = '180';
                    textEditingControllerMaxLimit.text = '120';
                    break;
                  default:
                }
              });
            },
          ),
        )
      ],
    );
  }
}

class TextFieldLimit extends StatelessWidget {
  const TextFieldLimit({
    required this.textEditingController,
    required this.onChanged,
    required this.labelText,
  });

  final TextEditingController textEditingController;
  final Function onChanged;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      textAlign: TextAlign.center,
      decoration: new InputDecoration(labelText: labelText),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 25),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      onChanged: (value) => onChanged(value),
    );
  }
}
