import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  Future<void> _launchUrl(String link) async {
    if (!await launchUrl(Uri.parse(link))) {
      throw Exception('Could not launch $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      color: Config.customBlue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("\u00a9 Kindah Store. All Rights Reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Config.customGrey, fontSize: 13.0)),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => context.go("/privacy_policy"),
                  child: const Text("Privacy Policy | ",
                      style:
                          TextStyle(fontSize: 11.0, color: Config.customGrey)),
                ),
                InkWell(
                  onTap: () => _launchUrl("https://www.freepik.com/"),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Vectors from ',
                            style: TextStyle(
                                fontSize: 11.0, color: Config.customGrey)),
                        TextSpan(
                            text: "Freepik",
                            style: TextStyle(
                                fontSize: 11.0, color: Config.customBlue)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
