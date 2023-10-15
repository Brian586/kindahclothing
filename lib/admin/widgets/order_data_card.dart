import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/sort_dates.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/widgets/progress_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OrderDataCard extends StatefulWidget {
  const OrderDataCard({
    super.key,
  });

  @override
  State<OrderDataCard> createState() => _OrderDataCardState();
}

class _OrderDataCardState extends State<OrderDataCard> {
  int maxOrders = 20;

  /// The method returns line series to chart.
  List<LineSeries<OrderGroup, dynamic>> _getDefaultLineSeries(
      List<OrderGroup> orderGroups) {
    return <LineSeries<OrderGroup, dynamic>>[
      LineSeries<OrderGroup, dynamic>(
          animationDuration: 2500,
          dataSource: orderGroups,
          xValueMapper: (OrderGroup orderGroup, _) => orderGroup.date,
          yValueMapper: (OrderGroup orderGroup, _) {
            if (orderGroup.orders!.length > maxOrders) {
              setState(() {
                maxOrders = orderGroup.orders!.length * 2;
              });
            }

            return orderGroup.orders!.length;
          },
          width: 2,
          color: Colors.pink,
          name: "Orders",
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  List<OrderGroup> getOrderGroups(List<template.Order> orders) {
    orders.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    var newMap = orders.groupListsBy((element) => DateFormat("dd MMM")
        .format(DateTime.fromMillisecondsSinceEpoch(element.timestamp!)));

    List<OrderGroup> orderGroups = newMap.entries
        .map((e) => OrderGroup(date: e.key, orders: e.value))
        .toList();

    orderGroups.sort((a, b) => sortDates(a, b));

    return orderGroups.toList();
  }

  int getCount(List<template.Order> orders, String type) {
    return orders
        .where(
          (element) => element.processedStatus == type,
        )
        .toList()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("orders").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<template.Order> orders = [];
          int notProcessed = 0;
          int processed = 0;
          int assigned = 0;
          int completed = 0;
          int finished = 0;

          snapshot.data!.docs.forEach((element) {
            template.Order order = template.Order.fromDocument(element);

            orders.add(order);
          });

          notProcessed = getCount(orders, "not processed");

          processed = getCount(orders, "processed");

          assigned = getCount(orders, "assigned");

          completed = getCount(orders, "completed");

          finished = getCount(orders, "finished");

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Templates/Orders",
                      style: Theme.of(context).textTheme.titleMedium,
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
                        title: ChartTitle(text: 'Orders'),
                        legend: Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap),
                        primaryXAxis: CategoryAxis(
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            //interval: 2,
                            majorGridLines: const MajorGridLines(width: 0)),
                        primaryYAxis: NumericAxis(
                            maximum: maxOrders.toDouble(),
                            minimum: 0,
                            interval: maxOrders.toDouble() / 10,
                            labelFormat: '{value}',
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(
                                color: Colors.transparent)),
                        series: _getDefaultLineSeries(getOrderGroups(orders)),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Orders",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              orders.length.toString(),
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
                                  color: Colors.red,
                                  height: 10.0,
                                  width: 10.0,
                                ),
                                title: Text("$notProcessed Not Processed"),
                              ),
                              ListTile(
                                leading: Container(
                                  color: Colors.orange,
                                  height: 10.0,
                                  width: 10.0,
                                ),
                                title: Text("$processed Processed"),
                              ),
                              ListTile(
                                leading: Container(
                                  color: Colors.greenAccent,
                                  height: 10.0,
                                  width: 10.0,
                                ),
                                title: Text("$completed Tailored"),
                              ),
                              ListTile(
                                leading: Container(
                                  color: Colors.green,
                                  height: 10.0,
                                  width: 10.0,
                                ),
                                title: Text("$finished Completed"),
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
      },
    );
  }
}

class OrderGroup {
  final String? date;
  final List<template.Order>? orders;

  OrderGroup({this.orders, this.date});
}
