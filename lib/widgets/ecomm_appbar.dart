import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/providers/category_provider.dart';
import 'package:kindah/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'category_button.dart';

class ECommerceAppBar extends StatefulWidget {
  const ECommerceAppBar({super.key});

  @override
  State<ECommerceAppBar> createState() => _ECommerceAppBarState();
}

class _ECommerceAppBarState extends State<ECommerceAppBar> {
  Widget buildCategories(BuildContext context, String selectedCategory) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("categories")
          .doc("categories")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
            "Loading Categories",
            style: TextStyle(color: Colors.white54),
          );
        } else {
          List<dynamic> categories = snapshot.data!["cat"];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(categories.length, (index) {
                // bool isSelected = categories[index] == selectedCategory;

                return CategoryButton(
                  category: categories[index],
                  isAppbar: true,
                );
              }),
            ),
          );
        }
      },
    );
  }

  Widget searchBar(Size size) {
    return Container(
      height: 34.0,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(17.0),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
            onPressed: () => GoRouter.of(context).go("/search"),
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            label: const Text(
              "Type something...",
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget buildActions(BuildContext context, List<String> cartList) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        kIsWeb
            ? const SizedBox(
                height: 0.0,
                width: 0.0,
              )
            : const SizedBox(
                height: 0.0,
                width: 0.0,
              ),
        // : TextButton.icon(
        //     onPressed: () => GoRouter.of(context).go("/nfc_sender"),
        //     icon: const Icon(
        //       Icons.wifi_tethering,
        //       color: Colors.white60,
        //     ),
        //     label: const Text(
        //       "NFC",
        //       style: TextStyle(color: Colors.white60),
        //     ),
        //   ),
        Stack(
          children: [
            IconButton(
                onPressed: () => GoRouter.of(context).go("/cart"),
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white60,
                )),
            Positioned(
              top: 5.0,
              right: 0.0,
              child: cartList.isEmpty
                  ? const SizedBox()
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(7.0)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            cartList.length.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10.0),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
        IconButton(
            onPressed: () => GoRouter.of(context).go("/authentication"),
            icon: const Icon(
              Icons.person,
              color: Colors.white60,
            )),
      ],
    );
  }

  Widget title() {
    return const Text(
      Config.appName,
      style: TextStyle(
          color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
    );
  }

  Widget posBtn() {
    return TextButton.icon(
        onPressed: () => GoRouter.of(context).go("/POS"),
        icon: const Icon(
          Icons.point_of_sale,
          color: Colors.white,
        ),
        label: const Text(
          "POS",
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget buildDesktop(BuildContext context, Size size, bool showCards,
      String selectedCategory, List<String> cartList) {
    return AppBar(
      title: title(),
      elevation: 0.0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: Config.diagonalGradient),
      ),
      actions: [
        posBtn(),
        SizedBox(
            width: size.width * 0.2,
            height: 34.0,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: searchBar(size),
            )),
        buildActions(context, cartList)
      ],
      bottom: PreferredSize(
        preferredSize: Size(size.width, 60.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: buildCategories(context, selectedCategory),
          ),
        ),
      ),
    );
  }

  Widget buildMobile(BuildContext context, Size size, bool showCards,
      String selectedCategory, List<String> cartList) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        kIsWeb
            ? Container()
            : const SizedBox(
                height: 20.0,
              ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [title(), buildActions(context, cartList)],
          ),
        ),
        buildCategories(context, selectedCategory),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              posBtn(),
              Expanded(
                child: searchBar(size),
              ),
              IconButton(
                  onPressed: () {
                    if (showCards) {
                      context.read<ProductProvider>().changeShowCards(false);
                    } else {
                      context.read<ProductProvider>().changeShowCards(true);
                    }
                  },
                  icon: Icon(
                    showCards ? Icons.list : Icons.grid_view_outlined,
                    color: Colors.white,
                  ))
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String selectedCategory =
        context.watch<CategoryProvider>().selectedCategory;
    bool showCards = context.watch<ProductProvider>().showCards;
    List<String> cartList = context.watch<ProductProvider>().cartList;

    return Container(
      width: size.width,
      decoration:
          const BoxDecoration(gradient: Config.horizontalGradient, boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            spreadRadius: 6.0,
            offset: Offset(4.0, 0.0))
      ]),
      child: ScreenTypeLayout.builder(
        mobile: (context) =>
            buildMobile(context, size, showCards, selectedCategory, cartList),
        desktop: (context) =>
            buildDesktop(context, size, showCards, selectedCategory, cartList),
        tablet: (context) =>
            buildMobile(context, size, showCards, selectedCategory, cartList),
      ),
    );
  }
}

class EcommGeneralAppbar extends StatelessWidget {
  final void Function()? onBackPressed;
  final String? title;
  const EcommGeneralAppbar({super.key, this.onBackPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: Config.diagonalGradient),
      ),
      leading: IconButton(
        onPressed: onBackPressed,
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
      title: Text(title!),
    );
  }
}
