import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

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
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.all(10), // 内边距为2,
              child: Column(
                children: [
                  Expanded(flex: 1, child: UserInfo()),
                  Expanded(flex: 2, child: ButtonGroup()),
                  Expanded(flex: 3, child: CardsGroup()),
                ],
              ),
            )),
      ],
    );
  }
}

class PostersCarousel extends StatefulWidget {
  const PostersCarousel({
    super.key,
  });

  @override
  State<PostersCarousel> createState() => _PostersCarouselState();
}

class _PostersCarouselState extends State<PostersCarousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                height: double.infinity,
                aspectRatio: 16 / 9,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: imgList
                  .map((item) => Container(
                        width: MediaQuery.of(context).size.width - 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // 背景色设置为白色
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(item),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withAlpha(_current == entry.key ? 229 : 102),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class CardsGroup extends StatelessWidget {
  const CardsGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Cards',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
        CreditCardsView(),
      ],
    );
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Amirul Islam ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Yamaha R15',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class CreditCardsView extends StatelessWidget {
  const CreditCardsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          CreditCard(),
          CreditCard(),
          CreditCard(),
        ],
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  const CreditCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
          child: Text(
        '**** **** **** 1234',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }
}

class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 1,
        child: Container(
          constraints: BoxConstraints.expand(),
          child: FunctionButton(
            text: '特权认证',
            color: const Color.fromARGB(255, 175, 235, 107),
            fontColor: const Color.fromARGB(255, 3, 71, 65),
            func: () {},
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(
            constraints: BoxConstraints.expand(),
            child: FunctionButton(
              text: '完善\n个人\n信息',
              color: const Color.fromARGB(255, 250, 238, 171),
              fontColor: const Color.fromARGB(255, 3, 71, 65),
              func: () {},
            )),
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
                      child: FunctionButton(
                        text: '注册/登陆',
                        color: const Color.fromARGB(255, 156, 226, 217),
                        fontColor: const Color.fromARGB(255, 3, 71, 65),
                        func: () {},
                      )),
                ),
                Expanded(
                  child: Container(
                      constraints: BoxConstraints.expand(),
                      child: FunctionButton(
                        text: '设置',
                        color: const Color.fromARGB(255, 193, 201, 184),
                        fontColor: const Color.fromARGB(255, 3, 71, 65),
                        func: () {},
                      )),
                ),
              ],
            ),
          ))
    ]);
  }
}

class FunctionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color fontColor;
  final Function() func;

  const FunctionButton({
    super.key,
    required this.text,
    required this.color,
    required this.fontColor,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        onPressed: func,
        child: Text(text,
            style: TextStyle(
              color: fontColor,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
