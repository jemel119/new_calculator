
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

class CalculationRecord {
  final String expression;
  final String result;

  const CalculationRecord({
    required this.expression,
    required this.result,
  });
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '0';

  double? accumulator;
  String? pendingOperator;

  bool awaitingOperand = false;
  bool resultShown = false;

  String expression = '';

  final List<CalculationRecord> history = [];

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
        expression = '';
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
        expression = '';
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
        expression = expression.replaceFirst(
          RegExp(r'[+−×÷]\s*$'),
          '$operator ',
        );
        return;
      }

      if (accumulator != null && pendingOperator != null) {
        expression += '$display ';
        accumulator = calculate(
          accumulator!,
          current,
          pendingOperator!,
        );
      } else {
        expression = '$display ';
        accumulator = current;
      }

      display = formatNumber(accumulator!);
      expression += '$operator ';
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

      final String completedExpression =
          '$expression$display';

      final String formattedResult = formatNumber(result);

      history.insert(
        0,
        CalculationRecord(
          expression: completedExpression,
          result: formattedResult,
        ),
      );

      display = formattedResult;
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      resultShown = true;
      expression = '';
    });
  }

  void clearCalculator() {
    setState(() {
      display = '0';
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      resultShown = false;
      expression = '';
    });
  }

  void reuseHistoryResult(String result) {
    setState(() {
      display = result;
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      resultShown = true;
      expression = '';
    });

    Navigator.of(context).pop();
  }

  void clearHistory() {
    setState(() {
      history.clear();
    });
  }

  void showHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, updateSheet) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.65,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Calculation History',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: history.isEmpty
                                ? null
                                : () {
                                    clearHistory();
                                    updateSheet(() {});
                                  },
                            child: const Text('Clear History'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: history.isEmpty
                          ? const Center(
                              child: Text(
                                'No calculations yet.',
                              ),
                            )
                          : ListView.separated(
                              itemCount: history.length,
                              separatorBuilder: (context, index) {
                                return const Divider(height: 1);
                              },
                              itemBuilder: (context, index) {
                                final record = history[index];

                                return ListTile(
                                  title: Text(record.expression),
                                  subtitle: Text(
                                    '= ${record.result}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.north_west,
                                  ),
                                  onTap: () {
                                    reuseHistoryResult(record.result);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        actions: [
          IconButton(
            onPressed: showHistory,
            tooltip: 'Calculation history',
            icon: const Icon(Icons.history),
          ),
        ],
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
