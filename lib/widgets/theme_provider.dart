import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final cornsilk = Color(0xfffff8dc);
final _backgroundColor = Color(0xff081229);

final _textTheme = GoogleFonts.ralewayTextTheme(Typography.material2018().white.apply(bodyColor: cornsilk));

class ThemeProvider extends StatelessWidget {
  const ThemeProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        backgroundColor: _backgroundColor,
        applyElevationOverlayColor: true,
        textTheme: _textTheme,
        // textTheme: Typography.material2018().white,
        cardTheme: CardTheme(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          clipBehavior: Clip.hardEdge,
        ),
        buttonTheme: ButtonThemeData(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          buttonColor: cornsilk,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(cornsilk),
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return cornsilk.withOpacity(0.04);
              }
              if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) {
                return cornsilk.withOpacity(0.12);
              }
              return null;
            }),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: _backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      ),
      child: child,
    );
  }
}
