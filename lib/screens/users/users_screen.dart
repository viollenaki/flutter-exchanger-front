import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';
import '../../components/header_cell.dart';
import '../../components/table_cell.dart' as custom;
import '../../components/buttons/custom_button.dart';
import 'package:exchanger/components/background/animated_background.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<String> _users = [];
  int? _selectedRowIndex;
  bool _isSuperAdmin = false;
  late AnimationController _animationController;
  final formKey = GlobalKey<FormState>();
  Timer? _updateTimer;

  final Map<String, String> _headerTitles = {
    'username': 'Имя пользователя',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fetchUsers();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchUsers();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.fetchUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки пользователей')),
      );
    }
  }

  Future<void> _addUser(String username, String password, bool isSuperAdmin, String email, String phone) async {
    try {
      await ApiService.addUser(username, password, isSuperAdmin, email, phone);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Пользователь добавлен')),
      );
      await _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _editUser(String username, String oldUsername, String password, bool isSuperAdmin, String email, String phone) async {
    try {
      await ApiService.editUser(username, oldUsername, password, isSuperAdmin, email, phone);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Пользователь изменен')),
      );
      await _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка изменения пользователя')),
      );
    }
  }

  void _handleRowSelection(int index) {
    setState(() {
      if (_selectedRowIndex == index) {
        _selectedRowIndex = null;
        _animationController.reverse();
      } else {
        _selectedRowIndex = index;
        _animationController.forward();
      }
    });
  }

  Future<void> _deleteUser(String username) async {
    try {
      await ApiService.deleteUser(username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пользователь "$username" удален')),
      );
      setState(() {
        _selectedRowIndex = null;
        _animationController.reverse();
      });
      await _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления пользователя')),
      );
    }
  }

  Future<void> _showEditDialog(String username) async {
    Map<String, dynamic> userData = await ApiService.getUserDetails(username); 
    final TextEditingController usernameController = TextEditingController(text: username);
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController(text: userData["phone"]);
    final TextEditingController emailController = TextEditingController(text: userData["email"]);
    String oldUsername = username;
    bool isSuperAdmin = userData["is_superuser"];

    if (Theme.of(context).isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: const Text('Редактировать пользователя'),
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: _buildFormFields(
                    context,
                    usernameController: usernameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    passwordController: passwordController,
                    isSuperAdmin: isSuperAdmin,
                    onSuperAdminChanged: (value) => setState(() => isSuperAdmin = value ?? false),
                    isEditMode: true,
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Отмена'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Сохранить'),
                    onPressed: () async {
                      final usernameError = _validateUsername(usernameController.text);
                      final emailError = _validateEmail(emailController.text);
                      final phoneError = _validatePhone(phoneController.text);
                      final passwordError = _validatePassword(passwordController.text, true);

                      if (usernameError == null && emailError == null && passwordError == null && phoneError == null) {
                        await _editUser(
                          usernameController.text,
                          oldUsername,
                          passwordController.text.isNotEmpty ? passwordController.text : '',
                          isSuperAdmin,
                          emailController.text,
                          phoneController.text
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Редактировать пользователя'),
                content: _buildFormFields(
                  context,
                  usernameController: usernameController,
                  emailController: emailController,
                  phoneController: phoneController,
                  passwordController: passwordController,
                  isSuperAdmin: isSuperAdmin,
                  onSuperAdminChanged: (value) => setState(() => isSuperAdmin = value ?? false),
                  isEditMode: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await _editUser(
                          usernameController.text,
                          oldUsername,
                          passwordController.text.isNotEmpty ? passwordController.text : '',
                          isSuperAdmin,
                          emailController.text,
                          phoneController.text
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<void> _showDeleteDialog(String username) async {
    if (Theme.of(context).isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Удалить пользователя'),
            content: Text('Вы уверены, что хотите удалить пользователя "$username"?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _deleteUser(username);
                  Navigator.pop(context);
                },
                child: const Text('Удалить'),
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Удалить пользователя'),
            content: Text('Вы уверены, что хотите удалить пользователя "$username"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  _deleteUser(username);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Удалить'),
              ),
            ],
          );
        },
      );
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя пользователя';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите эл. почту';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный адрес эл. почты';
    }
    return null;
  }

  String? _validatePassword(String? value, bool isEditMode) {
    if (!isEditMode && (value == null || value.isEmpty)) {
      return 'Введите пароль';
    }
    if (value != null && value.isNotEmpty && value.length < 8) {
      return 'Пароль должен содержать не менее 8 символов';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }
    if (value.isNotEmpty && value.length < 12) {
      return 'Номер телефона должен содержать не менее 12 символов';
    }
    if (value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Номер телефона не должен содержать буквы';
    } 
    return null;
  }

  Widget _buildFormFields(BuildContext context, {
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController passwordController,
    required bool isSuperAdmin,
    required Function(bool?) onSuperAdminChanged,
    bool isEditMode = false,
  }) {
    final theme = Theme.of(context);

    if (theme.isIOS) {
      // Add state variables for validation error messages
      String? usernameError;
      String? emailError;
      String? phoneError;
      String? passwordError;

      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: usernameController,
                placeholder: 'Имя пользователя',
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: usernameError != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                onChanged: (value) {
                  setState(() {
                    usernameError = _validateUsername(value);
                  });
                },
              ),
              if (usernameError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    usernameError!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: emailController,
                placeholder: 'Эл. почта',
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: emailError != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                onChanged: (value) {
                  setState(() {
                    emailError = _validateEmail(value);
                  });
                },
              ),
              if (emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    emailError!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: phoneController,
                placeholder: 'Номер телефона(+996...)',
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: phoneError != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                onChanged: (value) {
                  setState(() {
                    phoneError = _validatePhone(value);
                  });
                },
              ),
              if (emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    emailError!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: passwordController,
                placeholder: isEditMode ? 'Пароль (оставьте пустым, если не хотите менять)' : 'Пароль',
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
                    passwordError = _validatePassword(value, isEditMode);
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Суперадмин', style: TextStyle(color: CupertinoColors.white)),
                  CupertinoSwitch(
                    value: isSuperAdmin,
                    onChanged: onSuperAdminChanged,
                  ),
                ],
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
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Имя пользователя'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите имя пользователя';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Эл. почта'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите эл. почту';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value)) {
                  return 'Введите корректный адрес эл. почты';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: isEditMode ? 'Пароль (оставьте пустым, если не хотите менять)' : 'Пароль',
              ),
              obscureText: true,
              validator: (value) {
                if (!isEditMode && (value == null || value.isEmpty)) {
                  return 'Введите пароль';
                }
                if (value != null && value.isNotEmpty && value.length < 8) {
                  return 'Пароль должен содержать не менее 8 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Супер-админ'),
                Checkbox(
                  value: isSuperAdmin,
                  onChanged: onSuperAdminChanged,
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showAddDialog() async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    if (Theme.of(context).isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: const Text('Добавить пользователя'),
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: _buildFormFields(
                    context,
                    usernameController: usernameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    passwordController: passwordController,
                    isSuperAdmin: _isSuperAdmin,
                    onSuperAdminChanged: (value) => setState(() => _isSuperAdmin = value ?? false),
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Отмена'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Добавить'),
                    onPressed: () async {
                      final usernameError = _validateUsername(usernameController.text);
                      final emailError = _validateEmail(emailController.text);
                      final passwordError = _validatePassword(passwordController.text, false);
                      final phoneError = _validatePhone(phoneController.text);

                      if (usernameError == null && emailError == null && passwordError == null && phoneError == null) {
                        await _addUser(usernameController.text, passwordController.text, _isSuperAdmin, emailController.text, phoneController.text);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Добавить пользователя'),
                content: _buildFormFields(
                  context,
                  usernameController: usernameController,
                  emailController: emailController,
                  phoneController: phoneController,
                  passwordController: passwordController,
                  isSuperAdmin: _isSuperAdmin,
                  onSuperAdminChanged: (value) => setState(() => _isSuperAdmin = value ?? false),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await _addUser(usernameController.text, passwordController.text, _isSuperAdmin, emailController.text, phoneController.text);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Добавить'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _animationController,
          child: FadeTransition(
            opacity: _animationController,
            child: Container(
              height: 60,
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedRowIndex != null) {
                        _showEditDialog(_users[_selectedRowIndex!]);
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Редактировать'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedRowIndex != null) {
                        _showDeleteDialog(_users[_selectedRowIndex!]);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white,),
                    label: const Text('Удалить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: SafeArea(
          child: _isLoading
              ? Column(
                  children: List.generate(
                    10,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ShimmerLoading(
                        width: double.infinity,
                        height: 50,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 150,
                    child: Column(
                      children: [
                        _buildActionButtons(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[900],
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      child: Container(
                                        color: Colors.grey[800],
                                        child: Row(
                                          children: _headerTitles.entries.map((entry) => 
                                            Expanded(
                                              child: HeaderCell(
                                                entry.value, 
                                                width: MediaQuery.of(context).size.width / _headerTitles.length,
                                              ),
                                            ),
                                          ).toList(),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: List.generate(
                                              _headerTitles.length,
                                              (index) => Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: index == 0
                                                        ? const BorderRadius.only(topLeft: Radius.circular(8))
                                                        : index == _headerTitles.length - 1
                                                            ? const BorderRadius.only(topRight: Radius.circular(8))
                                                            : BorderRadius.zero,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _users.length,
                                    itemBuilder: (context, index) {
                                      final user = _users[index];
                                      return GestureDetector(
                                        onTap: () => _handleRowSelection(index),
                                        child: Container(
                                          color: _selectedRowIndex == index 
                                            ? Colors.blue.withOpacity(0.2) 
                                            : null,
                                          child: Row(
                                            children: _headerTitles.keys.map((key) => 
                                              Expanded(
                                                child: custom.TableCell(
                                                  user, 
                                                  width: MediaQuery.of(context).size.width / _headerTitles.length, // Adjust width dynamically
                                                ),
                                              ),
                                            ).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Add some space between the table and the button
                        CustomButton(
                          onPressed: _showAddDialog,
                          text: 'Добавить',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}