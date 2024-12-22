
class User {
  final String username;

  User({required this.username});
}

class UserManager {
  static final UserManager _instance = UserManager._internal();
  User? _currentUser;

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  String? getCurrentUser() {
    return _currentUser?.username;
  }
}