import 'package:flutter/material.dart';

/// Holds the [ThemeData] for the [lightTheme] and [darkTheme], and provides
/// some extra values for consistent design.
class AppTheme {
  /// Default color when using shadows. Flutter supports no default
  /// [shadowColor] so always use this when working with elevation.
  static Color shadowColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark)
      return Colors.grey[100]!.withOpacity(0.05);
    return Colors.grey[500]!.withOpacity(0.22);
  }

  static double get elevation => 12.0;
  static double get borderRadius => 16.0;
  static double get iconButtonSize => 34;
  static double get dialogSize => 0.6;

  static ThemeData get lightTheme => ThemeData(
        accentColor: Colors.blueAccent[700],
        applyElevationOverlayColor: true,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.blueAccent[700]),
            padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
        buttonBarTheme: ButtonBarThemeData(
          buttonPadding: EdgeInsets.all(16.0),
          buttonTextTheme: ButtonTextTheme.accent,
        ),
        canvasColor: Colors.grey[300],
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.black26,
          elevation: 12.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          elevation: 12.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        disabledColor: Colors.black38,
        dividerTheme: DividerThemeData(color: Colors.grey[300]),
        errorColor: Colors.red[700],
        hintColor: Colors.grey[600],
        iconTheme: IconThemeData(color: Colors.grey[800], size: 32),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          disabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        primaryColor: Colors.blueAccent[700],
        scaffoldBackgroundColor: Colors.grey[200],
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.blueAccent[700],
          thumbColor: Colors.blueAccent[700],
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          elevation: 12.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        fontFamily: 'Rubik',
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
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blueAccent[700],
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        accentColor: Colors.blueAccent[100],
        applyElevationOverlayColor: true,
        backgroundColor: Colors.grey[900],
        brightness: Brightness.dark,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.blueAccent[100]),
            padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
        buttonBarTheme: ButtonBarThemeData(
          buttonPadding: EdgeInsets.all(16.0),
          buttonTextTheme: ButtonTextTheme.accent,
        ),
        canvasColor: Colors.grey[800],
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 12.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        dialogTheme: DialogTheme(
          elevation: 12.0,
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        disabledColor: Colors.white38,
        dividerTheme: DividerThemeData(color: Colors.grey[800]),
        iconTheme: IconThemeData(color: Colors.grey[300], size: 32),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          disabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        primaryColor: Colors.blueAccent[100],
        scaffoldBackgroundColor: Colors.black,
        snackBarTheme: SnackBarThemeData(
          elevation: 12.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        fontFamily: 'Rubik',
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
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blueAccent[100],
        ),
      );
}
