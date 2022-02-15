import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/main.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/widgets/star_loader.dart';

final bool isProduction = bool.fromEnvironment('dart.vm.product');

class Bootstrap extends StatefulWidget {
  @override
  _BootstrapState createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  Future<void>? _initFuture = Get.put(BaseService()).bootstrapFuture;

  final backgroundColor = Color(0xff081229);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.square(key: Get.find<BaseService>().containerKey, dimension: 300),
                      SizedBox(height: 16),
                      TextButton(onPressed: (){}, child: Text('')),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 96 + 2 * 16),
          ],
        ),
        FutureBuilder(
          future: _initFuture,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              // addPostFrameCallback is needed here, so it doesn't throw an error about using setState in build method
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                Get.off(() => MyHomePage());
              });
              return Container(
                color: backgroundColor,
              );
            }

            return Container(
              color: backgroundColor,
              child: Center(
                child: StarLoader(),
              ),
            );
          },
        ),
      ],
    );
  }
}
