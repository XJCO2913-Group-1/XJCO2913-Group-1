import 'package:easy_scooter/components/main_navigation.dart';
import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/components/scooter_card.dart';
import 'package:easy_scooter/pages/home_page/components/tag_button_group.dart';
import 'package:flutter/material.dart';

class ScootersPage extends StatefulWidget {
  const ScootersPage({super.key});
  @override
  State<ScootersPage> createState() => _ScootersPageState();
}

class _ScootersPageState extends State<ScootersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const PageTitle(title: 'Available Scooters'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
              );
            },
          ),
        ),
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              ScooterCard(
                id: 'EB-2023-0001',
                name: 'City Scooter',
                distance: 0.5,
                location: '北京市海淀区中关村大街1号',
                rating: 4.5,
                price: 15.0,
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                padding: EdgeInsets.only(
                  top: 10,
                  left: 2,
                  right: 2,
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 148, 192, 97), //
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TagButtonGroup(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ScooterCard(
                            id: 'EB-2023-0001',
                            name: 'City Scooter',
                            distance: 0.5,
                            location: '北京市海淀区中关村大街1号',
                            rating: 4.5,
                            price: 15.0,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ))
            ])));
  }
}
