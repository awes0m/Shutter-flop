import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutter_flop/screens/products_overview_screen.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  //var _isLoading = false;
  late Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  // void initState() {
  //   _isLoading = true;
  //   Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     super.initState();
  //   });
  // }
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: const AppDrawer(),
        body: RefreshIndicator(
          onRefresh: _obtainOrdersFuture,
          child: FutureBuilder(
              // Using future builder to show loading screen
              future: _ordersFuture,
              builder: (ctx, dataSnapshot) {
                // print("building orders");
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (dataSnapshot.error != null) {
                  return AlertDialog(
                    title: const Text(
                      "An error occured\n Please try again later",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    content: Text(
                      "Error: ${dataSnapshot.error.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Okay'),
                        onPressed: () {
                          Navigator.of(ctx).pushReplacementNamed(
                              ProductsOverviewScreen.routename);
                        },
                      )
                    ],
                  );
                }
                if (dataSnapshot.connectionState == ConnectionState.done) {
                  return Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) =>
                          OrderItem(order: orderData.orders[i]),
                    ),
                  );
                }
                // ) _isLoading
                //   ? Center(child: CircularProgressIndicator())
                //   : ListView.builder(
                //       itemCount: orderData.orders.length,
                //       itemBuilder: (ctx, index) => OrderItem(
                //         order: orderData.orders[index],
                //       ),
                //     ),
                else {
                  return const Center(
                    child: Text('No orders yet'),
                  );
                }
              }),
        ));
  }
}
