import 'package:flutter/material.dart';
import 'package:kindah/config.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CustomHeader extends StatelessWidget {
  final List<Widget>? action;
  final String? customTitle;
  const CustomHeader({super.key, this.action, this.customTitle});

  @override
  Widget build(BuildContext context) {
    String currentTab = context.watch<AdminProvider>().selectedDrawerItem;
    Size size = MediaQuery.of(context).size;

    String title = currentTab.split("_").join(" ").toTitleCase();

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isMobile
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            customTitle == null ? title : customTitle!,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .apply(
                                    color: Config.customGrey,
                                    overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: action!,
                          ),
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .apply(
                                  color: Config.customGrey,
                                  overflow: TextOverflow.ellipsis),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: action!,
                        )
                      ],
                    ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                height: 1.0,
                color: Colors.black12,
                width: size.width,
              )
            ],
          ),
        );
      },
    );
  }
}
