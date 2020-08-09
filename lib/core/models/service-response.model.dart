import 'dart:io';

class ServiceResponse {
  //this class aims to provide a 2-part list, for single-method-call-to-multiple-API-calls scenarios
  bool hasErrors;
  bool hasItems;
  List<dynamic> items = [];
  List<HttpException> errors = [];

  ServiceResponse(this.items, this.errors) {
    hasItems = false;
    hasErrors = false;
    if (items != null && items.length > 0) hasItems = true;
    if (errors != null && errors.length > 0) hasErrors = true;
  }
}
