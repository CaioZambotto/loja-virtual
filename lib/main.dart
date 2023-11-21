import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual/models/admin_orders_manager.dart';
import 'package:loja_virtual/models/admin_users_manager.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/models/orders_manager.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/product_manager.dart';
import 'package:loja_virtual/models/stores_manager.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/screens/address/address_screen.dart';
import 'package:loja_virtual/screens/cart/cart_screen.dart';
import 'package:loja_virtual/screens/checkout/checkout_screen.dart';
import 'package:loja_virtual/screens/confirmation/confirmation_screen.dart';
import 'package:loja_virtual/screens/edit_product/edit_product_screen.dart';
import 'package:loja_virtual/screens/login/login_screen.dart';
import 'package:loja_virtual/screens/product_consult/product_consult_screen.dart';
import 'package:loja_virtual/screens/select_product/select_product_screen.dart';
import 'package:loja_virtual/screens/signup/signup_screen.dart';
import 'package:provider/provider.dart';
import 'screens/base/base_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserManager(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => ProductManager(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => HomeManager(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => StoresManager(),
        ),
        ChangeNotifierProxyProvider<UserManager, CartManager>(
          create: (_) => CartManager(),
          lazy: false,
          update: (_, userManager, cartManager) =>
          cartManager!..updateUser(userManager),
        ),
        ChangeNotifierProxyProvider<UserManager, AdminUsersManager>(
          create: (_) => AdminUsersManager(),
          lazy: false,
          update: (_, userManager, adminUsersManager) =>
          adminUsersManager!..updateUser(userManager),
        ),
        ChangeNotifierProxyProvider<UserManager, OrdersManager>(
          create: (_) => OrdersManager(),
          lazy: false,
          update: (_, userManager, ordersManager) =>
          ordersManager!..updateUser(userManager.appUser as Users),
        ),
        ChangeNotifierProxyProvider<UserManager, AdminOrdersManager>(
          create: (_) => AdminOrdersManager(),
          lazy: false,
          update: (_, userManager, adminOrdersManager) =>
          adminOrdersManager!..updateAdmin(
              adminEnabled: userManager.adminEnabled
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Loja do Caio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.teal,
          appBarTheme: const AppBarTheme(
              elevation: 0
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        onGenerateRoute: (settings){
          switch(settings.name){
            case '/confirmation':
              return MaterialPageRoute(
                  builder: (_) => ConfirmationScreen(
                      settings.arguments as Orders
                  )
              );
            case '/checkout':
              return MaterialPageRoute(
                  builder: (_) => CheckoutScreen()
              );
            case '/address':
              return MaterialPageRoute(
                  builder: (_) => AddressScreen()
              );
            case '/edit_product':
              return MaterialPageRoute(
                  builder: (_) => EditProductScreen(
                    settings.arguments as Product
                  )
            );
            case '/select_product':
              return MaterialPageRoute(
                  builder: (_) => SelectProductScreen()
            );
            case '/login':
              return MaterialPageRoute(
                  builder: (_) => LoginScreen()
            );
            case '/signup':
              return MaterialPageRoute(
                  builder: (_) => SignUpScreen()
            );
            case '/product':
              return MaterialPageRoute(
                  builder: (_) => ProductScreen(
                    settings.arguments as Product
                  )
            );
            case '/cart':
              return MaterialPageRoute(
                  builder: (_) => CartScreen(),
                  settings: settings
            );
            case '/':
            default:
              return MaterialPageRoute(
                  builder: (_) => BaseScreen(),
                  settings: settings
            );
          }
        },
      ),
    );
  }
}
