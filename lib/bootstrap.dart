import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/views/main_layout.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/widgets/star_loader.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

class Bootstrap extends StatefulWidget {
  const Bootstrap({Key? key}) : super(key: key);

  @override
  _BootstrapState createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  final Future<void>? _initFuture = Get.put(BaseService()).initFuture;
  bool redirected = false;

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
            if (!redirected) {
              navigator!.pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
              redirected = true;
            }
          });
          return Container(
            color: Theme.of(context).backgroundColor,
          );
        }

        return Container(
          color: Theme.of(context).backgroundColor,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stazzle',
                  style: GoogleFonts.josefinSlab(
                    textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(color: cornsilk),
                  ),
                ),
                const SizedBox(height: 36.0),
                const StarLoader(),
              ],
            ),
          ),
        );
      },
    );
  }
}
