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
    } else if (buttonText == 'OK') {
      // Just close or confirm action
      return;
    } else if (buttonText == 'X') {
      // Delete last character
      if (_currentNumber.isNotEmpty) {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
        _output = _currentNumber.isEmpty ? '0' : _currentNumber;
      }
    } else if (buttonText == '%') {
      if (_currentNumber.isNotEmpty) {
        double value = double.parse(_currentNumber);
        _output = (value / 100).toString();
        _currentNumber = _output;
      }
    } else if (buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '÷' ||
        buttonText == '×') {
      if (_currentNumber.isNotEmpty) {
        _num1 = double.parse(_currentNumber);
        _operation = buttonText;
        _currentNumber = '';
      }
    } else if (buttonText == '.') {
      if (!_currentNumber.contains('.')) {
        if (_currentNumber.isEmpty) {
          _currentNumber = '0.';
        } else {
          _currentNumber += '.';
        }
      }
    } else if (buttonText == '=') {
      if (_currentNumber.isNotEmpty && _operation.isNotEmpty) {
        _num2 = double.parse(_currentNumber);
        if (_operation == '+') {
          _output = (_num1 + _num2).toString();
        } else if (_operation == '-') {
          _output = (_num1 - _num2).toString();
        } else if (_operation == '×') {
          _output = (_num1 * _num2).toString();
        } else if (_operation == '÷') {
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
    widget.onValueChanged(_output == '0' ? '0' : _output);
  }

  Color _getButtonColor(String key) {
    // Top row buttons (C, X, %, ÷)
    if (key == 'C' || key == 'X') {
      return Colors.grey.shade300;
    }
    if (key == '%' || key == '÷') {
      return const Color(0xFF5B9BD5); // Blue color
    }
    // Operation buttons (×, -, +)
    if (key == '×' || key == '-' || key == '+') {
      return const Color(0xFF5B9BD5); // Blue color
    }
    // Number buttons and special buttons
    if (key == '.' || key == '=' || key == 'OK') {
      return const Color(0xFF3C4A5C); // Dark blue-grey
    }
    // Number buttons (0-9)
    return const Color(0xFF3C4A5C); // Dark blue-grey
  }

  Color _getTextColor(String key) {
    // Light background buttons have dark text
    if (key == 'C' || key == 'X') {
      return Colors.black87;
    }
    // All other buttons have white text
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final buttonKeys = [
      ['C', 'X', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['.', '0', '=', 'OK'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: buttonKeys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      onPressed: () => _buttonPressed(key),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(key),
                        foregroundColor: _getTextColor(key),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}