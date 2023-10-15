import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../providers/product_provider.dart';

class ProductDetails extends StatefulWidget {
  final Product? product;
  const ProductDetails({super.key, this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  CarouselController _carouselController = CarouselController();
  int currentIndex = 0;
  TextEditingController quantityController = TextEditingController();
  int quantityValue = 1;

  @override
  void initState() {
    super.initState();
    quantityController.text = quantityValue.toString();
  }

  void onPageChanged(index, reason) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget fetchImagesAndDisplay(Size size) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("products")
          .doc(widget.product!.id)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<dynamic> imageUrls =
              Product.fromDocument(snapshot.data!).images!;

          return displayImages(size, imageUrls);
        }
      },
    );
  }

  Widget displayImages(Size size, List<dynamic> imageUrls) {
    return Stack(
      children: [
        CarouselSlider(
            items: List.generate(imageUrls.length, (index) {
              return Image.network(
                imageUrls[index],
                width: size.width,
                height: 300.0,
                fit: BoxFit.contain,
              );
            }),
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 300.0,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: false,
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: onPageChanged,
              scrollDirection: Axis.horizontal,
            )),
        Positioned(
          bottom: 10.0,
          right: 10.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.black26,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => _carouselController.previousPage(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn),
                  ),
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.black26,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => _carouselController.nextPage(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget quantityTextField() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantityValue > 1
              ? () {
                  setState(() {
                    quantityValue--;
                    quantityController.text = quantityValue.toString();
                  });

                  print(quantityValue);
                }
              : null,
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 70.0,
          child: TextField(
            controller: quantityController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
            onChanged: (text) {
              setState(() {
                quantityValue = int.parse(text);
              });
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              quantityValue++;
              quantityController.text = quantityValue.toString();
            });
            print(quantityValue);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> favList = context.watch<ProductProvider>().favList;
    List<String> cartList = context.watch<ProductProvider>().cartList;
    bool isFav = favList.contains(widget.product!.id);
    bool isCart = cartList.contains(widget.product!.id);

    return EcommAdaptiveUI(
      appbarTitle: "Product Details",
      onBackPressed: () => Navigator.pop(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: widget.product!.images![0] == null
                ? fetchImagesAndDisplay(size)
                : displayImages(size, widget.product!.images!),
          ),
          const SizedBox(
            height: 20.0,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.product!.title!,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              widget.product!.category!,
              style: const TextStyle(fontSize: 12.0),
            ),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isFav ? Colors.pink : Config.customGrey,
              ),
              onPressed: () => context
                  .read<ProductProvider>()
                  .addRemoveProductFavourites(
                      product: widget.product, remove: isFav),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            "Description",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .apply(color: Config.customBlue),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(widget.product!.description!),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            "${widget.product!.currency!} ${widget.product!.price}",
            style: const TextStyle(
                color: Colors.pink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              quantityTextField(),
              CustomButton(
                onPressed: () {
                  if (quantityValue > 0) {
                    Product product = Product(
                        id: widget.product!.id,
                        title: widget.product!.title,
                        currency: widget.product!.currency,
                        price: widget.product!.price,
                        description: widget.product!.description,
                        category: widget.product!.category,
                        images: widget.product!.images,
                        publisher: widget.product!.publisher,
                        searchKeys: widget.product!.searchKeys,
                        quantity: quantityValue,
                        rating: widget.product!.rating,
                        timestamp: widget.product!.timestamp);

                    context
                        .read<ProductProvider>()
                        .addRemoveProductCart(product: product, remove: isCart);
                  }
                },
                title: isCart ? "Remove From Cart" : "Add To Cart",
                iconData: Icons.shopping_bag_rounded,
              )
            ],
          )
        ],
      ),
    );
  }
}
