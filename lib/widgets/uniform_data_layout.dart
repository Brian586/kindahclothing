import 'package:flutter/material.dart';
import 'package:kindah/models/uniform.dart';

import '../common_functions/color_functions.dart';
import '../config.dart';

class UniformDataLayout extends StatelessWidget {
  final Uniform? uniform;
  final int? index;
  const UniformDataLayout({super.key, this.uniform, this.index});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("${index! + 1}. ${uniform!.name!}"),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Unit Price: Ksh ${uniform!.unitPrice}",
              style: const TextStyle(color: Config.customGrey),
            ),
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                      text: 'Quantity: ',
                      style: TextStyle(color: Config.customGrey)),
                  TextSpan(
                      text: uniform!.quantity.toString(),
                      style: const TextStyle(
                          color: Config.customGrey,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                      text: 'Size: ',
                      style: TextStyle(color: Config.customGrey)),
                  TextSpan(
                      text: sizeMatcher(uniform!.size!),
                      style: const TextStyle(
                          color: Config.customGrey,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Color: ',
                    style: TextStyle(color: Config.customGrey)),
                Container(
                  height: 20.0,
                  width: 20.0,
                  color: hexToColor(uniform!.color!),
                ),
                const SizedBox(width: 10.0),
                Text(
                  findColorName(uniform!.color!),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Image.network(
              uniform!.imageUrl!,
              height: 300.0,
              width: size.width,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 5.0,
            ),
            const Text(
              "Measurements",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              width: size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Config.customGrey, width: 0.5)),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      List.generate(uniform!.measurements!.length, (index) {
                    UniformMeasurement measurement = uniform!.measurements!
                        .map(
                          (e) => UniformMeasurement.fromJson(e),
                        )
                        .toList()[index];
                    return RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: measurement.name!,
                              style: const TextStyle(color: Config.customGrey)),
                          TextSpan(
                              text: " (${measurement.symbol}): ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Config.customGrey)),
                          TextSpan(
                              text: measurement.measurement.toString(),
                              style: const TextStyle(
                                  color: Config.customGrey,
                                  fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: " ${measurement.units!}",
                              style: const TextStyle(color: Config.customGrey)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
