import 'package:flutter/material.dart';
import 'package:kindah/config.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';

class POSCategoryButton extends StatelessWidget {
  final String? category;
  const POSCategoryButton({
    super.key,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    String selectedCategory =
        context.watch<CategoryProvider>().selectedPOSCategory;
    bool isSelected = category == selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: InkWell(
        onTap: () => context
            .read<CategoryProvider>()
            .changePOSSelectedCategory(category!),
        child: Container(
            height: 30.0,
            decoration: BoxDecoration(
              gradient: isSelected ? Config.diagonalGradient : null,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Config.customGrey.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  category!,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Config.customGrey),
                ),
              ),
            )),
      ),
    );
  }
}
