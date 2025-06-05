import 'package:flutter/material.dart';
import '../models/cep_model.dart';
import '../services/cep_service.dart';

class CepProvider extends ChangeNotifier {
  final CepService _cepService = CepService();
  List<CepModel> ceps = [];
  bool isLoading = false;

  Future<void> loadCeps({String? search}) async {
    isLoading = true;
    notifyListeners();
    ceps = await _cepService.fetchCeps(search: search);
    isLoading = false;
    notifyListeners();
  }
}
