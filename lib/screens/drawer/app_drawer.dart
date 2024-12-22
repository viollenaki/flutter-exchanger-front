import 'package:flutter/material.dart';
import '../../models/user.dart';

import '../events/events_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onDrawerOpened;

  const AppDrawer({
    super.key,
    this.onDrawerOpened,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDrawerOpened?.call();
    });

    final username = UserManager().getCurrentUser();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Привет, $username!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54, // Dark color for the circle
                  ),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () {
                      UserManager().setCurrentUser(null);
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('События'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Настройки'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}