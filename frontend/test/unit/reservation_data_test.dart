import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/models/rental.dart';

void main() {
  group('ReservationData Tests', () {
    test('getReservations returns non-empty list', () {
      // Act
      final reservations = ReservationData.getReservations();

      // Assert
      expect(reservations, isNotEmpty);
      expect(reservations, isA<List<Map<String, dynamic>>>());
    });

    test('getReservations returns valid reservation objects', () {
      // Act
      final reservations = ReservationData.getReservations();

      // Assert
      for (var reservation in reservations) {
        expect(reservation['orderId'], isNotEmpty);
        expect(reservation['vehicleModel'], isNotEmpty);
        expect(reservation['vehicleId'], isNotEmpty);
        expect(reservation['reservationTime'], isA<DateTime>());
        expect(reservation['startTime'], isA<DateTime>());
        expect(reservation['status'], isNotEmpty);
        expect(reservation['location'], isNotEmpty);
      }
    });

    test('getReservations returns correctly formatted data', () {
      // Act
      final reservations = ReservationData.getReservations();

      // Assert
      for (var reservation in reservations) {
        // Check orderId format (e.g., ORD followed by numbers)
        expect(reservation['orderId'], matches(r'^ORD[0-9]+$'));

        // Check vehicleId format
        expect(
            reservation['vehicleId'],
            anyOf(matches(r'^SC-[0-9]+-[0-9]+$'),
                matches(r'^EB-[0-9]+-[0-9]+$')));

        // Check that startTime is after reservationTime
        expect(
            (reservation['startTime'] as DateTime)
                .isAfter(reservation['reservationTime'] as DateTime),
            isTrue);
      }
    });
  });
}
