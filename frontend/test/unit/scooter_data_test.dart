import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/models/scooter.dart';

void main() {
  group('ScooterInfo Model Tests', () {
    test('ScooterInfo.fromMap creates correct instance', () {
      // Arrange
      final Map<String, dynamic> testMap = {
        'id': 'test-id',
        'name': 'Test Scooter',
        'distance': 1.5,
        'location': 'foo location',
        'rating': 4.2,
        'price': 15.5,
      };

      // Act
      final scooterInfo = ScooterInfo.fromMap(testMap);

      // Assert
      expect(scooterInfo.id, equals('test-id'));
      expect(scooterInfo.name, equals('Test Scooter'));
      expect(scooterInfo.distance, equals(1.5));
      expect(scooterInfo.location, equals('foo location'));
      expect(scooterInfo.rating, equals(4.2));
      expect(scooterInfo.price, equals(15.5));
    });

    test('ScooterInfo.toMap returns correct map', () {
      // Arrange
      final scooterInfo = ScooterInfo(
        id: 'test-id',
        name: 'Test Scooter',
        distance: 1.5,
        location: 'foo location',
        rating: 4.2,
        price: 15.5,
      );

      // Act
      final resultMap = scooterInfo.toMap();

      // Assert
      expect(resultMap['id'], equals('test-id'));
      expect(resultMap['name'], equals('Test Scooter'));
      expect(resultMap['distance'], equals(1.5));
      expect(resultMap['location'], equals('foo location'));
      expect(resultMap['rating'], equals(4.2));
      expect(resultMap['price'], equals(15.5));
    });
  });

  group('ScooterData Tests', () {
    test('getScooters returns non-empty list', () {
      // Act
      final scooters = ScooterData.getScooters();

      // Assert
      expect(scooters, isNotEmpty);
      expect(scooters, isA<List<ScooterInfo>>());
    });

    test('getScooters returns valid ScooterInfo objects', () {
      // Act
      final scooters = ScooterData.getScooters();

      // Assert
      for (var scooter in scooters) {
        expect(scooter.id, isNotEmpty);
        expect(scooter.name, isNotEmpty);
        expect(scooter.distance, isA<double>());
        expect(scooter.location, isNotEmpty);
        expect(scooter.rating, isA<double>());
        expect(scooter.price, isA<double>());
      }
    });
  });
}
