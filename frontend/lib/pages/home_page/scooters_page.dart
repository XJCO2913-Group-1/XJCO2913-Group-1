import 'package:easy_scooter/components/main_navigation.dart';
import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/components/scooter_card.dart';
import 'package:easy_scooter/pages/home_page/components/tag_button_group.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScootersPage extends StatefulWidget {
  const ScootersPage({super.key});
  @override
  State<ScootersPage> createState() => _ScootersPageState();
}

class _ScootersPageState extends State<ScootersPage> {
  // 滑板车数据列表

  @override
  void initState() {
    super.initState();
    // 异步获取滑板车数据
    // 使用Provider获取滑板车数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScootersProvider>(context, listen: false).fetchScooters();
    });
  }

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
      body: SafeArea(child: Consumer<ScootersProvider>(
          builder: (context, scootersProvider, child) {
        if (scootersProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 28, 49, 44),
            ),
          );
        } else if (scootersProvider.error != null) {
          return Center(
            child: Text(
              '加载失败: ${scootersProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (scootersProvider.scooters.isEmpty) {
          return const Center(
            child: Text(
              '没有可用的滑板车数据',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScooterCard(
                id: scootersProvider.scooters[0].id,
                name: scootersProvider.scooters[0].name,
                status: scootersProvider.scooters[0].status,
                distance: scootersProvider.scooters[0].distance,
                location: scootersProvider.scooters[0].location,
                rating: scootersProvider.scooters[0].rating,
                price: scootersProvider.scooters[0].price,
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
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TagButtonGroup(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: scootersProvider.scooters.length,
                          itemBuilder: (context, index) {
                            return ScooterCard(
                              id: scootersProvider.scooters[index].id,
                              name: scootersProvider.scooters[index].name,
                              status: scootersProvider.scooters[index].status,
                              distance:
                                  scootersProvider.scooters[index].distance,
                              location:
                                  scootersProvider.scooters[index].location,
                              rating: scootersProvider.scooters[index].rating,
                              price: scootersProvider.scooters[index].price,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }
      })),
    );
  }
}
// _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _scooterData.isEmpty
//                 ? const Center(child: Text('No scooter data available.'))
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       ScooterCard(
//                         id: _scooterData[0].id,
//                         name: _scooterData[0].name,
//                         status: _scooterData[0].status,
//                         distance: _scooterData[0].distance,
//                         location: _scooterData[0].location,
//                         rating: _scooterData[0].rating,
//                         price: _scooterData[0].price,
//                       ),
//                       Expanded(
//                         child: Container(
//                           margin: EdgeInsets.symmetric(
//                             horizontal: 8,
//                           ),
//                           padding: EdgeInsets.only(
//                             top: 10,
//                             left: 2,
//                             right: 2,
//                             bottom: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color.fromARGB(255, 148, 192, 97), //
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Column(
//                             children: [
//                               TagButtonGroup(),
//                               Expanded(
//                                 child: ListView.builder(
//                                   itemCount: _scooterData.length,
//                                   itemBuilder: (context, index) {
//                                     return ScooterCard(
//                                       id: _scooterData[index].id,
//                                       name: _scooterData[index].name,
//                                       status: _scooterData[index].status,
//                                       distance: _scooterData[index].distance,
//                                       location: _scooterData[index].location,
//                                       rating: _scooterData[index].rating,
//                                       price: _scooterData[index].price,
//                                     );
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
