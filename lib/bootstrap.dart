import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/main.dart';
import 'package:star_puzzle/layout/main_layout.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/widgets/star_loader.dart';

class Bootstrap extends StatefulWidget {
  const Bootstrap({Key? key}) : super(key: key);

  @override
  _BootstrapState createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  final Future<void>? _initFuture = Get.put(BaseService()).initFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            throw snapshot.error!;
          });
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          // addPostFrameCallback is needed here, so it doesn't throw an error about using setState in build method
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            navigator!.pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
          });
          return Container(
            color: Theme.of(context).backgroundColor,
          );
        }

        return Container(
          color: Theme.of(context).backgroundColor,
          child: const Center(
            child: StarLoader(),
          ),
        );
      },
    );
  }
}
