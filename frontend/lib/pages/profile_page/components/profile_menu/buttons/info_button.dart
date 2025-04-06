import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'info',
      color: const Color.fromARGB(255, 250, 238, 171),
      fontColor: const Color.fromARGB(255, 3, 71, 65),
      func: () {},
    );
  }
}
