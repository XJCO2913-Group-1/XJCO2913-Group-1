import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'settings',
      color: const Color.fromARGB(255, 193, 201, 184),
      fontColor: const Color.fromARGB(255, 3, 71, 65),
      func: () {},
    );
  }
}
