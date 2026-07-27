import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class JobCreationProvider extends ChangeNotifier {
  final List<String> _tags = [];
  final List<String> _benefits = [];
  final List<File> _newImages = [];
  final List<String> _existingImageUrls = [];
  
  bool _isLoading = false;
  String? _vacancyId;

  // Getters
  List<String> get tags => _tags;
  List<String> get benefits => _benefits;
  List<File> get newImages => _newImages;
  List<String> get existingImageUrls => _existingImageUrls;
  bool get isLoading => _isLoading;

  void setVacancy(Map<String, dynamic>? vacancy) {
    if (vacancy == null) return;
    
    _vacancyId = vacancy['id'];
    _tags.clear();
    if (vacancy['requirements'] != null) {
      _tags.addAll(List<String>.from(vacancy['requirements']));
    }
    
    _benefits.clear();
    if (vacancy['providesTransport'] == true) _benefits.add('transporte');
    
    _existingImageUrls.clear();
    if (vacancy['images'] != null) {
      _existingImageUrls.addAll(List<String>.from(vacancy['images']));
    }
    notifyListeners();
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void toggleBenefit(String id) {
    if (_benefits.contains(id)) {
      _benefits.remove(id);
    } else {
      _benefits.add(id);
    }
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      _newImages.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  void removeNewImage(int index) {
    _newImages.removeAt(index);
    notifyListeners();
  }

  void removeExistingImage(int index) {
    _existingImageUrls.removeAt(index);
    notifyListeners();
  }

  Future<bool> submitVacancy({
    required String title,
    required String salary,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final double salaryVal = double.tryParse(salary) ?? 0;
      
      // Preparar FormData para subida de archivos y campos
      final Map<String, dynamic> body = {
        'title': title,
        'roleTitle': title,
        'salaryMin': salaryVal,
        'salaryMax': salaryVal,
        'requirements': _tags, // Dio se encarga de formatear esto si lo pasamos bien o enviamos como JSON string
        'availabilityTarget': address,
        'description': 'Vacante generada en Chamby App',
        'providesTransport': _benefits.contains('transporte'),
      };

      // FormData
      final formData = FormData.fromMap(body);

      // Agregar requisitos como string JSON (necesario para Multer/Express a veces)
      formData.fields.add(MapEntry('requirements', '["${_tags.join('","')}"]'));

      // Agregar imágenes nuevas
      for (var file in _newImages) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }

      final isEdit = _vacancyId != null;
      final response = isEdit
          ? await ApiService.put('/employers/vacancies/$_vacancyId', formData)
          : await ApiService.postMultipart('/employers/vacancies', formData);

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
