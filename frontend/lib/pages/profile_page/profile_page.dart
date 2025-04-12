import 'package:easy_scooter/pages/profile_page/components/cards_group.dart';

import 'package:easy_scooter/pages/profile_page/components/poster_carousel.dart';
import 'package:easy_scooter/pages/profile_page/components/profile_menu/profile_menu.dart';
import 'package:easy_scooter/pages/profile_page/components/user_info_bar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 1, child: PostersCarousel()),
        Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 7, 82, 74),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(10), // 内边距为2,
              child: Column(
                children: [
                  Expanded(flex: 1, child: UserInfoBar()),
                  Expanded(flex: 2, child: ProfileMenu()),
                  Expanded(flex: 3, child: CardsGroup()),
                ],
              ),
            )),
      ],
    );
  }
}
