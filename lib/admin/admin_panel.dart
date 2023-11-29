import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/pages/add_products.dart';
import 'package:kindah/admin/pages/add_schools.dart';
import 'package:kindah/admin/pages/add_users.dart';
import 'package:kindah/admin/pages/admin_settings.dart';
import 'package:kindah/admin/pages/advance_payments_listing.dart';
import 'package:kindah/admin/pages/dashboard.dart';
import 'package:kindah/admin/pages/inventory.dart';
import 'package:kindah/admin/pages/my_tariffs.dart';
import 'package:kindah/admin/pages/notifications.dart';
import 'package:kindah/admin/pages/orders_listing.dart';
import 'package:kindah/admin/pages/payments_listing.dart';
import 'package:kindah/admin/pages/product_categories.dart';
import 'package:kindah/admin/pages/products_listing.dart';
import 'package:kindah/admin/pages/schools_listing.dart';
import 'package:kindah/admin/pages/users_listing.dart';
import 'package:kindah/admin/widgets/admin_appbar.dart';
import 'package:kindah/admin/widgets/custom_drawer.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../common_functions/custom_toast.dart';
import '../common_functions/messaging_functions.dart';
import '../dialog/error_dialog.dart';
import 'pages/add_order.dart';
import 'pages/add_uniforms.dart';
import 'pages/edit_order.dart';
import 'pages/edit_products.dart';
import 'pages/edit_schools.dart';
import 'pages/edit_uniforms.dart';
import 'pages/edit_users.dart';
import 'pages/order_status.dart';
import 'pages/uniforms_listing.dart';

class AdminPanel extends StatefulWidget {
  final String? currentTab;
  final String? userID;
  const AdminPanel({super.key, this.currentTab, this.userID});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    getAdminInfo();
  }

  void getAdminInfo() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("admins")
        .doc(widget.userID)
        .get();

    Admin admin = Admin.fromDocument(documentSnapshot);

    Provider.of<AdminProvider>(context, listen: false).changeAdmin(admin);

    // getDeviceToken(admin);

    setState(() {
      loading = false;
    });
  }

  void getDeviceToken(Admin admin) async {
    try {
      String deviceToken = await getToken();

      print(deviceToken);

      if (!admin.devices!.contains(deviceToken)) {
        await FirebaseFirestore.instance
            .collection("admins")
            .doc("0001")
            .update({
          "devices": FieldValue.arrayUnion([deviceToken])
        });
      }
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      showCustomToast("An ERROR Occured :(");
    }
  }

  Widget buildAdminBody() {
    switch (widget.currentTab) {
      case "dashboard":
        return const Dashboard();

      // USERS
      case "add_users":
        return const AddUsers(
          isAdmin: true,
        );
      case "edit_users":
        return const EditUsers(
          isAdmin: true,
        );
      case "users":
        return const UsersListing(
          isAdmin: true,
        );

      // ECOMMERCE PRODUCTS
      case "products":
        return const ProductsListing(
          isAdmin: true,
        );
      case "add_products":
        return const AddProducts(
          isAdmin: true,
        );
      case "edit_products":
        return const EditProducts(
          isAdmin: true,
        );
      case "product_categories":
        return const ProductCategories(
          isAdmin: true,
        );

      // SCHOOLS
      case "schools":
        return const SchoolsListing(
          isAdmin: true,
        );
      case "add_schools":
        return const AddSchools(
          isAdmin: true,
        );
      case "edit_schools":
        return const EditSchools(
          isAdmin: true,
        );

      // UNIFORMS
      case "add_uniforms":
        return const AddUniforms(
          isAdmin: true,
        );
      case "edit_uniforms":
        return const EditUniforms(
          isAdmin: true,
        );
      case "uniforms":
        return const UniformsListing(
          isAdmin: true,
        );

      // ORDERS
      case "orders":
        return const OrdersListing(
          isAdmin: true,
        );
      case "order_status":
        return const OrderStatus(
          isAdmin: true,
        );
      case "add_order":
        return const AddOrder(
          isAdmin: true,
          userID: "",
          userMap: {},
        );
      case "edit_orders":
        return const EditOrder(
          isAdmin: true,
        );

      // PAYMENTS
      case "payments":
        return const PaymentsListing(
          isAdmin: true,
        );
      case "advance_payments":
        return const AdvancePaymentsListing(
          isAdmin: true,
        );

      // OTHERS
      case "my_tariffs":
        return const MyTariffs(
          isAdmin: true,
        );
      case "inventory":
        return const Inventory(
          isAdmin: true,
        );
      case "settings":
        return const AdminSettings();
      case "notifications":
        return const AdminNotifications();
      default:
        return const Dashboard();
    }
  }

  Widget buildMobile(BuildContext context, Size size) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(size.width, kToolbarHeight),
        child: AdminAppBar(
          isMobile: true,
          scaffoldKey: scaffoldKey,
        ),
      ),
      body: buildAdminBody(),
    );
  }

  Widget buildDesktop(BuildContext context, Size size) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(size.width, kToolbarHeight),
        child: AdminAppBar(
          isMobile: false,
          scaffoldKey: scaffoldKey,
        ),
      ),
      body: Row(
        children: [
          const Expanded(
            flex: 1,
            child: CustomDrawer(),
          ),
          Expanded(
            flex: 4,
            child: Align(alignment: Alignment.topLeft, child: buildAdminBody()),
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
