import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier{

  bool _isDark = false;
  bool get isDark => _isDark;

  late SharedPreferences storage;

  //Custom dark theme
  final darkTheme = ThemeData(
    primaryColor: Colors.black12,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black12,
  );

  //Custom light theme
  final lightTheme = ThemeData(
      primaryColor: Colors.white,
      brightness: Brightness.light,
      primaryColorDark: Colors.white
  );

  final blueTheme = ThemeData(
    primaryColor: Color(0x0067A1), // Hex #2196F3 (Blue),
    brightness: Brightness.light,
    primaryColorDark: Colors.pinkAccent,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0067A1), // Pink AppBar
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white), // AppBar icons color
    ),

    // Button Theme
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF0067A1), // Default button color
      textTheme: ButtonTextTheme.primary,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Button text color
        backgroundColor: Color(0xFF0067A1), // Button background color
      ),
    ),

    // TextButton Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // backgroundColor: Colors.pink, // TextButton color
        foregroundColor: Color(0xFF0067A1), // TextButton color
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0067A1), // Background color
      selectedItemColor: Colors.white, // Selected icon & text color
      unselectedItemColor: Colors.white70, // Unselected icon & text color
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, backgroundColor: Color(0xFF0067A1)), // Selected text style
      unselectedLabelStyle: TextStyle(fontSize: 12), // Unselected text style
    ),


    // Icon Theme
    iconTheme: IconThemeData(color: Colors.pink), // Default icon color
    primaryIconTheme: IconThemeData(color: Colors.white), // Primary icon color (AppBar, etc.)

    // Text Theme
    // textTheme: TextTheme(
    //   bodyLarge: TextStyle(color: Colors.pinkAccent, fontSize: 18), // Large text
    //   bodyMedium: TextStyle(color: Colors.pink, fontSize: 16), // Medium text
    //   bodySmall: TextStyle(color: Colors.pink, fontSize: 14), // Small text
    //   titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), // Large titles
    // ),
  );


  //Dark mode toggle action
  changeTheme(){
    _isDark = !isDark;

    //Save the value to secure storage
    storage.setBool("isDark", _isDark);
    notifyListeners();
  }

  //Init method of provider
  init()async{
    //After we re run the app
    storage = await SharedPreferences.getInstance();
    _isDark = storage.getBool("isDark")??false;
    notifyListeners();
  }
}