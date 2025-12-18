import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_aplikasi/main.dart';
import 'package:laundry_aplikasi/screens/login_screen.dart';

void main() {
  testWidgets('Fixing missing startPage test', (WidgetTester tester) async {
    // Memberikan parameter startPage agar tidak error
    await tester.pumpWidget(const LaundryApp(startPage: LoginPage()));
  });
}