
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  final Color cardColor;
  final Color textColor;
  final Function(String) onValueChanged;

  const Calculator({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.onValueChanged,
  });

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = '0';
  String _currentNumber = '';
  String _operation = '';
  double _num1 = 0;
  double _num2 = 0;

  void _buttonPressed(String buttonText) {
    if (buttonText == 'C') {
      _output = '0';
      _currentNumber = '';
      _operation = '';
      _num1 = 0;
      _num2 = 0;
    } else if (buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '/' ||
        buttonText == 'x') {
      if (_currentNumber.isNotEmpty) {
        _num1 = double.parse(_currentNumber);
        _operation = buttonText;
        _currentNumber = '';
      }
    } else if (buttonText == '.') {
      if (!_currentNumber.contains('.')) {
        _currentNumber += '.';
      }
    } else if (buttonText == '=') {
      if (_currentNumber.isNotEmpty) {
        _num2 = double.parse(_currentNumber);
        if (_operation == '+') {
          _output = (_num1 + _num2).toString();
        } else if (_operation == '-') {
          _output = (_num1 - _num2).toString();
        } else if (_operation == 'x') {
          _output = (_num1 * _num2).toString();
        } else if (_operation == '/') {
          _output = (_num1 / _num2).toString();
        }
        _num1 = 0;
        _num2 = 0;
        _currentNumber = _output;
        _operation = '';
      }
    } else {
      _currentNumber += buttonText;
      _output = _currentNumber;
    }

    setState(() {});
    widget.onValueChanged(_output);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          ...['C', '', '%', '/'],
          ...['7', '8', '9', 'x'],
          ...['4', '5', '6', '-'],
          ...['1', '2', '3', '+'],
          ...['.', '0', '=', 'OK'],
        ].map((key) {
          return ElevatedButton(
            onPressed: () => _buttonPressed(key),
            child: Text(key, style: const TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: widget.textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
