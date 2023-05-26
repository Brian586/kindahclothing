import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/APIs/request_assistant.dart';
import 'package:kindah/Ads/ad_state.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/widgets/ecomm_appbar.dart';
import 'package:kindah/widgets/product_card.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/category_button.dart';
import '../widgets/custom_footer.dart';
import '../widgets/no_data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    Provider.of<ProductProvider>(context, listen: false)
        .updateCartAndFavLists();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!kIsWeb) {
      final adState = Provider.of<AdState>(context);
      adState.initialization.then((status) {
        setState(() {
          bannerAd = BannerAd(
              size: AdSize.banner,
              adUnitId: adState.bannerAdUnitId,
              listener: adState.adListener,
              request: AdRequest())
            ..load();
        });
      });
    }
  }

  Widget favouritesCard(List<String> favList) {
    return InkWell(
      onTap: () => GoRouter.of(context).go("/favourites"),
      child: Card(
        color: Config.customBlue,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: SizedBox(
          height: 150.0,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favList.length.toString(),
                        style: Theme.of(context).textTheme.headlineSmall!.apply(
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "My Favourites",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .apply(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  "assets/images/favourites.png",
                  height: 150.0,
                  width: 120.0,
                  fit: BoxFit.contain,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMobile(
      bool showCards, List<String> favList, String selectedCategory) {
    bool isAll = selectedCategory == "All";
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            favList.isNotEmpty ? favouritesCard(favList) : const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Products",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(color: Config.customGrey),
                  ),
                  const SizedBox()
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: isAll
                  ? FirebaseFirestore.instance
                      .collection("products")
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("products")
                      .where("category", isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  List<Product> products = [];

                  snapshot.data!.docs.forEach((prod) {
                    Product product = Product.fromDocument(prod);

                    products.add(product);
                  });
                  if (products.isEmpty) {
                    return const NoData(
                      title: "No Products Available",
                    );
                  } else {
                    return showCards
                        ? GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2 / 3,
                            children: List.generate(products.length, (index) {
                              Product product = products[index];

                              return ProductCard(
                                product: product,
                                isDesktop: false,
                              );
                            }),
                          )
                        : ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(products.length, (index) {
                              Product product = products[index];

                              return ProductListCard(
                                product: product,
                              );
                            }),
                          );
                  }
                }
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            !kIsWeb
                ? const CustomFooter()
                : const SizedBox(
                    height: 0.0,
                  )
          ],
        ),
      ),
    );
  }

  Widget buildDesktop(
      bool showCards, String selectedCategory, List<String> favList) {
    bool isAll = selectedCategory == "All";
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Categories",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(color: Config.customGrey),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("categories")
                        .doc("categories")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text(
                          "Loading Categories",
                          style: TextStyle(color: Colors.black26),
                        );
                      } else {
                        List<dynamic> categories = snapshot.data!["cat"];

                        return Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 2.5,
                          runSpacing: 5.0,
                          children: List.generate(categories.length, (index) {
                            // bool isSelected =
                            //     categories[index] == selectedCategory;

                            return CategoryButton(
                              category: categories[index],
                              isAppbar: false,
                            );
                          }),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: StreamBuilder<QuerySnapshot>(
            stream: isAll
                ? FirebaseFirestore.instance.collection("products").snapshots()
                : FirebaseFirestore.instance
                    .collection("products")
                    .where("category", isEqualTo: selectedCategory)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Product> products = [];

                snapshot.data!.docs.forEach((prod) {
                  Product product = Product.fromDocument(prod);

                  products.add(product);
                });

                if (products.isEmpty) {
                  return const NoData(
                    title: "No Products Available",
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        favList.isNotEmpty
                            ? favouritesCard(favList)
                            : const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Products",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .apply(color: Config.customGrey),
                              ),
                              const SizedBox()
                            ],
                          ),
                        ),
                        showCards
                            ? GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2 / 3,
                                children:
                                    List.generate(products.length, (index) {
                                  Product product = products[index];

                                  return ProductCard(
                                    product: product,
                                    isDesktop: true,
                                  );
                                }),
                              )
                            : ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children:
                                    List.generate(products.length, (index) {
                                  Product product = products[index];

                                  return ProductListCard(
                                    product: product,
                                  );
                                }),
                              )
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool showCards = context.watch<ProductProvider>().showCards;
    String selectedCategory =
        context.watch<CategoryProvider>().selectedCategory;
    List<String> favList = context.watch<ProductProvider>().favList;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile =
            sizingInformation.isMobile || sizingInformation.isTablet;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize:
                Size(size.width, isMobile ? 160.0 : kTextTabBarHeight + 31.0),
            child: const ECommerceAppBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: isMobile
                    ? buildMobile(showCards, favList, selectedCategory)
                    : buildDesktop(showCards, selectedCategory, favList),
              ),
              kIsWeb
                  ? const CustomFooter()
                  : bannerAd != null
                      ? SizedBox(
                          height: 50.0,
                          child: AdWidget(ad: bannerAd!),
                        )
                      : const SizedBox(
                          height: 0.0,
                        )
            ],
          ),
        );
      },
    );
  }
}
