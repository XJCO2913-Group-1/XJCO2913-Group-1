import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';

import 'package:easy_scooter/pages/profile_page/user_info_page.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'Improve Personal Info',
      color: Colors.grey,
      fontColor: primaryColor,
      func: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserInfoPage()),
        );
      },
    );
  }
}
