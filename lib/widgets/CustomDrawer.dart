import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/admin/AritstManagementScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/BrandScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/GenreScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/UploadScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/playlist/PlaylistScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/song/MySongScreen.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/song/SongScreen.dart';
import 'package:provider/provider.dart';


import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



import '../admin/AdminDashboard.dart';
import '../admin/SongManagementScreen.dart';
import '../screens/HomeScreen.dart';

import '../screens/SettingScreen.dart';

import '../screens/auth/LoginScreen.dart';
import '../screens/auth/ProfileScreen.dart';
import '../screens/auth/RegisterScreen.dart';
import '../services/UiProvider.dart';

class CustomDrawer extends StatelessWidget {
  final BuildContext parentContext;

  CustomDrawer({required this.parentContext});

  final supabase = Supabase.instance.client;
  final storage = FlutterSecureStorage();

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await storage.delete(key: 'session');
    Navigator.pushReplacement(
      parentContext,
      MaterialPageRoute(builder: (context) => LoginScreen(title: 'Login')),
    );
  }

  Future<String?> getUserRole() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await supabase
        .from('user_roles')
        .select('roles(id, name)')
        .eq('user_id', userId)
        .maybeSingle();

    return response != null ? response['roles']['name'] as String? : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    final themeProvider = Provider.of<UiProvider>(context);
    final theme = themeProvider.isDark ? themeProvider.darkTheme : themeProvider.orangeTheme;


    return Drawer(
      child: FutureBuilder<String?>(
        future: getUserRole(),
        builder: (context, snapshot) {
          final role = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.userMetadata?['name'] ?? "Guest"),
                accountEmail: Text(user?.email ?? "No Email"),
                currentAccountPicture: CircleAvatar(
                    // child: Icon(Icons.person, size: 40)
                  backgroundImage: NetworkImage(user?.userMetadata?['image_path'] ?? 'https://gravatar.com/avatar/${user!.email}'),
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor, // Themed background color
                ),
              ),

              // Common for all logged-in users
              if (user != null) ...[
                // ListTile(
                //   leading: Icon(Icons.home),
                //   title: Text('Home'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(parentContext, MaterialPageRoute(builder: (context) => HomeScreen(title: 'Home')));
                //   },
                // ),
              ],

              // Role-based rendering
              if (role == 'admin') ...[
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(parentContext, MaterialPageRoute(builder: (context) => AdminDashboard(title: 'Admin Dashboard')));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text('Song Management'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(parentContext, MaterialPageRoute(builder: (context) => SongManagementScreen(title: 'Song Management')));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Aritst Management'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(parentContext, MaterialPageRoute(builder: (context) => AritstManagementScreen(title: 'Aritst Management')));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
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

              ] else if (role == 'customer') ...[
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        parentContext,
                        MaterialPageRoute(builder: (context) => HomeScreen(title: 'Home'))
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.library_music),
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
                  leading: Icon(Icons.headset),
                  title: Text('My Songs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => MySongScreen(title: 'My Songs'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cloud_upload),
                  title: Text('Song Upload'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => UploadScreen(title: 'Song Upload'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category),
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
                  leading: Icon(Icons.store),
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
                  leading: Icon(Icons.queue_music),
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
                  leading: Icon(Icons.account_circle),
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

              ],

              // Logout option for authenticated users
              if (user != null) ...[
                Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: signOut,
                ),
              ] else ...[
                // Guest users: Login & Register
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login'),
                  onTap: () {
                    Navigator.pushReplacement(
                      parentContext,
                      MaterialPageRoute(builder: (context) => LoginScreen(title: 'Login')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.app_registration),
                  title: Text('Register'),
                  onTap: () {
                    Navigator.pushReplacement(
                      parentContext,
                      MaterialPageRoute(builder: (context) => RegisterScreen(title: 'Register')),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}