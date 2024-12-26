import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../events/events_screen.dart';
import '../currencies/currencies_screen.dart';
import '../users/users_screen.dart';

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => EventsScreen()));
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.settings),
            title: Text('Настройки'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Пользователи'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text('Валюты'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CurrenciesScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}