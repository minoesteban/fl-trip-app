import 'dart:io';
import 'package:hive/hive.dart';

import '../../core/models/user.model.dart';
import '../../core/services/user.service.dart';

class UserController {
  UserService _userService = UserService();
  Box<User> userBox;

  Future<User> init() async {
    userBox = await Hive.openBox('users');
    return userBox.get('current');
  }

  Future<void> setCurrentLocal(User user) {
    return userBox.put('current', user);
  }

  Future<User> getUser(int userId) async {
    return await _userService.getUser(userId).catchError((err) => throw err);
  }

  Future<int> update(User newUser) async {
    return await _userService.update(newUser).catchError((err) => throw err);
  }

  Future<String> uploadImage(int id, File image) async {
    return await _userService.uploadImage(id, image);
  }
}
