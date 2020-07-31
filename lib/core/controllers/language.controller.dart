import '../../core/models/language.model.dart';
import '../../core/services/language.service.dart';

class LanguageController {
  Future<List<Language>> getLanguages() async {
    return await LanguageService()
        .getLanguages()
        .catchError((err) => throw err);
  }
}
