import 'package:flutter/material.dart';
import 'package:kindah/config.dart';

class CustomButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final VoidCallback? onPressed;
  final String? title;
  final IconData? iconData;

  const CustomButton({
    Key? key,
    this.onPressed,
    this.title,
    this.iconData,
    this.borderRadius,
    this.width,
    this.height = 44.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(22);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: Config.diagonalGradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: Colors.white,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        label: Text(
          title!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class TransparentButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? title;
  const TransparentButton({super.key, this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          InkWell(
            onTap: onPressed,
            child: Container(
              height: 30.0,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    title!,
                    style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
