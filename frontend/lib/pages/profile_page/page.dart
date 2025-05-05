import 'package:easy_scooter/pages/profile_page/components/payment_card/cards_group.dart';

import 'package:easy_scooter/pages/profile_page/components/poster_carousel.dart';
import 'package:easy_scooter/pages/profile_page/components/profile_menu/profile_menu.dart';
import 'package:easy_scooter/pages/profile_page/components/user_info_bar.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // 检测是否为桌面设备
    final bool isDesktop = Theme.of(context).platform == TargetPlatform.windows ||
                          Theme.of(context).platform == TargetPlatform.linux ||
                          Theme.of(context).platform == TargetPlatform.macOS;
    
    // 根据设备类型确定内容最大宽度
    final double maxWidth = isDesktop ? 600.0 : double.infinity;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 1, child: PostersCarousel()),
        Expanded(
          flex: 2,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(flex: 1, child: UserInfoBar()),
                    Expanded(flex: 2, child: ProfileMenu()),
                    Expanded(flex: 3, child: CardsGroup()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
