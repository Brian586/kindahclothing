import 'package:flutter/material.dart';

import '../../widgets/ecomm_appbar.dart';
import '../responsive.dart';
import 'custom_nav_bar.dart';

class POSAdaptiveUI extends StatefulWidget {
  final Widget body;
  final String userID;
  final void Function() onBackPressed;
  final String appbarTitle;
  final String currentTab;

  const POSAdaptiveUI({
    super.key,
    required this.userID,
    required this.onBackPressed,
    required this.appbarTitle,
    required this.currentTab,
    required this.body,
  });

  @override
  State<POSAdaptiveUI> createState() => _POSAdaptiveUIState();
}

class _POSAdaptiveUIState extends State<POSAdaptiveUI> {
  Widget buildBody(BuildContext context) {
    return widget.body;
  }

  Widget buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomNavBar(
            currentPage: widget.currentTab,
            userID: widget.userID,
          ),
        ),
        Expanded(
          flex: 9,
          child: Align(alignment: Alignment.topLeft, child: buildBody(context)),
        ),
        Expanded(
          flex: 4,
          child: Container(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(size.width, kToolbarHeight),
          child: EcommGeneralAppbar(
            onBackPressed: widget.onBackPressed,
            title: widget.appbarTitle,
          ),
        ),
        body: Responsive.isMobile(context)
            ? buildBody(context)
            : buildDesktop(context));
  }
}
