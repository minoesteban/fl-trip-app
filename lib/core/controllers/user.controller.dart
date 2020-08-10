import 'package:image_picker/image_picker.dart';
import '../../core/models/user.model.dart';
import '../../core/services/user.service.dart';

class UserController {
  UserService _userService = UserService();

  Future<User> getUser(int userId) async {
    return await _userService.getUser(userId).catchError((err) => throw err);
  }

  Future<int> update(User newUser) async {
    return await _userService.update(newUser).catchError((err) => throw err);
  }

  Future<String> uploadImage(int id, PickedFile image) async {
    return await _userService.uploadImage(id, image);
  }
}
