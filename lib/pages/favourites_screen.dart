import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/providers/product_provider.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../widgets/product_card.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
      appbarTitle: "Favourites",
      onBackPressed: () => context.go("/home"),
      body: FutureBuilder<List<Product>>(
        future: ProductProvider().getProductFavourites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            List<Product> products = snapshot.data!;

            return ListView(
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
        },
      ),
    );
  }
}
