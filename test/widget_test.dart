import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkwise_pdf/main.dart'; // matches your pubspec.yaml

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const InkwisePDFApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
