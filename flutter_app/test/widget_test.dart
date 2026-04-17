import 'package:flutter_test/flutter_test.dart';

import 'package:gym_trainer_app/app.dart';

void main() {
  testWidgets('arranca la app', (WidgetTester tester) async {
    await tester.pumpWidget(const GymTrainerApp());

    expect(find.text('Gym Trainer Prototype'), findsOneWidget);
    expect(find.text('Pantalla inicial conectada al backend real'),
        findsOneWidget);
  });
}
