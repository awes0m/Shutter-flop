import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exceptions.dart';
import '../utils/constant.dart';
import './product.dart';

class Products with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Product> _items = [
    // Product(
    //   id: 'p1 ',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];

  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //fetches data from firebase

    var params = {
      'orderBy': '"creatorId"',
      'equalTo': '"$userId"',
      'print': 'pretty',
    };

    String paramString =
        params.entries.map((p) => '${p.key}=${p.value}').join('&');
    final filterString = filterByUser ? paramString : '';
    final url =
        Uri.https(firebaseUrl, "/products.json?auth=$authToken&$filterString");
    try {
      final response = await http.get(url);
      //print('data= ${response.body}');

      Map<String, dynamic>? extractedData =
          jsonDecode(response.body.toString());
      print(extractedData);
      // final List<Product> loadedProducts = [];
      // if (extractedData == null) {
      //   return;
      // }
      // final favouriteUrl = Uri.https(
      //     firebaseUrl, '/userFavourites/$userId.json', {"auth": authToken});
      // final favouriteResponse = await http.get(favouriteUrl);
      // final favouriteData = json.decode(favouriteResponse.body);
      // extractedData.forEach((prodId, prodData) {
      //   loadedProducts.add(Product(
      //     id: prodId,
      //     title: prodData['title'],
      //     description: prodData['description'],
      //     price: prodData['price'],
      //     isFavourite:
      //         favouriteData == null ? false : favouriteData[prodId] ?? false,
      //     imageUrl: prodData['imageUrl'],
      //   ));
      // });
      // _items = loadedProducts;
      // notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    //add product to firebase
    var params = {
      "auth": authToken,
      "orderBy": userId,
    };
    String paramString =
        params.entries.map((p) => '${p.key}=${p.value}').join('&');
    final url = Uri.parse(
      firebaseUrl + '/products.json' + paramString,
    );
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct);// to add product at start of list
      notifyListeners();
    } catch (error) {
      //print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    // update product
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      final url =
          Uri.https(firebaseUrl, '/products/$id.json', {"auth": authToken});
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }),
        );
      } catch (error) {
        rethrow;
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      //print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        Uri.https(firebaseUrl, '/products/$id.json', {"auth": authToken});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct); // to undo delete
      notifyListeners();
      throw HttpException('Failed to delete product');
    }
    existingProduct = null;

    notifyListeners();
  }
}
