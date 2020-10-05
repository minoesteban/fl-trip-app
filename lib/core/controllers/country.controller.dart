import 'package:tripper/core/models/country.model.dart';
import 'package:tripper/core/services/country.service.dart';

class CountryController {
  Future<List<Country>> getCountries() async {
    return await CountryService().getCountries().catchError((err) => throw err);
  }
}
