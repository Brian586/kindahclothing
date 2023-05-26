import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../providers/category_provider.dart';

class CategoryButton extends StatelessWidget {
  final String? category;
  final bool? isAppbar;
  const CategoryButton({super.key, this.category, this.isAppbar});

  Color containerFillColor(bool isSelected) {
    if (isAppbar!) {
      return isSelected ? Colors.white : Colors.white30;
    } else {
      return isSelected ? Config.customBlue : Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedCategory =
        context.watch<CategoryProvider>().selectedCategory;
    bool isSelected = category == selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: InkWell(
        onTap: () =>
            context.read<CategoryProvider>().changeSelectedCategory(category!),
        child: Container(
          height: 30.0,
          decoration: BoxDecoration(
            color: containerFillColor(isSelected),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color:
                  isAppbar! ? Colors.white : Config.customGrey.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: isAppbar!
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      category!,
                      style: TextStyle(
                          color: isSelected ? Config.customBlue : Colors.white),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: Text(
                    category!,
                    style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Config.customGrey.withOpacity(0.5)),
                  ),
                ),
        ),
      ),
    );
  }
}
