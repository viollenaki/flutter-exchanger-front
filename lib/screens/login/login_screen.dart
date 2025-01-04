import 'package:exchanger/components/background/animated_background.dart';
import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../components/buttons/custom_button.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../logo/custom_logo.dart'; // Import the custom logo widget

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loginFailed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_resetErrorState);
    passwordController.addListener(_resetErrorState);
  }

  void _resetErrorState() {
    if (_loginFailed) {
      setState(() {
        _loginFailed = false;
      });
    }
  }

  @override
  void dispose() {
    usernameController.removeListener(_resetErrorState);
    passwordController.removeListener(_resetErrorState);
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showLoadingIndicator() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoadingIndicator() {
    setState(() {
      _isLoading = false;
    });
  }

  void _showPasswordResetDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).isAndroid) {
          return _buildAndroidPasswordResetDialog(context, emailController);
        } else if (Theme.of(context).isIOS) {
          return _buildIOSPasswordResetDialog(context, emailController);
        } else {
          return _buildDefaultPasswordResetDialog(context, emailController);
        }
      },
    );
  }

  bool _isValidEmailOrPhone(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final phoneRegex = RegExp(r'^\+[0-9]+$');
    return emailRegex.hasMatch(input) || phoneRegex.hasMatch(input);
  }

  AlertDialog _buildAndroidPasswordResetDialog(BuildContext context, TextEditingController emailController) {
    return AlertDialog(
      title: const Text('Восстановление пароля'),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: 'Введите почту или номер(+996...)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            final trimmedValue = emailController.text.trim();
            if (!_isValidEmailOrPhone(trimmedValue)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите почту или номер(+996...)')),
              );
              return;
            }
            await _handlePasswordReset(context, trimmedValue);
          },
          child: const Text('Отправить'),
        ),
      ],
    );
  }

  CupertinoAlertDialog _buildIOSPasswordResetDialog(BuildContext context, TextEditingController emailController) {
    return CupertinoAlertDialog(
      title: const Text('Восстановление пароля'),
      content: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Add padding from the title
        child: CupertinoTextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          placeholder: 'Введите почту или номер(+996...)',
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отмена'),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            final trimmedValue = emailController.text.trim();
            if (!_isValidEmailOrPhone(trimmedValue)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите почту или номер(+996...)')),
              );
              return;
            }
            await _handlePasswordReset(context, trimmedValue);
          },
          child: const Text('Отправить'),
        ),
      ],
    );
  }

  AlertDialog _buildDefaultPasswordResetDialog(BuildContext context, TextEditingController emailController) {
    return AlertDialog(
      title: const Text('Восстановление пароля'),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: 'Введите почту или номер(+996...)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            final trimmedValue = emailController.text.trim();
            if (!_isValidEmailOrPhone(trimmedValue)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите почту или номер(+996...)')),
              );
              return;
            }
            await _handlePasswordReset(context, trimmedValue);
          },
          child: const Text('Отправить'),
        ),
      ],
    );
  }

  Future<void> _handlePasswordReset(BuildContext context, String email) async {
    _showLoadingIndicator();
    try {
      await ApiService.resetPassword(email);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          if (Theme.of(context).isAndroid) {
            return AlertDialog(
              title: const Text('Успеx'),
              content: const Text('Ссылка для сброса отправлена.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ОК'),
                ),
              ],
            );
          } else if (Theme.of(context).isIOS) {
            return CupertinoAlertDialog(
              title: const Text('Успех'),
              content: const Text('Ссылка для сброса отправлена.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ОК'),
                ),
              ],
            );
          } else {
            return AlertDialog(
              title: const Text('Успех'),
              content: const Text('Ссылка для сброса отправлена.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ОК'),
                ),
              ],
            );
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      _hideLoadingIndicator();
    }
  }

  Widget _buildUsernameField() {
    if (Theme.of(context).isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: usernameController,
            placeholder: 'Имя пользователя',
            decoration: BoxDecoration(
              border: Border.all(
                color: _loginFailed ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.7)),
            style: const TextStyle(color: Colors.white),
            padding: const EdgeInsets.all(16.0),
          ),
          if (_loginFailed)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
              child: Text(
                'Неверное имя пользователя или пароль',
                style: TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
              ),
            ),
        ],
      );
    } else {
      return TextField(
        controller: usernameController,
        decoration: InputDecoration(
          labelText: 'Имя пользователя',
          border: const OutlineInputBorder(),
          errorText: _loginFailed ? 'Неверное имя пользователя или пароль' : null,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
          ),
        ),
      );
    }
  }

  Widget _buildPasswordField() {
    if (Theme.of(context).isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: passwordController,
            placeholder: 'Пароль',
            obscureText: true,
            decoration: BoxDecoration(
              border: Border.all(
                color: _loginFailed ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.7)),
            style: const TextStyle(color: Colors.white),
            padding: const EdgeInsets.all(16.0),
          ),
          if (_loginFailed)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
              child: Text(
                'Неверное имя пользователя или пароль',
                style: TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
              ),
            ),
        ],
      );
    } else {
      return TextField(
        controller: passwordController,
        decoration: InputDecoration(
          labelText: 'Пароль',
          border: const OutlineInputBorder(),
          errorText: _loginFailed ? 'Неверное имя пользователя или пароль' : null,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
          ),
        ),
        obscureText: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем AppBar
      body: AnimatedBackground(
        child: Stack(
          children: [
            SafeArea( // Добавляем SafeArea
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                  top: 100.0, // Добавляем больший отступ сверху
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Change from center to start
                  children: [
                    const SizedBox(height: 50.0), // Add some space at the top
                    const CustomLogo(), // Use the custom logo widget
                    const SizedBox(height: 32.0),
                    _buildUsernameField(),
                    const SizedBox(height: 16.0),
                    _buildPasswordField(),
                    const SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () async {
                          _showLoadingIndicator();

                          User? user = await ApiService.authenticate(
                            usernameController.text.trim(),
                            passwordController.text.trim(),
                          );

                          _hideLoadingIndicator();

                          if (user != null) {
                            UserManager().setCurrentUser(user);
                            await ApiService.getAccessJWT(user.username, passwordController.text.trim());
                            await ApiService.isSuperUser(user.username);
                            Navigator.pushReplacementNamed(context, '/main');
                          } else {
                            setState(() {
                              _loginFailed = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ошибка входа')),
                            );
                          }
                        },
                        text: 'Войти',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        _showPasswordResetDialog(context);
                      },
                      child: const Text('Забыли пароль?'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}