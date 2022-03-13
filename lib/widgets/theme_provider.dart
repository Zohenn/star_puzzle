import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const cornsilk = Color(0xfffff8dc);
const _backgroundColor = Color(0xff081229);
const _backgroundColorDark = Color(0xff071024);

final _textTheme = GoogleFonts.ralewayTextTheme(Typography.material2018().white.apply(bodyColor: cornsilk));

/// Putting theme in a separate file would be the best, but then its changes are not reflected on hot reload.
/// This widget solves that problem.
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
        scaffoldBackgroundColor: _backgroundColor,
        cardColor: _backgroundColor,
        applyElevationOverlayColor: true,
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          color: _backgroundColorDark
        ),
        listTileTheme: const ListTileThemeData(
          selectedColor: Colors.white,
        ),
        toggleableActiveColor: Colors.white,
        // textTheme: Typography.material2018().white,
        cardTheme: CardTheme(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          clipBehavior: Clip.hardEdge,
        ),
        buttonTheme: const ButtonThemeData(
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
