
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  Future<void> startCalculator(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();
  }

  Future<void> pressButton(
    WidgetTester tester,
    String label,
  ) async {
    final button = find.widgetWithText(
      ElevatedButton,
      label,
      skipOffstage: false,
    );

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
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

  void checkDisplay(String expected) {
    expect(find.text(expected), findsWidgets);
  }

  group('Calculator State Lab', () {
    testWidgets('Displays zero initially', (tester) async {
      await startCalculator(tester);

      checkDisplay('0');
    });

    testWidgets('Adds two numbers', (tester) async {
      await startCalculator(tester);

      await enterSequence(tester, ['2', '+', '3', '=']);

      checkDisplay('5');
    });

    testWidgets('Evaluates left to right', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['2', '+', '3', '×', '4', '='],
      );

      checkDisplay('20');
    });

    testWidgets('Replaces consecutive operators', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['9', '+', '×', '2', '='],
      );

      checkDisplay('18');
    });

    testWidgets('Supports decimal calculations', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['1', '.', '5', '+', '2', '.', '5', '='],
      );

      checkDisplay('4');
    });

    testWidgets('Prevents duplicate decimals', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['1', '.', '.', '5'],
      );

      checkDisplay('1.5');
    });

    testWidgets('Calculates percentages', (tester) async {
      await startCalculator(tester);

      await enterSequence(tester, ['5', '0', '%']);

      checkDisplay('0.5');
    });

    testWidgets('Calculates square roots', (tester) async {
      await startCalculator(tester);

      await enterSequence(tester, ['9', '√']);

      checkDisplay('3');
    });

    testWidgets('Toggles number signs', (tester) async {
      await startCalculator(tester);

      await enterSequence(tester, ['5', '±']);

      checkDisplay('-5');
    });

    testWidgets('Deletes the last digit', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['1', '2', '3', 'DEL'],
      );

      checkDisplay('12');
    });

    testWidgets('Clears the calculator', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['8', '+', '2', 'AC'],
      );

      checkDisplay('0');
    });

    testWidgets('Shows division by zero error', (tester) async {
      await startCalculator(tester);

      await enterSequence(
        tester,
        ['9', '÷', '0', '='],
      );

      checkDisplay('Error');
    });

    testWidgets('Saves calculation history', (tester) async {
      await startCalculator(tester);

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
      await startCalculator(tester);

      await enterSequence(tester, ['9', '√']);

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('√(9)'), findsOneWidget);
      expect(find.text('= 3'), findsOneWidget);
    });
  });
}
