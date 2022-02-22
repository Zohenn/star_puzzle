import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:star_puzzle/models/constellation.dart';

final numberFormatter = NumberFormat('0.00');

class StarInfo extends StatelessWidget {
  const StarInfo({
    Key? key,
    required this.star,
  }) : super(key: key);

  final Star? star;

  String get name => star?.name ?? '';

  String get magnitude => star?.magnitude != null ? numberFormatter.format(star!.magnitude) : '';

  String get distance => star?.distance != null ? numberFormatter.format(star!.distance) : '';

  @override
  Widget build(BuildContext context) {
    const spacerBox = SizedBox(height: 16.0);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Opacity(
          opacity: star == null ? 1 : 0,
          child: Text(
            'Click on a star to see its info',
            style: TextStyle(color: Theme.of(context).textTheme.caption!.color),
          ),
        ),
        Opacity(
          opacity: star == null ? 0 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              spacerBox,
              Text('MAGNITUDE', style: Theme.of(context).textTheme.caption),
              Text(magnitude, style: GoogleFonts.poppins()),
              spacerBox,
              Text('DISTANCE', style: Theme.of(context).textTheme.caption),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: distance, style: GoogleFonts.poppins()),
                    TextSpan(text: ' ly'),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
