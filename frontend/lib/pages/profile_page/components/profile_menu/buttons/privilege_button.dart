import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:easy_scooter/pages/profile_page/privilege_page/page.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class PrivilegeButton extends StatelessWidget {
  const PrivilegeButton({
    super.key,
  });
  bool checkVip() {
    int age = UserProvider().user?.age ?? 0;
    bool hasSchool = UserProvider().user?.school != null;
    return age > 60 || hasSchool;
  }

  @override
  Widget build(BuildContext context) {
    return FunctionButton(
      text: 'Privilege ${checkVip() ? 'VIP' : 'Normal'}',
      color: Colors.grey,
      fontColor: checkVip()
          ? const Color.fromARGB(255, 255, 196, 0)
          : primaryColor, // Gold color for VIP
      func: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivilegePage()),
        );
      },
    );
  }
}
