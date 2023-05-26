import 'package:flutter/material.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/ecomm_appbar.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'user_appbar.dart';

class AdaptiveUI extends StatelessWidget {
  final Widget? appbarLeading;
  final String? appbarTitle;
  final String? appbarSubtitle;
  final Widget? body;
  const AdaptiveUI(
      {super.key,
      this.appbarLeading,
      this.appbarTitle,
      this.body,
      this.appbarSubtitle = ""});

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: CustomWrapper(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: body,
        ),
      ),
    );
  }

  Widget buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 4,
          child: Align(alignment: Alignment.topLeft, child: buildBody(context)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(size.width, kToolbarHeight),
            child: UserAppbar(
              isMobile: isMobile,
              leading: appbarLeading,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appbarTitle!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    appbarSubtitle!,
                    style:
                        const TextStyle(fontSize: 13.0, color: Colors.white60),
                  )
                ],
              ),
            ),
          ),
          body: isMobile ? buildBody(context) : buildDesktop(context),
        );
      },
    );
  }
}

class EcommAdaptiveUI extends StatelessWidget {
  final void Function()? onBackPressed;
  final String? appbarTitle;
  final Widget? body;
  const EcommAdaptiveUI(
      {super.key, this.appbarTitle, this.body, this.onBackPressed});

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: CustomWrapper(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: body,
        ),
      ),
    );
  }

  Widget buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 4,
          child: Align(alignment: Alignment.topLeft, child: buildBody(context)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile =
            sizingInformation.isMobile || sizingInformation.isTablet;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(size.width, kToolbarHeight),
            child: EcommGeneralAppbar(
              onBackPressed: onBackPressed,
              title: appbarTitle,
            ),
          ),
          body: isMobile ? buildBody(context) : buildDesktop(context),
        );
      },
    );
  }
}
