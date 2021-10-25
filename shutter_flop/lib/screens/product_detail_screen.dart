import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutter_flop/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  //final String title;
  //const ProductDetailScreen(this.title);
  static const routeName = '/product-detail';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
