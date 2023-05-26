import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kindah/POS/models/pos_product.dart';
import 'package:kindah/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductProvider with ChangeNotifier {
  bool _showCards = true;
  List<String> _favList = [];
  List<String> _cartList = [];
  List<String> _posCartList = [];

  bool get showCards => _showCards;
  List<String> get favList => _favList;
  List<String> get cartList => _cartList;
  List<String> get posCartList => _posCartList;

  changeShowCards(bool value) {
    _showCards = value;

    notifyListeners();
  }

  Future<void> clearCartList() async {
    _cartList.clear();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("cart");
  }

  Future<void> clearPOSCartList() async {
    _posCartList.clear();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("POS_cart");
  }

  updateCartAndFavLists() async {
    _favList = [];
    _cartList = [];

    await getProductFavourites().then((favProducts) {
      for (Product favProd in favProducts) {
        _favList.add(favProd.id!);
      }
    });

    await getProductCart().then((cartProducts) {
      for (Product cartProd in cartProducts) {
        _cartList.add(cartProd.id!);
      }
    });

    notifyListeners();
  }

  Future<void> addRemovePOSProductCart(
      {POSProduct? product, bool? remove}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String cartsString = prefs.getString("POS_cart") ?? "";

    List<POSProduct> products = POSProduct.decode(cartsString);

    if (remove!) {
      products.remove(product);
      _posCartList.remove(product!.id);
    } else {
      products.add(product!);
      _posCartList.add(product.id!);
    }

    final String encodedData = POSProduct.encode(products);

    await prefs.setString("POS_cart", encodedData);

    notifyListeners();
  }

  Future<void> addRemoveProductCart({Product? product, bool? remove}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String cartsString = prefs.getString("cart") ?? "";

    List<Product> products = Product.decode(cartsString);

    if (remove!) {
      products.remove(product);
      _cartList.remove(product!.id);
    } else {
      products.add(product!);
      _cartList.add(product.id!);
    }

    final String encodedData = Product.encode(products);

    await prefs.setString("cart", encodedData);

    notifyListeners();
  }

  Future<void> addRemoveProductFavourites(
      {Product? product, bool? remove}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String favouritesString = prefs.getString("favourites") ?? "";

    List<Product> products = Product.decode(favouritesString);

    if (remove!) {
      products.remove(product);
      _favList.remove(product!.id);
    } else {
      products.add(product!);
      _favList.add(product.id!);
    }

    final String encodedData = Product.encode(products);

    await prefs.setString("favourites", encodedData);

    notifyListeners();
  }

  Future<List<Product>> getProductCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String cartsString = prefs.getString("cart") ?? "";

    List<Product> products =
        cartsString != "" ? Product.decode(cartsString) : [];

    return products;
  }

  Future<List<POSProduct>> getPOSProductCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String cartsString = prefs.getString("POS_cart") ?? "";

    List<POSProduct> products =
        cartsString != "" ? POSProduct.decode(cartsString) : [];

    return products;
  }

  Future<POSProduct> getPOSProductInCart(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String cartsString = prefs.getString("POS_cart") ?? "";

    List<POSProduct> products =
        cartsString != "" ? POSProduct.decode(cartsString) : [];

    return products.where((element) => element.id == id).toList()[0];
  }

  Future<List<Product>> getProductFavourites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String favouritesString = prefs.getString("favourites") ?? "";

    List<Product> products =
        favouritesString != "" ? Product.decode(favouritesString) : [];

    return products;
  }
}
