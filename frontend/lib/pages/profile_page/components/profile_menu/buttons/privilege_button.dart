import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:flutter/material.dart';

class PrivilegeButton extends StatelessWidget {
  const PrivilegeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'privilege',
      color: const Color.fromARGB(255, 175, 235, 107),
      fontColor: const Color.fromARGB(255, 3, 71, 65),
      func: () {},
    );
  }
}
