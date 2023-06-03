import 'package:flutter/material.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/widgets/adaptive_ui.dart';

import '../widgets/user_access_editor.dart';

class AccessRightsPage extends StatefulWidget {
  final Account? account;
  const AccessRightsPage({super.key, this.account});

  @override
  State<AccessRightsPage> createState() => _AccessRightsPageState();
}

class _AccessRightsPageState extends State<AccessRightsPage> {
  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
      onBackPressed: () => Navigator.pop(context),
      appbarTitle: "User Access Rights",
      body: UserAccessEditor(
        account: widget.account,
      ),
    );
  }
}
