import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iitism_smartid_merchant/constansts.dart';
import 'package:iitism_smartid_merchant/models/merchant.dart';
import 'package:iitism_smartid_merchant/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

enum AuthStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Refreshing
}

class AuthProvider extends ChangeNotifier {
  AuthStatus status;
  Merchant merchant;
  String token;
  String error;
  bool refreshing;

  AuthProvider.instance()
      : status = AuthStatus.Uninitialized,
        refreshing = false {
    _init();
  }

  Map<String, String> getHeaders() {
    Map<String, String> mp = Map();
    mp['Authorization'] = 'Bearer ' + this.token;
    mp['Content-Type'] = "application/json";
    return mp;
  }

  _init() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map merchantData = json.decode(prefs.get('currentMerchant'));
      merchant = Merchant.fromMap(merchantData);
      token = prefs.getString('token');
      if (merchant != null && token != null) {
        status = AuthStatus.Authenticated;
      } else {
        status = AuthStatus.Unauthenticated;
      }
    } catch (error) {
      status = AuthStatus.Unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    Map<String, String> mp = Map();
    mp['email'] = email;
    mp['password'] = password;
    status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      Response response =
          await http.post(BASE_URL + 'merchants/login', body: mp);
      Map<String, dynamic> parsedResponse;
      parsedResponse = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (parsedResponse['success']) {
        prefs.setString('token', parsedResponse['token']);
        prefs.setString(
            'currentMerchant', json.encode(parsedResponse['merchant']));
        merchant = Merchant.fromMap(parsedResponse['merchant']);
        token = parsedResponse['token'];
        status = AuthStatus.Authenticated;
      } else {
        error = parsedResponse['error'];
        status = AuthStatus.Unauthenticated;
      }
    } catch (e) {
      error = e.toString();
      status = AuthStatus.Unauthenticated;
    }
    notifyListeners();
  }

  Future<void> refreshMerchantData() async {
    refreshing = true;
    notifyListeners();
    try {
      Response response = await http.get(
          BASE_URL + 'merchant/' + merchant.merchantId.toString(),
          headers: getHeaders());
      Map<String, dynamic> parsedResponse;
      parsedResponse = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (parsedResponse['success']) {
        prefs.setString(
            'currentMerchant', json.encode(parsedResponse['merchant']));
        merchant = Merchant.fromMap(parsedResponse['merchant']);
      } else {
        error = parsedResponse['error'];
        await logout();
      }
    } catch (e) {
      error = e.toString();
      await logout();
    }
    refreshing = false;
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('currentMerchant');
    prefs.remove('token');
    token = null;
    merchant = null;
    status = AuthStatus.Unauthenticated;
    notifyListeners();
  }
}
