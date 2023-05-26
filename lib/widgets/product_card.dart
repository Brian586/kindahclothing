import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/pages/product_details.dart';
import 'package:kindah/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  final Product? product;
  final bool isDesktop;

  const ProductCard({super.key, this.product, required this.isDesktop});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> favList = context.watch<ProductProvider>().favList;
    List<String> cartList = context.watch<ProductProvider>().cartList;
    bool isFav = favList.contains(widget.product!.id);
    bool isCart = cartList.contains(widget.product!.id);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: Image.network(
                    widget.product!.images![0],
                    width: widget.isDesktop ? size.width * 0.2 : size.width,
                    height: 800.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5.0,
                  left: 5.0,
                  child: IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: isFav ? Colors.pink : Config.customGrey,
                    ),
                    onPressed: () => context
                        .read<ProductProvider>()
                        .addRemoveProductFavourites(
                            product: widget.product, remove: isFav),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RatingBarIndicator(
                      rating: widget.product!.rating!["rate"].toDouble(),
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 12.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      "(${widget.product!.rating!["count"]})",
                      style: const TextStyle(
                          fontSize: 10.0, color: Config.customGrey),
                    )
                  ],
                ),
                Text(
                  widget.product!.category!,
                  style:
                      const TextStyle(fontSize: 12.0, color: Config.customGrey),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetails(
                                product: widget.product,
                              ))),
                  child: Text(
                    widget.product!.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.product!.currency!} ${widget.product!.price!}",
                      style: const TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => context
                          .read<ProductProvider>()
                          .addRemoveProductCart(
                              product: widget.product, remove: isCart),
                      icon: Icon(
                        isCart
                            ? Icons.shopping_cart
                            : Icons.add_shopping_cart_rounded,
                        color: isCart ? Colors.pink : Config.customGrey,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProductListCard extends StatefulWidget {
  final Product? product;
  const ProductListCard({super.key, this.product});

  @override
  State<ProductListCard> createState() => _ProductListCardState();
}

class _ProductListCardState extends State<ProductListCard> {
  Widget fetchImages(Size size) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("products")
          .doc(widget.product!.id)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          List<dynamic> images = snapshot.data!["images"];

          return Image.network(
            images[0],
            width: size.width * 0.3,
            height: 180.0,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> favList = context.watch<ProductProvider>().favList;
    List<String> cartList = context.watch<ProductProvider>().cartList;
    bool isFav = favList.contains(widget.product!.id);
    bool isCart = cartList.contains(widget.product!.id);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10.0)),
            child: widget.product!.images![0] == null
                ? fetchImages(size)
                : Image.network(
                    widget.product!.images![0],
                    width: size.width * 0.3,
                    height: 180.0,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetails(
                                  product: widget.product,
                                ))),
                    child: Text(
                      widget.product!.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    widget.product!.category!,
                    style: const TextStyle(
                        fontSize: 12.0, color: Config.customGrey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingBarIndicator(
                        rating: widget.product!.rating!["rate"].toDouble(),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        "(${widget.product!.rating!["count"]})",
                        style: const TextStyle(
                            fontSize: 10.0, color: Config.customGrey),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.product!.currency!} ${widget.product!.price!}",
                        style: const TextStyle(
                            color: Colors.pink, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: isFav ? Colors.pink : Config.customGrey,
                            ),
                            onPressed: () => context
                                .read<ProductProvider>()
                                .addRemoveProductFavourites(
                                    product: widget.product, remove: isFav),
                          ),
                          IconButton(
                            onPressed: () => context
                                .read<ProductProvider>()
                                .addRemoveProductCart(
                                    product: widget.product, remove: isCart),
                            icon: Icon(
                              isCart
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart_rounded,
                              color: isCart ? Colors.pink : Config.customGrey,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
