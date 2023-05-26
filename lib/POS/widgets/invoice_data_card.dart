import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../config.dart';
import '../models/invoice.dart';
import '../models/invoice_group.dart';

class InvoiceDataCard extends StatefulWidget {
  final List<Invoice> invoices;
  const InvoiceDataCard({super.key, required this.invoices});

  @override
  State<InvoiceDataCard> createState() => _InvoiceDataCardState();
}

class _InvoiceDataCardState extends State<InvoiceDataCard> {
  List<InvoiceGroup> invoiceGroups = [];
  int maxOrders = 100;

  @override
  void initState() {
    super.initState();

    invoiceGroups = getInvoiceGroups(widget.invoices);
  }

  /// The method returns line series to chart.
  List<LineSeries<InvoiceGroup, dynamic>> _getDefaultLineSeries(
      List<InvoiceGroup> invoiceGroups) {
    return <LineSeries<InvoiceGroup, dynamic>>[
      LineSeries<InvoiceGroup, dynamic>(
          animationDuration: 2500,
          dataSource: invoiceGroups,
          xValueMapper: (InvoiceGroup invoiceGroup, _) => invoiceGroup.date,
          yValueMapper: (InvoiceGroup invoiceGroup, _) {
            if (invoiceGroup.invoices!.length > maxOrders) {
              setState(() {
                maxOrders = invoiceGroup.invoices!.length * 2;
              });
            }

            return invoiceGroup.invoices!.length;
          },
          width: 2,
          color: Config.customBlue,
          name: "Orders \nHistory",
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  List<InvoiceGroup> getInvoiceGroups(List<Invoice> invoices) {
    invoices.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    var newMap = invoices.groupListsBy((element) => DateFormat("dd MMM")
        .format(DateTime.fromMillisecondsSinceEpoch(element.timestamp!)));

    List<InvoiceGroup> invoiceGroups = newMap.entries
        .map((e) => InvoiceGroup(date: e.key, invoices: e.value))
        .toList();

    invoiceGroups.sort((a, b) => a.date!.compareTo(b.date!));
    return invoiceGroups.toList();
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
              Text(
                "Orders",
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
                  title: ChartTitle(text: 'New Orders'),
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
                      majorTickLines:
                          const MajorTickLines(color: Colors.transparent)),
                  series: _getDefaultLineSeries(invoiceGroups),
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Total Orders",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.invoices.length.toString(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ListTile(
                        //   leading: Container(
                        //     color: Colors.teal,
                        //     height: 10.0,
                        //     width: 10.0,
                        //   ),
                        //   title: Text("This "),
                        // ),
                        // ListTile(
                        //   leading: Container(
                        //     color: Colors.orange,
                        //     height: 10.0,
                        //     width: 10.0,
                        //   ),
                        //   title: Text("$fabricCutters Fabric Cutters"),
                        // ),
                        // ListTile(
                        //   leading: Container(
                        //     color: Colors.red,
                        //     height: 10.0,
                        //     width: 10.0,
                        //   ),
                        //   title: Text("$tailors Tailors"),
                        // )
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
