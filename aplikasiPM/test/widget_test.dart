import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:praktikummodul1/main.dart';

void main() {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Test ThirdPage Widget', (WidgetTester tester) async {
    // Sediakan ImageController
    Get.put(ImageController);

    // Bangun aplikasi kita dan picu frame.
    await tester.pumpWidget(MaterialApp(
      home: ThirdPage(),
    ));

    // Verifikasi bahwa halaman memiliki widget yang benar
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Obx), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(3));
    expect(find.byType(Icon), findsNWidgets(3));
    expect(find.text('No image selected.'), findsOneWidget);

    // Ketuk FloatingActionButton dengan ikon kamera.
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.camera));
    await tester.pump();

    // Ketuk FloatingActionButton dengan ikon pustaka foto.
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.photo_library));
    await tester.pump();

    // Ketuk FloatingActionButton dengan ikon hapus.
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.delete));
    await tester.pump();
  });
}
