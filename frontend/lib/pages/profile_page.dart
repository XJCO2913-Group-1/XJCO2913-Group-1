import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> carouselImages = [
    'https://via.placeholder.com/800x400/FF5733/FFFFFF?text=Electric+Bike+1',
    'https://via.placeholder.com/800x400/33FF57/FFFFFF?text=Electric+Bike+2',
    'https://via.placeholder.com/800x400/5733FF/FFFFFF?text=Electric+Bike+3',
  ];

  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 轮播图部分 - 使用SliverAppBar实现滑动效果
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height / 3,
            pinned: false,
            floating: false,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCarousel(),
            ),
          ),
          // 个人信息卡片部分
          SliverList(
            delegate: SliverChildListDelegate([
              _buildProfileCard(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: [
        // 轮播图
        PageView.builder(
          itemCount: carouselImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentCarouselIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              carouselImages[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, size: 50),
                  ),
                );
              },
            );
          },
        ),
        // 轮播图指示器
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselImages.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户基本信息部分
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 用户头像
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'john.doe@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4.0),
                            const Text(
                              'Premium Member',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 编辑按钮
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // 编辑个人资料的逻辑
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // 账户信息部分
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildInfoItem(Icons.credit_card, 'Payment Methods', '2 cards added'),
          _buildInfoItem(Icons.location_on, 'Addresses', '3 addresses saved'),
          _buildInfoItem(Icons.history, 'Ride History', '12 rides this month'),
          _buildInfoItem(Icons.electric_bike, 'My Vehicles', '1 active rental'),

          const SizedBox(height: 16.0),

          // 设置部分
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildInfoItem(Icons.notifications, 'Notifications', 'On'),
          _buildInfoItem(Icons.language, 'Language', 'English'),
          _buildInfoItem(Icons.dark_mode, 'Dark Mode', 'Off'),
          _buildInfoItem(Icons.help, 'Help & Support', ''),
          _buildInfoItem(Icons.logout, 'Logout', '', isLogout: true),

          // 底部空间，确保滚动时有足够空间
          const SizedBox(height: 100.0),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle,
      {bool isLogout = false}) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : null,
            fontWeight: isLogout ? FontWeight.bold : null,
          ),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 处理点击事件的逻辑
        },
      ),
    );
  }
}
