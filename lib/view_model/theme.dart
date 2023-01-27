import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme = ThemeData(
      drawerTheme: DrawerThemeData(backgroundColor: Color(0xffe7e7e7)),
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
        buttonColor: Color(0xFF80c783),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xFF59B200),
        labelStyle: TextStyle(color: Color(0xff585858)),
        unselectedLabelColor: Color(0XFF999999)
      ),
      primaryColor: Color(0xffEEEEEE),
    accentColor: Color(0XFFA3D900),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.lightGreen
    ),
      bannerTheme: MaterialBannerThemeData(
          backgroundColor: Color(0xFFEEEEEE)
      ),
    backgroundColor: Colors.white
  );

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
        backgroundColor: Color(0xff26334d),
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
          color: Color(0xff25334D), foregroundColor: Color(0xffF4F6F6)),
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xff0e91ce),
        labelStyle: TextStyle(color: Colors.cyan),
          unselectedLabelColor: Color(0xff697a9b)
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff80C783),
      ),
      primaryColor: Color(0xff202b40),
      accentColor: Color(0xff0e91ce),
      listTileTheme: ListTileThemeData(
          iconColor: Colors.lightBlue
      ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: Color(0xff202b40),

    ),
      backgroundColor: Color(0xff1A2133)

  );
}
