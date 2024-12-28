import 'package:exchanger/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../events/events_screen.dart';
import '../currencies/currencies_screen.dart';
import '../users/users_screen.dart';
import '../cash_register/cash_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onDrawerOpened;

  const AppDrawer({
    super.key,
    this.onDrawerOpened,
  });

  Future<void> showClearConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подтверждение'),
          content: Text('Вы уверены, что хотите очистить все данные?'),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Да'),
              onPressed: () async {
                // Close first dialog
                Navigator.of(context).pop();
                
                // Show second dialog
                final loginController = TextEditingController();
                final passwordController = TextEditingController();
                
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Авторизация Супер-Админа'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: loginController,
                            decoration: InputDecoration(labelText: 'Логин'),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: 'Пароль'),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('Отмена'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('Подтвердить'),
                          onPressed: () async {
                            bool isCleared = await ApiService.clearAll(
                              loginController.text,
                              passwordController.text,
                            );
                            
                            if (isCleared) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Данные успешно очищены')),
                              );
                            } else {
                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Неверные учетные данные супер-админа')),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

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
          ListTile(
            leading: Icon(Icons.money_sharp),
            title: Text('Касса'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => CashScreen()));
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
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Очистить'),
                onTap: () {
                  Navigator.pop(context);
                  showClearConfirmationDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}