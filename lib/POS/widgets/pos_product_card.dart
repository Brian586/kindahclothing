import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config.dart';
import '../models/pos_product.dart';

class POSProductCard extends StatefulWidget {
  final POSProduct? product;
  final bool isDesktop;
  final String userID;

  const POSProductCard(
      {super.key, this.product, required this.isDesktop, required this.userID});

  @override
  State<POSProductCard> createState() => _POSProductCardState();
}

class _POSProductCardState extends State<POSProductCard> {
  bool isCart = false;
  @override
  void initState() {
    super.initState();
    checkIsCart();
  }

  Future<void> checkIsCart() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(widget.userID)
        .collection("cart")
        .doc(widget.product!.id)
        .get();

    setState(() {
      isCart = documentSnapshot.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // List<String> cartList = context.watch<ProductProvider>().posCartList;
    // bool isCart = cartList.contains(widget.product!.id);

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
                    widget.product!.image!,
                    height: 800.0,
                    width: widget.isDesktop ? size.width * 0.2 : size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     RatingBarIndicator(
                //       rating: widget.product!.rating!["rate"].toDouble(),
                //       itemBuilder: (context, index) => const Icon(
                //         Icons.star,
                //         color: Colors.amber,
                //       ),
                //       itemCount: 5,
                //       itemSize: 12.0,
                //       direction: Axis.horizontal,
                //     ),
                //     const SizedBox(
                //       width: 5.0,
                //     ),
                //     Text(
                //       "(${widget.product!.rating!["count"]})",
                //       style: const TextStyle(
                //           fontSize: 10.0, color: Config.customGrey),
                //     )
                //   ],
                // ),
                Text(
                  widget.product!.category!,
                  style:
                      const TextStyle(fontSize: 12.0, color: Config.customGrey),
                ),
                InkWell(
                  onTap: () {},
                  // onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ProductDetails(
                  //               product: widget.product,
                  //             ))),
                  child: Text(
                    widget.product!.name!,
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
                      "Ksh ${widget.product!.price!}",
                      style: const TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isCart) {
                          await FirebaseFirestore.instance
                              .collection("POS_users")
                              .doc(widget.userID)
                              .collection("cart")
                              .doc(widget.product!.id)
                              .delete();

                          setState(() {
                            isCart = false;
                          });

                          Fluttertoast.showToast(
                              msg: 'Item removed from cart successfully');
                        } else {
                          await FirebaseFirestore.instance
                              .collection("POS_users")
                              .doc(widget.userID)
                              .collection("cart")
                              .doc(widget.product!.id)
                              .set(widget.product!.toJson());

                          setState(() {
                            isCart = true;
                          });

                          Fluttertoast.showToast(
                              msg: 'Item added to cart successfully');
                        }
                      },
                      // onPressed: () => context
                      //     .read<ProductProvider>()
                      //     .addRemovePOSProductCart(
                      //         product: widget.product, remove: isCart),
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
