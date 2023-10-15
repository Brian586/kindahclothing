import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/sort_dates.dart';
import 'package:kindah/common_functions/user_role_solver.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/custom_tag.dart';

class UserDataCard extends StatefulWidget {
  final List<Account>? accounts;
  const UserDataCard({super.key, this.accounts});

  @override
  State<UserDataCard> createState() => _UserDataCardState();
}

class _UserDataCardState extends State<UserDataCard> {
  int specialMachineHandlers = 0;
  int shopAttendants = 0;
  int fabricCutters = 0;
  int tailors = 0;
  int finishers = 0;
  int maxUsers = 20;
  List<AccountGroup> accountGroups = [];

  @override
  void initState() {
    super.initState();

    accountGroups = getAccountGroups(widget.accounts!);

    shopAttendants = userCount("shop_attendant");

    fabricCutters = userCount("fabric_cutter");

    tailors = userCount("tailor");

    finishers = userCount("finisher");

    specialMachineHandlers =
        userCount(toCoded(UserRoles.specialMachineHandler));
  }

  int userCount(String role) {
    return widget.accounts!
        .where(
          (account) => account.userRole!.contains(role),
        )
        .toList()
        .length;
  }

  /// The method returns line series to chart.
  List<LineSeries<AccountGroup, dynamic>> _getDefaultLineSeries(
      List<AccountGroup> accountGroups) {
    return <LineSeries<AccountGroup, dynamic>>[
      LineSeries<AccountGroup, dynamic>(
          animationDuration: 2500,
          dataSource: accountGroups,
          xValueMapper: (AccountGroup accountGroup, _) => accountGroup.date,
          yValueMapper: (AccountGroup accountGroup, _) {
            if (accountGroup.accounts!.length > maxUsers) {
              setState(() {
                maxUsers = accountGroup.accounts!.length * 2;
              });
            }

            return accountGroup.accounts!.length;
          },
          width: 2,
          color: Config.customBlue,
          name: "New Users",
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  List<AccountGroup> getAccountGroups(List<Account> accounts) {
    accounts.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    var newMap = accounts.groupListsBy((element) => DateFormat("dd MMM")
        .format(DateTime.fromMillisecondsSinceEpoch(element.timestamp!)));

    List<AccountGroup> accountGroups = newMap.entries
        .map((e) => AccountGroup(date: e.key, accounts: e.value))
        .toList();

    accountGroups.sort((a, b) => sortDates(a, b));

    return accountGroups.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "User Analytics",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  InkWell(
                      onTap: () {
                        context
                            .read<AdminProvider>()
                            .changeDrawerItem("add_users");

                        context.go("/admin/0001/add_users");
                      },
                      child: const CustomTag(
                        title: "Add Users",
                        color: Config.customBlue,
                      ))
                ],
              ),
              const Divider(
                height: 20.0,
                thickness: 1.0,
                color: Colors.grey,
              ),
              SizedBox(
                height: 300.0,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  title: ChartTitle(text: 'New Users'),
                  legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap),
                  primaryXAxis: CategoryAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      //interval: 2,
                      majorGridLines: const MajorGridLines(width: 0)),
                  primaryYAxis: NumericAxis(
                      maximum: maxUsers.toDouble(),
                      minimum: 0,
                      interval: maxUsers.toDouble() / 10,
                      labelFormat: '{value}',
                      axisLine: const AxisLine(width: 0),
                      majorTickLines:
                          const MajorTickLines(color: Colors.transparent)),
                  series: _getDefaultLineSeries(accountGroups),
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Users",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.accounts!.length.toString(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Container(
                            color: Colors.teal,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$shopAttendants Shop Attendants"),
                        ),
                        ListTile(
                          leading: Container(
                            color: Colors.orange,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$fabricCutters Fabric Cutters"),
                        ),
                        ListTile(
                          leading: Container(
                            color: Colors.red,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$tailors Tailors"),
                        ),
                        ListTile(
                          leading: Container(
                            color: Colors.blue,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$finishers Finishers"),
                        ),
                        ListTile(
                          leading: Container(
                            color: Config.customBlue,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text(
                              "$specialMachineHandlers Special Machine Handlers"),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AccountGroup {
  final String? date;
  final List<Account>? accounts;

  AccountGroup({this.accounts, this.date});
}
