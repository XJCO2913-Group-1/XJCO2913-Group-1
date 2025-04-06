import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/auth_button.dart';
import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/info_button.dart';
import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/privilege_button.dart';
import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/settings_button.dart';
import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 1,
        child: Container(
          constraints: BoxConstraints.expand(),
          child: PrivilegeButton(),
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(
          constraints: BoxConstraints.expand(),
          child: InfoButton(),
        ),
      ),
      Expanded(
          flex: 2,
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                      constraints: BoxConstraints.expand(),
                      child: AuthButton()),
                ),
                Expanded(
                  child: Container(
                      constraints: BoxConstraints.expand(),
                      child: SettingsButton()),
                ),
              ],
            ),
          ))
    ]);
  }
}
