import 'package:flutter_test/flutter_test.dart';
import 'package:level_up_shared/level_up_shared.dart';

void main() {
  group('User.fromJsonWithId', () {
    test('creates Client from valid JSON', () {
      final user = User.fromJsonWithId('user-1', {
        'type': 'client',
        'name': 'Jane Doe',
        'email': 'jane@example.com',
      });

      expect(user, isA<Client>());
      expect(user.id, 'user-1');
      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@example.com');
    });

    test('creates Coach from valid JSON', () {
      final user = User.fromJsonWithId('coach-1', {
        'type': 'coach',
        'name': 'Coach Smith',
        'email': 'smith@example.com',
      });

      expect(user, isA<Coach>());
      expect(user.id, 'coach-1');
      expect(user.name, 'Coach Smith');
      expect(user.email, 'smith@example.com');
    });

    test('throws on unknown type', () {
      expect(
        () => User.fromJsonWithId('x', {'type': 'admin', 'name': 'A'}),
        throwsException,
      );
    });

    test('throws when type is missing', () {
      expect(
        () => User.fromJsonWithId('x', {'name': 'A'}),
        throwsException,
      );
    });
  });

  group('Client.fromJsonWithId', () {
    test('handles missing name gracefully (defaults to empty string)', () {
      final client = Client.fromJsonWithId('c-1', {'email': 'a@b.com'});

      expect(client.name, isEmpty);
      // Regression: previously defaulted to the string 'null'
      expect(client.name, isNot(equals('null')));
    });

    test('handles null email', () {
      final client = Client.fromJsonWithId('c-1', {'name': 'Alice'});

      expect(client.name, 'Alice');
      expect(client.email, isNull);
    });
  });

  group('Coach.fromJsonWithId', () {
    test('handles missing name gracefully (defaults to empty string)', () {
      final coach = Coach.fromJsonWithId('co-1', {'email': 'a@b.com'});

      expect(coach.name, isEmpty);
      // Regression: previously defaulted to the string 'null'
      expect(coach.name, isNot(equals('null')));
    });

    test('handles null email', () {
      final coach = Coach.fromJsonWithId('co-1', {'name': 'Bob'});

      expect(coach.name, 'Bob');
      expect(coach.email, isNull);
    });
  });
}
