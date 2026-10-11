
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  Future<void> pressButton(
    WidgetTester tester,
    String label,
  ) async {
    await tester.tap(find.widgetWithText(ElevatedButton, label));
    await tester.pumpAndSettle();
  }

  Future<void> enterSequence(
    WidgetTester tester,
    List<String> buttons,
  ) async {
    for (final button in buttons) {
      await pressButton(tester, button);
    }
  }

  Future<void> checkDisplay(
    WidgetTester tester,
    String expected,
  ) async {
    expect(find.text(expected), findsWidgets);
  }

  group('Calculator State Lab', () {
    testWidgets('Displays zero initially', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Adds two numbers', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(tester, ['2', '+', '3', '=']);

      await checkDisplay(tester, '5');
    });

    testWidgets('Evaluates left to right', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['2', '+', '3', '×', '4', '='],
      );

      await checkDisplay(tester, '20');
    });

    testWidgets('Replaces consecutive operators', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['9', '+', '×', '2', '='],
      );

      await checkDisplay(tester, '18');
    });

    testWidgets('Supports decimal calculations', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['1', '.', '5', '+', '2', '.', '5', '='],
      );

      await checkDisplay(tester, '4');
    });

    testWidgets('Prevents duplicate decimals', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['1', '.', '.', '5'],
      );

      await checkDisplay(tester, '1.5');
    });

    testWidgets('Calculates percentages', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(tester, ['5', '0', '%']);

      await checkDisplay(tester, '0.5');
    });

    testWidgets('Calculates square roots', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(tester, ['9', '√']);

      await checkDisplay(tester, '3');
    });

    testWidgets('Toggles number signs', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(tester, ['5', '±']);

      await checkDisplay(tester, '-5');
    });

    testWidgets('Deletes the last digit', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['1', '2', '3', 'DEL'],
      );

      await checkDisplay(tester, '12');
    });

    testWidgets('Clears the calculator', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['8', '+', '2', 'AC'],
      );

      await checkDisplay(tester, '0');
    });

    testWidgets('Shows division by zero error', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['9', '÷', '0', '='],
      );

      await checkDisplay(tester, 'Error');
    });

    testWidgets('Saves calculation history', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(
        tester,
        ['2', '+', '3', '='],
      );

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('2 + 3'), findsOneWidget);
      expect(find.text('= 5'), findsOneWidget);
    });

    testWidgets('Saves advanced operation history', (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await enterSequence(tester, ['9', '√']);

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('√(9)'), findsOneWidget);
      expect(find.text('= 3'), findsOneWidget);
    });
  });
}
