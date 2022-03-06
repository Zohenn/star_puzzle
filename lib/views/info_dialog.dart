import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

const _licenseText = '''
Night sky screenshots taken from Stellarium, licensed under GNU GPL.
https://stellarium.org

Background image for this dialog by Laney Smith.
https://unsplash.com/photos/FwNUSwJDZIQ
https://unsplash.com/@laney1smith

Star path was modified from svg provided by SVG Repo, licensed under CC0 license.
https://www.svgrepo.com/svg/27048/star

Josefin Slab, Poppins and Raleway fonts are present within the app, all licensed under OFL license.
''';

class InfoDialog extends StatelessWidget {
  const InfoDialog({Key? key}) : super(key: key);

  void _openResetConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset progress?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.find<BaseService>().resetProgress();
              Get.back();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Image.asset('assets/night_sky.jpg', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stazzle',
                  style: GoogleFonts.josefinSlab(
                    textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(color: cornsilk),
                  ),
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: _openResetConfirmationDialog,
                  child: const Text('Reset progress'),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'CREDITS',
                  style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12.0),
                const SelectableText(_licenseText),
                const SizedBox(height: 24.0),
                const Text('Special thanks to my wonderful girlfriend.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
