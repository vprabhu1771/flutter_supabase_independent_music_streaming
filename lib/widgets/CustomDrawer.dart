import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/BrandScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/GenreScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/SettingScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/song/SongScreen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import '../screens/HomeScreen.dart';
import '../screens/playlist/PlaylistScreen.dart';
import '../screens/auth/LoginScreen.dart';
import '../screens/auth/ProfileScreen.dart';
import '../screens/auth/RegisterScreen.dart';

final supabase = Supabase.instance.client;
final storage = FlutterSecureStorage();

class CustomDrawer extends StatelessWidget {
  final BuildContext parentContext;

  CustomDrawer({required this.parentContext});

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await storage.delete(key: 'session');

    // Navigate to login screen and remove all previous routes
    Navigator.pushReplacement(
      parentContext,
      MaterialPageRoute(
        // builder: (context) => LoginScreen(title: 'Login'),
        builder: (context) => HomeScreen(title: 'Home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (user != null) ...[
            UserAccountsDrawerHeader(
              accountName: Text(user.userMetadata?['name'] ?? "User Name"),
              accountEmail: Text(user.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Songs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => SongScreen(title: 'Songs'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Genre'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => GenreScreen(title: 'Genre'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Brand'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => BrandScreen(title: 'Brand'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Playlist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => PlaylistScreen(title: 'Playlist'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => SettingScreen(title: 'Settings'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(title: 'Profile'),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: signOut,
            ),
          ] else ...[
            UserAccountsDrawerHeader(
              accountName: Text(user != null ? "User Name" : "Guest"),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                Navigator.pushReplacement(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(title: 'Login'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Register'),
              onTap: () {
                Navigator.pushReplacement(
                  parentContext,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(title: 'Register'),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}