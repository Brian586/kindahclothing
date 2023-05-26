import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/POS/models/invoice.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/invoice_group.dart';

class POSIncomeCard extends StatefulWidget {
  final List<Invoice> invoices;
  const POSIncomeCard({super.key, required this.invoices});

  @override
  State<POSIncomeCard> createState() => _POSIncomeCardState();
}

class _POSIncomeCardState extends State<POSIncomeCard> {
  int maxCash = 1000;
  int mpesa = 0;
  int cash = 0;
  int paypal = 0;
  List<InvoiceGroup> mpesaInvoiceGroups = [];
  List<InvoiceGroup> paypalInvoiceGroups = [];
  List<InvoiceGroup> cashInvoiceGroups = [];
  List<String> transactionTypes = ["M-Pesa", "Paypal", "Cash"];

  @override
  void initState() {
    super.initState();

    mpesaInvoiceGroups = getInvoiceGroups(widget.invoices, transactionTypes[0]);

    paypalInvoiceGroups =
        getInvoiceGroups(widget.invoices, transactionTypes[1]);

    cashInvoiceGroups = getInvoiceGroups(widget.invoices, transactionTypes[2]);

    mpesa = widget.invoices
        .where(
          (invoice) =>
              invoice.paymentInfo!["payment_method"] == transactionTypes[0],
        )
        .toList()
        .length;

    cash = widget.invoices
        .where(
          (invoice) =>
              invoice.paymentInfo!["payment_method"] == transactionTypes[2],
        )
        .toList()
        .length;

    paypal = widget.invoices
        .where(
          (invoice) =>
              invoice.paymentInfo!["payment_method"] == transactionTypes[1],
        )
        .toList()
        .length;
  }

  LineSeries<InvoiceGroup, dynamic> dynamicSeries(
      List<InvoiceGroup> individualGroups, String title, Color color) {
    return LineSeries<InvoiceGroup, dynamic>(
        animationDuration: 2500,
        dataSource: individualGroups,
        xValueMapper: (InvoiceGroup invoiceGroup, _) => invoiceGroup.date,
        yValueMapper: (InvoiceGroup invoiceGroup, _) {
          int totalCashIn = 0;

          invoiceGroup.invoices!.forEach((invoice) {
            totalCashIn = totalCashIn + invoice.totalAmount!.round();
          });

          if (maxCash <= totalCashIn) {
            setState(() {
              maxCash = totalCashIn * 2;
            });
          }

          return totalCashIn;
        },
        width: 2,
        color: color,
        name: title,
        markerSettings: const MarkerSettings(isVisible: true));
  }

  Color getLineColor(String type) {
    switch (type) {
      case "M-Pesa":
        return Colors.green;
      case "Paypal":
        return Colors.blue;
      case "Cash":
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  List<InvoiceGroup> getRequiredInvoiceGroup(String type) {
    switch (type) {
      case "M-Pesa":
        return mpesaInvoiceGroups;
      case "Paypal":
        return paypalInvoiceGroups;
      case "Cash":
        return cashInvoiceGroups;
      default:
        return cashInvoiceGroups;
    }
  }

  /// The method returns line series to chart.
  List<LineSeries<InvoiceGroup, dynamic>> _getDefaultLineSeries() {
    return List.generate(
        transactionTypes.length,
        (index) => dynamicSeries(
            getRequiredInvoiceGroup(transactionTypes[index]),
            transactionTypes[index],
            getLineColor(transactionTypes[index])));
  }

  List<InvoiceGroup> getInvoiceGroups(List<Invoice> invoices, String type) {
    List<Invoice> transactionTypeInvoices = invoices
        .where(
          (invoice) => invoice.paymentInfo!["payment_method"] == type,
        )
        .toList();

    transactionTypeInvoices
        .sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    var newMap = transactionTypeInvoices.groupListsBy((element) =>
        DateFormat("dd MMM")
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
                "Income Analytics",
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
                  title: ChartTitle(text: 'Income (Ksh)'),
                  legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap),
                  primaryXAxis: CategoryAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      //interval: 2,
                      majorGridLines: const MajorGridLines(width: 0)),
                  primaryYAxis: NumericAxis(
                      maximum: maxCash.toDouble(),
                      minimum: 0,
                      interval: (maxCash.toDouble()) / 10,
                      labelFormat: '{value}',
                      axisLine: const AxisLine(width: 0),
                      majorTickLines:
                          const MajorTickLines(color: Colors.transparent)),
                  series: _getDefaultLineSeries(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Transactions",
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
                        ListTile(
                          leading: Container(
                            color: Colors.green,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$mpesa M-Pesa"),
                        ),
                        ListTile(
                          leading: Container(
                            color: Colors.blue,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$paypal Paypal"),
                        ),
                        ListTile(
                          leading: Container(
                            color: Colors.orange,
                            height: 10.0,
                            width: 10.0,
                          ),
                          title: Text("$cash Cash"),
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
