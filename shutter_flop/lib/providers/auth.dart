import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exceptions.dart';
import '../utils/constant.dart';

String signupUrlSegment = 'signUp';
String signinUrlSegment = 'signInWithPassword';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

//token getters
  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  //userId getters
  String? get userId {
    // if (_expiryDate != null &&
    //     _expiryDate!.isAfter(DateTime.now()) &&
    //     _token != null) {
    //   return _userId;
    // }
    // return null;
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String linkSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$linkSegment?key=$API_KEY');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, signupUrlSegment);
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, signinUrlSegment);
  }
}
