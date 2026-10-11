
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '0';

  double? accumulator;
  String? pendingOperator;

  bool awaitingOperand = false;
  bool resultShown = false;

  final List<String> buttons = [
    'AC', 'DEL', '√', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
    '%',
  ];

  String formatNumber(double number) {
    if (!number.isFinite) {
      return 'Error';
    }

    if (number == 0) {
      return '0';
    }

    if (number == number.truncateToDouble()) {
      return number.toStringAsFixed(0);
    }

    final String formatted = number.toStringAsPrecision(12);

    if (formatted.contains('e') || formatted.contains('E')) {
      return formatted;
    }

    return formatted
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  double calculate(double first, double second, String operator) {
    switch (operator) {
      case '+':
        return first + second;
      case '−':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        return first / second;
      default:
        return second;
    }
  }

  void enterDigit(String digit) {
    setState(() {
      if (resultShown) {
        accumulator = null;
        pendingOperator = null;
        awaitingOperand = false;
        resultShown = false;
        display = digit;
        return;
      }

      if (awaitingOperand) {
        display = digit;
        awaitingOperand = false;
        return;
      }

      if (display == '0') {
        display = digit;
      } else {
        display += digit;
      }
    });
  }

  void enterDecimal() {
    setState(() {
      if (resultShown) {
        accumulator = null;
        pendingOperator = null;
        awaitingOperand = false;
        resultShown = false;
        display = '0.';
        return;
      }

      if (awaitingOperand) {
        display = '0.';
        awaitingOperand = false;
        return;
      }

      if (!display.contains('.')) {
        display += '.';
      }
    });
  }

  void chooseOperator(String operator) {
    setState(() {
      final double current = double.parse(display);

      if (awaitingOperand) {
        pendingOperator = operator;
        return;
      }

      if (accumulator != null && pendingOperator != null) {
        accumulator = calculate(
          accumulator!,
          current,
          pendingOperator!,
        );
      } else {
        accumulator = current;
      }

      display = formatNumber(accumulator!);
      pendingOperator = operator;
      awaitingOperand = true;
      resultShown = false;
    });
  }

  void pressEquals() {
    if (awaitingOperand ||
        accumulator == null ||
        pendingOperator == null) {
      return;
    }

    setState(() {
      final double current = double.parse(display);

      final double result = calculate(
        accumulator!,
        current,
        pendingOperator!,
      );

      display = formatNumber(result);
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      resultShown = true;
    });
  }

  void clearCalculator() {
    setState(() {
      display = '0';
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      resultShown = false;
    });
  }

  void onButtonPressed(String value) {
    if (RegExp(r'^[0-9]$').hasMatch(value)) {
      enterDigit(value);
      return;
    }

    if (['+', '−', '×', '÷'].contains(value)) {
      chooseOperator(value);
      return;
    }

    switch (value) {
      case '.':
        enterDecimal();
        break;
      case '=':
        pressEquals();
        break;
      case 'AC':
        clearCalculator();
        break;
    }
  }

  Widget buildButton(String value) {
    final bool isOperator =
        ['÷', '×', '−', '+', '='].contains(value);

    final bool isSpecial =
        ['AC', 'DEL', '√', '±', '%'].contains(value);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => onButtonPressed(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOperator
              ? Colors.deepPurple
              : isSpecial
                  ? Colors.deepPurple.shade100
                  : Colors.white,
          foregroundColor: isOperator
              ? Colors.white
              : Colors.black87,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator State Lab'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    display,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                ),
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  return buildButton(buttons[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
