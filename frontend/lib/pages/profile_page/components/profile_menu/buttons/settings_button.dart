import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:easy_scooter/providers/rentals_provider.dart';
import 'package:easy_scooter/services/scooter_service.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'Set Up',
      color: Colors.grey,
      fontColor: primaryColor,
      func: () async {
        await ScooterService().updateScooters();
        for (var rental in RentalsProvider().rentals) {
          await RentalsProvider().deleteRental(rental.id);
        }
      },
    );
  }
}
