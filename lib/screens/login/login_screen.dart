import 'package:exchanger/components/background/animated_background.dart';
import 'package:flutter/material.dart';
import '../../components/buttons/custom_button.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

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
                    const FlutterLogo(size: 100),
                    const SizedBox(height: 32.0),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Имя пользователя',
                        border: const OutlineInputBorder(),
                        errorText: _loginFailed ? 'Неверное имя пользователя или пароль' : null,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        border: const OutlineInputBorder(),
                        errorText: _loginFailed ? 'Неверное имя пользователя или пароль' : null,
                      ),
                      obscureText: true,
                    ),
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
                        final TextEditingController emailController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Восстановление пароля'),
                              content: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Введите вашу почту',
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
                                    _showLoadingIndicator();

                                    try {
                                      await ApiService.resetPassword(emailController.text);
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Успех'),
                                            content: const Text('Ссылка для сброса отправлена на почту'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('ОК'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Ошибка: $e')),
                                      );
                                    } finally {
                                      _hideLoadingIndicator();
                                    }
                                  },
                                  child: const Text('Отправить'),
                                ),
                              ],
                            );
                          },
                        );
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