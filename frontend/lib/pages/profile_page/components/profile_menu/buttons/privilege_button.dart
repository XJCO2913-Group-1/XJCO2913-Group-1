import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:easy_scooter/pages/profile_page/privilege_page.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class PrivilegeButton extends StatelessWidget {
  const PrivilegeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'Privilege',
      color: Colors.grey,
      fontColor: primaryColor,
      func: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivilegePage()),
        );
      },
    );
  }
}
