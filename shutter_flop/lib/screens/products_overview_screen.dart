import 'package:flutter/material.dart';

import '../widgets/products_grid.dart';
import '../models/product.dart';

class ProductsOverviewScreen extends StatelessWidget {
  final List<Product> loadedProducts = [];

  ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mu Shop"),
      ),
      body: ProductsGrid(),
    );
  }
}
