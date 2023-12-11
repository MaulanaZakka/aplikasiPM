import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:praktikummodul1/main.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('fetchMessages', () {
    test('returns a Message if the http call completes successfully', () async {
      final client = MockClient();

      // Buat instance dari MessagesController
      final controller = MessagesController();

      // Gunakan Mockito untuk berhasil mengembalikan respons HTTP 200 saat dipanggil
      when(client.get(Uri.parse('https://api.github.com/gists/a3977acb85a45e07d1af0a84e2f94855')))
          .thenAnswer((_) async => http.Response('{"content": "Test content"}', 200));

      // Panggil fetchMessages pada instance controller
      expect(await controller.fetchMessages(client), isA<Message>());
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockClient();

      // Buat instance dari MessagesController
      final controller = MessagesController();

      // Gunakan Mockito untuk mengembalikan respons HTTP 400 saat dipanggil
      when(client.get(Uri.parse('https://api.github.com/gists/a3977acb85a45e07d1af0a84e2f94855')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Panggil fetchMessages pada instance controller
      expect(controller.fetchMessages(client), throwsException);
    });
  });
}
