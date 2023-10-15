import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/widgets/no_data.dart';
import 'package:provider/provider.dart';

import '../Ads/ad_state.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../user_panel/widgets/user_custom_header.dart';
import '../widgets/custom_scrollbar.dart';
import '../widgets/custom_wrapper.dart';

class SpecialMachineHandler extends StatefulWidget {
  const SpecialMachineHandler({super.key});

  @override
  State<SpecialMachineHandler> createState() => _SpecialMachineHandlerState();
}

class _SpecialMachineHandlerState extends State<SpecialMachineHandler> {
  final ScrollController _controller = ScrollController();
  BannerAd? bannerAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!kIsWeb) {
      final adState = Provider.of<AdState>(context);
      adState.initialization.then((status) {
        setState(() {
          bannerAd = BannerAd(
              size: AdSize.banner,
              adUnitId: adState.bannerAdUnitId,
              listener: adState.adListener,
              request: AdRequest())
            ..load();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;
    return CustomScrollBar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const UserCustomHeader(
              action: [],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: CustomWrapper(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NoData(
                        title: "Welcome, ${account.username!}",
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
