import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutter_flop/providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import 'carts_screen.dart';

enum FilterOptions {
  favourites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      _isLoading = true;
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
        _isInit = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mu Shop"),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
            ),
            onSelected: (FilterOptions selectedValue) => [
              setState(() {
                if (selectedValue == FilterOptions.favourites) {
                  _showOnlyFavourites = true;
                } else {
                  _showOnlyFavourites = false;
                }
              })
            ],
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text("Only Favourites"),
                value: FilterOptions.favourites,
              ),
              const PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.all,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch as Widget,
              value: cart.itemCount.toString(),
              color: Colors.teal,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}
