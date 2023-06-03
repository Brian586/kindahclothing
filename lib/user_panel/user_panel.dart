// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/admin_appbar.dart';
import 'package:kindah/fabric_cutter/fabric_cutter.dart';
import 'package:kindah/finisher/finisher.dart';
import 'package:kindah/pages/user_settings.dart';
import 'package:kindah/shop_attendant/shop_attendant.dart';
import 'package:kindah/tailor/tailor.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../admin/pages/add_order.dart';
import '../admin/pages/add_products.dart';
import '../admin/pages/add_schools.dart';
import '../admin/pages/add_uniforms.dart';
import '../admin/pages/add_users.dart';
import '../admin/pages/advance_payments_listing.dart';
import '../admin/pages/edit_order.dart';
import '../admin/pages/edit_products.dart';
import '../admin/pages/edit_schools.dart';
import '../admin/pages/edit_uniforms.dart';
import '../admin/pages/edit_users.dart';
import '../admin/pages/inventory.dart';
import '../admin/pages/my_tariffs.dart';
import '../admin/pages/order_status.dart';
import '../admin/pages/orders_listing.dart';
import '../admin/pages/payments_listing.dart';
import '../admin/pages/product_categories.dart';
import '../admin/pages/products_listing.dart';
import '../admin/pages/schools_listing.dart';
import '../admin/pages/uniforms_listing.dart';
import '../admin/pages/users_listing.dart';
import '../models/account.dart';
import '../pages/user_intro.dart';
import '../providers/account_provider.dart';
import '../widgets/progress_widget.dart';
import 'widgets/user_panel_appbar.dart';
import 'widgets/user_panel_drawer.dart';

class UserPanel extends StatefulWidget {
  final String? currentTab;
  final String? userID;
  final String? userRole;
  const UserPanel({super.key, this.userID, this.currentTab, this.userRole});

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();

    getAccountInfo();
  }

  void getAccountInfo() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .get();

    Account account = Account.fromDocument(documentSnapshot);

    if (account.isNew!) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserIntro(
                    userType: account.userRole!,
                  )));

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userID)
          .update({"isNew": false});
    }

    Provider.of<AccountProvider>(context, listen: false).changeAccount(account);

    setState(() {
      loading = false;
    });
  }

  Widget getDash() {
    switch (widget.userRole) {
      case "shop_attendants":
        return const ShopAttendant();
      case "fabric_cutters":
        return const FabricCutter();
      case "tailors":
        return const Tailor();
      case "finishers":
        return const Finisher();
      default:
        return Container();
    }
  }

  Widget buildUserBody() {
    switch (widget.currentTab) {
      case "dashboard":
        return getDash();

      // USERS
      case "add_users":
        return const AddUsers(
          isAdmin: false,
        );
      case "edit_users":
        return const EditUsers(
          isAdmin: false,
        );
      case "users":
        return const UsersListing(
          isAdmin: false,
        );

      // ECOMMERCE PRODUCTS
      case "products":
        return const ProductsListing(
          isAdmin: false,
        );
      case "add_products":
        return const AddProducts(
          isAdmin: false,
        );
      case "edit_products":
        return const EditProducts(
          isAdmin: false,
        );
      case "product_categories":
        return const ProductCategories(
          isAdmin: false,
        );

      // SCHOOLS
      case "schools":
        return const SchoolsListing(
          isAdmin: false,
        );
      case "add_schools":
        return const AddSchools(
          isAdmin: false,
        );
      case "edit_schools":
        return const EditSchools(
          isAdmin: false,
        );

      // UNIFORMS
      case "add_uniforms":
        return const AddUniforms(
          isAdmin: false,
        );
      case "edit_uniforms":
        return const EditUniforms(
          isAdmin: false,
        );
      case "uniforms":
        return const UniformsListing(
          isAdmin: false,
        );

      // ORDERS
      case "orders":
        return const OrdersListing(
          isAdmin: false,
        );
      case "order_status":
        return const OrderStatus(
          isAdmin: false,
        );
      case "add_order":
        return const AddOrder(
          isAdmin: false,
        );
      case "edit_orders":
        return const EditOrder(
          isAdmin: false,
        );

      // PAYMENTS
      case "payments":
        return const PaymentsListing(
          isAdmin: false,
        );
      case "advance_payments":
        return const AdvancePaymentsListing(
          isAdmin: false,
        );

      // OTHERS
      case "my_tariffs":
        return const MyTariffs(
          isAdmin: false,
        );
      case "inventory":
        return const Inventory(
          isAdmin: false,
        );
      case "settings":
        return const UserSettings();
      default:
        return getDash();
    }
  }

  Widget buildMobile(BuildContext context, Size size) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const UserPanelDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(size.width, kToolbarHeight),
        child: UserPanelAppbar(
          isMobile: true,
          scaffoldKey: scaffoldKey,
        ),
      ),
      body: buildUserBody(),
    );
  }

  Widget buildDesktop(BuildContext context, Size size) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(size.width, kToolbarHeight),
        child: UserPanelAppbar(
          isMobile: false,
          scaffoldKey: scaffoldKey,
        ),
      ),
      body: Row(
        children: [
          const Expanded(
            flex: 1,
            child: UserPanelDrawer(),
          ),
          Expanded(
            flex: 4,
            child: Align(alignment: Alignment.topLeft, child: buildUserBody()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return loading
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: circularProgress(),
            ),
          )
        : ScreenTypeLayout.builder(
            desktop: (context) => buildDesktop(context, size),
            tablet: (context) => buildMobile(context, size),
            mobile: (context) => buildMobile(context, size),
            watch: (p0) => Container(),
          );
  }
}
