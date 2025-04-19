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
  String currentModel = 'All'; // 添加当前型号状态变量

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScootersProvider>(context, listen: false).fetchScooters();
    });
  }

  // 处理型号更改
  void _onModelChanged(String model) {
    setState(() {
      currentModel = model;
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
      body: SafeArea(
        child: Consumer<ScootersProvider>(
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
                    model: scootersProvider.scooters[0].model,
                    status: scootersProvider.scooters[0].status,
                    distance: scootersProvider.scooters[0].distance,
                    location: scootersProvider.scooters[0].location,
                    rating: scootersProvider.scooters[0].rating,
                    price: scootersProvider.scooters[0].price!,
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
                          TagButtonGroup(
                            currentModel: currentModel,
                            onModelChanged: _onModelChanged,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: scootersProvider.scooters.length,
                              itemBuilder: (context, index) {
                                if (currentModel != 'All' &&
                                    scootersProvider.scooters[index].model !=
                                        currentModel) {
                                  return const SizedBox.shrink();
                                }
                                return ScooterCard(
                                  id: scootersProvider.scooters[index].id,
                                  model: scootersProvider.scooters[index].model,
                                  status:
                                      scootersProvider.scooters[index].status,
                                  distance:
                                      scootersProvider.scooters[index].distance,
                                  location:
                                      scootersProvider.scooters[index].location,
                                  rating:
                                      scootersProvider.scooters[index].rating,
                                  price:
                                      scootersProvider.scooters[index].price!,
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
          },
        ),
      ),
    );
  }
}
