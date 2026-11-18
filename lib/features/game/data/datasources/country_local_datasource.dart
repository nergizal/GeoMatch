import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geo/core/errors/exceptipns.dart';
import '../models/country_model.dart';

/// Yerel JSON dosyasından ülke verilerini okuyan veri kaynağı arayüzü.
abstract interface class CountryLocalDataSource {
  Future<List<CountryModel>> loadCountriesFromAsset();
}

class CountryLocalDataSourceImpl implements CountryLocalDataSource {
  final AssetBundle assetBundle;
  final String assetPath;

  CountryLocalDataSourceImpl({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/data/countries.json',
  }) : assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<CountryModel>> loadCountriesFromAsset() async {
    try {
      final jsonString = await assetBundle.loadString(assetPath);
      final List<dynamic> decodedList = json.decode(jsonString) as List<dynamic>;

      if (decodedList.isEmpty) {
        throw const CacheException('countries.json dosyası boş.');
      }

      return decodedList
          .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Ülke verileri ayrıştırılamadı: $e');
    }
  }
}