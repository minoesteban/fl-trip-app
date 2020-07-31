import 'package:tripit/core/models/country.model.dart';
import 'package:tripit/core/services/country.service.dart';

class CountryController {
  Future<List<Country>> getCountries() async {
    return await CountryService().getCountries().catchError((err) => throw err);
  }
}
