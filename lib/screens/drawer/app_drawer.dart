import 'package:exchanger/services/api_service.dart';
import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/user.dart';
import '../events/events_screen.dart';
import '../currencies/currencies_screen.dart';
import '../users/users_screen.dart';
import '../cash_register/cash_screen.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onDrawerOpened;

  const AppDrawer({
    super.key,
    this.onDrawerOpened,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool? _isSuperAdmin;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  Future<void> _checkSuperUser() async {
    final username = UserManager().getCurrentUser();
    if (username != null) {
      final result = await ApiService.isSuperUser(username);
      setState(() {
        _isSuperAdmin = result;
      });
    }
  }

  String? _validateSuperAdminField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Введите $fieldName';
    }
    return null;
  }

  Widget _buildSuperAdminFields(BuildContext context, {
    required TextEditingController loginController,
    required TextEditingController passwordController,
  }) {
    final theme = Theme.of(context);
    String? loginError;
    String? passwordError;

    if (theme.isIOS) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: loginController,
                placeholder: 'Логин',
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: loginError != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                onChanged: (value) {
                  setState(() {
                    loginError = _validateSuperAdminField(value, 'логин');
                  });
                },
              ),
              if (loginError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    loginError!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: passwordController,
                placeholder: 'Пароль',
                obscureText: true,
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: passwordError != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                onChanged: (value) {
                  setState(() {
                    passwordError = _validateSuperAdminField(value, 'пароль');
                  });
                },
              ),
              if (passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    passwordError!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      );
    } else {
      return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: loginController,
              decoration: const InputDecoration(labelText: 'Логин'),
              validator: (value) => _validateSuperAdminField(value, 'логин'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
              validator: (value) => _validateSuperAdminField(value, 'пароль'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> showClearConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
    
    if (theme.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Подтверждение'),
            content: const Text('Вы уверены, что хотите очистить все данные?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.pop(context);
                  final loginController = TextEditingController();
                  final passwordController = TextEditingController();

                  await showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text('Авторизация Супер-Админа'),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: _buildSuperAdminFields(
                            context,
                            loginController: loginController,
                            passwordController: passwordController,
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Отмена'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoDialogAction(
                            child: const Text('Подтвердить'),
                            onPressed: () async {
                              final loginError = _validateSuperAdminField(loginController.text, 'логин');
                              final passwordError = _validateSuperAdminField(passwordController.text, 'пароль');
                              
                              if (loginError == null && passwordError == null) {
                                bool isCleared = await ApiService.clearAll(
                                  loginController.text,
                                  passwordController.text,
                                );
                                
                                Navigator.pop(context);
                                if (isCleared) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Данные успешно очищены')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Неверные учетные данные супер-админа')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Да'),
              ),
            ],
          );
        },
      );
    } else {
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
                            _buildSuperAdminFields(
                              context,
                              loginController: loginController,
                              passwordController: passwordController,
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
                              if (formKey.currentState!.validate()) {
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
  }

  @override
  Widget build(BuildContext context) {
    widget.onDrawerOpened?.call();
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
                    color: Colors.black54, 
                  ),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () {
                      ApiService.clearSuperUserCache();
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
              if (_isSuperAdmin ?? false)
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
              if (_isSuperAdmin ?? false)
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