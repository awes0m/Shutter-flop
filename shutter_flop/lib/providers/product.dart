import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shutter_flop/utils/constant.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavouriteValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String? authToken, String? userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.https(firebaseUrl, 'userFavourites/$userId/$id.json',
            {"auth": authToken}),
        body: json.encode(isFavourite),
      );
      if (response.statusCode >= 400) {
        _setFavouriteValue(oldStatus);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _setFavouriteValue(oldStatus);
    }
  }
}
