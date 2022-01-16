import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

import '../providers/product.dart';
//provides a form for user to add or edit new produts in the shop database

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocousNode = FocusNode();
  final _form = GlobalKey<
      FormState>(); //used to control the form elements individuallty while saving the data
  var _editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocousNode.addListener(_updateImageUrl);
    super.initState();
  }

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocousNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocousNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveform() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != '') {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error occured'),
                  content: Text(error.toString()),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Okay'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              //save the product
              _saveform();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(
                        hintText: 'enter the preffered name for product',
                        labelText: "Product Title",
                      ),
                      textInputAction: TextInputAction
                          .next, //Switches to next folrm element on pressing enter
                      onFieldSubmitted: (value) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value as String,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          isFavourite: _editedProduct.isFavourite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(
                        hintText: 'Price for product',
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction
                          .next, //Switches to next folrm element on pressing enter
                      keyboardType:
                          TextInputType.number, //Brings up a num keypad
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: double.parse(value as String),
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          isFavourite: _editedProduct.isFavourite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: const InputDecoration(
                        hintText: 'Description for product',
                        labelText: "Desceiption",
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType
                          .multiline, //Brings up a multiline keyboard with enter key
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Description';
                        }
                        if (value.length < 10) {
                          return 'Please enter atleast 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value as String,
                          imageUrl: _editedProduct.imageUrl,
                          isFavourite: _editedProduct.isFavourite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocousNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) => _saveform(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an Image URL';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid URL';
                              }
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value as String,
                                isFavourite: _editedProduct.isFavourite,
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ])),
            ),
    );
  }
}
