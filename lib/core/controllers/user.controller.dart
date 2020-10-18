import 'dart:io';
import 'package:hive/hive.dart';

import '../../core/models/user.model.dart';
import '../../core/services/user.service.dart';

class UserController {
  UserService _service = UserService();
  Box<User> userBox;

  Future<User> init() async {
    userBox = await Hive.openBox('users');
    return userBox.get('current');
  }

  Future<int> login(String user, String password) async {
    return await _service.login(user, password);
  }

  Future<bool> signup(String user, String password) async {
    return await _service.signup(user, password);
  }

  Future<bool> activate(String user, String pin) async {
    return await _service.activate(user, pin);
  }

  Future<void> setCurrentLocal(User user) {
    return userBox.put('current', user);
  }

  Future<void> logout() async {
    return await userBox.delete('current');
  }

  Future<User> getUser(int userId) async {
    return await _service.getUser(userId).catchError((err) => throw err);
  }

  Future<int> update(User newUser) async {
    return await _service.update(newUser).catchError((err) => throw err);
  }

  Future<String> uploadImage(int id, File image) async {
    return await _service.uploadImage(id, image);
  }
}
