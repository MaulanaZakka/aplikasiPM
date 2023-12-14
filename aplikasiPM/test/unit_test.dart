import 'package:flutter_test/flutter_test.dart';
import 'package:praktikummodul1/main.dart';

void main() {
  group('fetchMessages', () {
    test('returns Message if the http call completes successfully', () async {
      final messagesController = MessagesController();

      await messagesController.fetchMessages();
      expect(messagesController.messages.value.content, isNotEmpty);
    });

    test('throws an exception if the http call completes with an error', () async {
      final messagesController = MessagesController();

      expect(() async => await messagesController.fetchMessages(), throwsException);
    });
  });
}
