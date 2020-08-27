import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static Color customShadowColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark)
      return Colors.grey[100].withOpacity(0.05); // TODO: Adapt to Raspi-Display
    return Colors.grey[500].withOpacity(0.22);
  }
  static double get customElevation => 12.0;
  static double get customBorderRadius => 16.0;
  static double get iconButtonSize => 34;

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColorBrightness: Brightness.light,
        primaryColor: Color(0xFF428DFC),
        accentColor: Colors.blueAccent[700],
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[200],
        canvasColor: Colors.grey[300],
        cursorColor: Color(0xFF428DFC),
        hoverColor: Colors.grey[100],
        fontFamily: 'Rubik',
        iconTheme: IconThemeData(color: Colors.grey[800], size: 32),
        toggleableActiveColor: Color(0xFF428DFC),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 90,
            fontWeight: FontWeight.w400,
            color: Colors.grey[900],
          ),
          headline2: TextStyle(
            fontSize: 62,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          headline3: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          headline4: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          headline5: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          headline6: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          subtitle1: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          subtitle2: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          bodyText1: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
          bodyText2: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
          caption: TextStyle(
            fontSize: 16,
          ),
          button: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: Colors.grey[800],
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColorBrightness: Brightness.dark,
        primaryColor: Colors.blueAccent[100],
        accentColor: Colors.blueAccent[100],
        backgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.grey[800],
        cursorColor: Colors.blueAccent[100],
        hoverColor: Colors.grey[700],
        fontFamily: 'Rubik',
        iconTheme: IconThemeData(color: Colors.grey[300], size: 32),
        toggleableActiveColor: Colors.blueAccent[100],
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 90,
            fontWeight: FontWeight.w400,
            color: Colors.grey[50],
          ),
          headline2: TextStyle(
            fontSize: 62,
            fontWeight: FontWeight.w500,
            color: Colors.grey[50],
          ),
          headline3: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w500,
            color: Colors.grey[50],
          ),
          headline4: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            color: Colors.grey[50],
          ),
          headline5: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.grey[50],
          ),
          headline6: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.grey[50],
          ),
          subtitle1: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
          subtitle2: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
          bodyText1: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.grey[300],
          ),
          bodyText2: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[300],
          ),
          caption: TextStyle(
            fontSize: 16,
          ),
          button: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      );
}
