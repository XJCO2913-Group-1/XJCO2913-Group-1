import 'package:easy_scooter/pages/profile_page/components/profile_menu/buttons/function_button.dart';
import 'package:easy_scooter/pages/welcome_page.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, value, child) => value.isLoggedIn
            ? FunctionButton(
                text: 'log out',
                color: const Color.fromARGB(255, 156, 226, 217),
                fontColor: const Color.fromARGB(255, 3, 71, 65),
                func: () {
                  value.logout();
                },
              )
            : FunctionButton(
                text: 'sign in',
                color: const Color.fromARGB(255, 156, 226, 217),
                fontColor: const Color.fromARGB(255, 3, 71, 65),
                func: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                  );
                }));
  }
}
