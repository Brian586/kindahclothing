import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../Ads/ad_state.dart';
import '../config.dart';
import '../models/product.dart';
import '../widgets/no_data.dart';
import '../widgets/product_card.dart';
import '../widgets/progress_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchKey = "";
  BannerAd? bannerAd;

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

  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
        appbarTitle: "Search Products",
        onBackPressed: () => context.go("/home"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Search for anything...",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .apply(color: Config.customGrey),
                    ),
                    const SizedBox()
                  ],
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Config.customGrey,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchKey = value;
                  });
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .where("searchKeys", arrayContains: searchKey.toLowerCase())
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
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(products.length, (index) {
                              Product product = products[index];

                              return ProductListCard(
                                product: product,
                              );
                            }),
                          ),
                          kIsWeb
                              ? const SizedBox(
                                  height: 0.0,
                                )
                              : bannerAd != null
                                  ? SizedBox(
                                      height: 50.0,
                                      child: AdWidget(ad: bannerAd!),
                                    )
                                  : const SizedBox(
                                      height: 0.0,
                                    )
                        ],
                      );
                    }
                  }
                },
              )
            ],
          ),
        ));
  }
}
