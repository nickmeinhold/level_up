import 'package:flutter_test/flutter_test.dart';
import 'package:level_up_shared/level_up_shared.dart';

void main() {
  group('ChatMessage.fromJsonWithId', () {
    test('creates TextChatMessage from valid JSON', () {
      final msg = ChatMessage.fromJsonWithId('m-1', {
        'type': 'text',
        'authorId': 'user-1',
        'read': false,
        'message': 'Hello coach!',
      });

      expect(msg, isA<TextChatMessage>());
      final text = msg as TextChatMessage;
      expect(text.id, 'm-1');
      expect(text.authorId, 'user-1');
      expect(text.read, isFalse);
      expect(text.message, 'Hello coach!');
    });

    test('creates VideoChatMessage from valid JSON', () {
      final msg = ChatMessage.fromJsonWithId('m-2', {
        'type': 'video',
        'authorId': 'user-2',
        'read': true,
        'videoUrl': 'https://storage.example.com/video.mp4',
      });

      expect(msg, isA<VideoChatMessage>());
      final video = msg as VideoChatMessage;
      expect(video.id, 'm-2');
      expect(video.authorId, 'user-2');
      expect(video.read, isTrue);
      expect(video.videoUrl, 'https://storage.example.com/video.mp4');
    });

    test('throws on unknown type', () {
      expect(
        () => ChatMessage.fromJsonWithId('m-3', {
          'type': 'image',
          'authorId': 'user-3',
          'read': false,
          'videoUrl': 'https://example.com/fallback.mp4',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when type is missing', () {
      expect(
        () => ChatMessage.fromJsonWithId('m-4', {
          'authorId': 'user-4',
          'read': false,
          'videoUrl': 'https://example.com/fallback.mp4',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when required text fields are missing', () {
      expect(
        () => ChatMessage.fromJsonWithId('m-5', {
          'type': 'text',
          'authorId': 'user-5',
          'read': false,
          // 'message' is missing
        }),
        throwsA(anything),
      );
    });

    test('throws when required video fields are missing', () {
      expect(
        () => ChatMessage.fromJsonWithId('m-6', {
          'type': 'video',
          'authorId': 'user-6',
          'read': false,
          // 'videoUrl' is missing
        }),
        throwsA(anything),
      );
    });

    test('throws when authorId is missing', () {
      expect(
        () => ChatMessage.fromJsonWithId('m-7', {
          'type': 'text',
          'read': false,
          'message': 'Hello',
        }),
        throwsA(anything),
      );
    });

    test('throws when read is missing', () {
      expect(
        () => ChatMessage.fromJsonWithId('m-8', {
          'type': 'text',
          'authorId': 'user-8',
          'message': 'Hello',
        }),
        throwsA(anything),
      );
    });
  });
}
