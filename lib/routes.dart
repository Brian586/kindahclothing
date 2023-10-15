import 'package:go_router/go_router.dart';
import 'package:kindah/POS/pages/auth/login.dart';
import 'package:kindah/POS/pages/auth/signup.dart';
import 'package:kindah/POS/pages/invoice_listings.dart';
import 'package:kindah/POS/pages/pos_cart_page.dart';
import 'package:kindah/POS/pages/upload_page.dart';
import 'package:kindah/POS/point_of_sale.dart';
import 'package:kindah/admin/admin_panel.dart';
import 'package:kindah/main.dart';
import 'package:kindah/pages/auth.dart';
import 'package:kindah/pages/cart_screen.dart';
import 'package:kindah/pages/favourites_screen.dart';
import 'package:kindah/pages/home.dart';
import 'package:kindah/pages/paypal_success.dart';
import 'package:kindah/pages/privacy_policy.dart';
import 'package:kindah/pages/search_page.dart';
import 'package:kindah/user_panel/user_panel.dart';

import 'POS/pages/analytics_page.dart';
import 'POS/pages/pos_home.dart';
import 'POS/pages/pos_category_page.dart';
import 'POS/pages/pos_settings.dart';
import 'pages/admin_auth.dart';

class CustomRoutes {
  static final GoRouter router = GoRouter(routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: "/home",
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      path: "/staff",
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: "/admin_login",
      builder: (context, state) => const AdminAuth(),
    ),
    GoRoute(
      path: "/search",
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: "/privacy_policy",
      builder: (context, state) => const PrivacyPolicy(),
    ),
    // GoRoute(
    //   path: "/nfc_sender",
    //   builder: (context, state) => const NFCSender(),
    // ),
    GoRoute(
      path: "/favourites",
      builder: (context, state) => const FavouritesScreen(),
    ),
    GoRoute(
      path: "/cart",
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path:
          "/paypal_success/:contact_timestamp?paymentId=paymentId&token=token&PayerID=payerID",
      builder: (context, state) => PaypalSuccess(
        contact: state.params["contact_timestamp"]!.split("_").first,
        paymentID: state.queryParams["paymentId"]!,
        payerID: state.queryParams["PayerID"]!,
        timestamp: state.params["contact_timestamp"]!.split("_").last,
      ),
    ),
    GoRoute(
      path: "/POS",
      builder: (context, state) => const PointOfSale(),
    ),
    GoRoute(
      path: "/POS/login",
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: "/POS/signup",
      builder: (context, state) => const Signup(),
    ),
    GoRoute(
      path: "/POS/:userID/:currentTab",
      builder: (context, state) {
        switch (state.params['currentTab']) {
          case "home":
            return POSHome(userID: state.params['userID']!);
          case "cart":
            return POSCartPage(
              userID: state.params['userID']!,
              isDesktop: false,
            );
          case "analytics":
            return AnalyticsPage(
              userID: state.params['userID']!,
            );
          case "orders":
            return InvoiceListings(
              userID: state.params['userID']!,
            );
          case "upload":
            return POSUploadPage(
              userID: state.params['userID']!,
            );
          case "categories":
            return POSCategoryPage(
              userID: state.params['userID']!,
            );
          case "settings":
            return POSSettings(
              userID: state.params['userID']!,
            );
          default:
            return POSHome(userID: state.params['userID']!);
        }
      },
    ),
    GoRoute(
      path: "/admin/:userID/:currentTab",
      builder: (context, state) => AdminPanel(
        currentTab: state.params['currentTab'],
        userID: state.params['userID'],
      ),
    ),
    GoRoute(
      path: "/users/:userRole/:userID/:currentTab",
      builder: (context, state) => UserPanel(
        userID: state.params['userID'],
        userRole: state.params['userRole']!
            .substring(0, state.params['userRole']!.length - 1),
        currentTab: state.params['currentTab'] == "home"
            ? "dashboard"
            : state.params['currentTab'],
      ),
    )
  ]);
}
