import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme = ThemeData(
      drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
      textTheme: TextTheme(
          headline5: TextStyle(
        color: Color(0xff232326),
      )),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Color(0xffe3e6ea),
      ),
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(),
      scaffoldBackgroundColor: Color(0xffaebac1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.black,
            elevation: 10,
            primary: Color(0xff80C783),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
      ),
      appBarTheme: AppBarTheme(
          color: Color(0xffe7e7e7), foregroundColor: Color(0xff808080)),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff80C783),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xff585858),
        labelStyle: TextStyle(color: Color(0xff585858)),
      ),
      primaryColor: Color(0xff3b3b3b));

  static ThemeData darkTheme = ThemeData(
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Color(0xff293d5a),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xff202b40),
        selectedItemColor: Color(0xff017eba),
        unselectedItemColor: Color(0xff697a9b),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Color(0xff192132),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Color(0xff26334d),
        selectedTileColor: Colors.deepPurple,
      ),
      textTheme: TextTheme(
          headline5: TextStyle(
        color: Color(0xffe1e4ee),
      )),
      primarySwatch: Colors.red,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(),
      scaffoldBackgroundColor: Color(0xff192132),
      cardColor: Color(0xff26334d),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.black,
            elevation: 10,
            primary: Color(0xff80C783),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
      ),
      appBarTheme: AppBarTheme(
          color: Color(0xff26334d), foregroundColor: Color(0xffd9d9d9)),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.cyan,
        labelStyle: TextStyle(color: Colors.cyan), // color for text
        // outdated and has no effect to Tabbar
        // deprecated,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff80C783),
      ),
      primaryColor: Color(0xff202b40));
}
