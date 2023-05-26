import 'package:flutter/material.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindah/widgets/progress_widget.dart';

class OrdersPieChart extends StatefulWidget {
  const OrdersPieChart({super.key});

  @override
  State<OrdersPieChart> createState() => _OrdersPieChartState();
}

class _OrdersPieChartState extends State<OrdersPieChart> {
  /// Returns the pie series.
  List<PieSeries<ChartSampleData, String>> _getDefaultPieSeries(data) {
    return <PieSeries<ChartSampleData, String>>[
      PieSeries<ChartSampleData, String>(
          explode: true,
          explodeIndex: 0,
          explodeOffset: '10%',
          dataSource: data,
          xValueMapper: (ChartSampleData data, _) => data.x as String,
          yValueMapper: (ChartSampleData data, _) => data.y,
          dataLabelMapper: (ChartSampleData data, _) => data.text,
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: const DataLabelSettings(isVisible: true)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("order_count")
          .doc("order_count")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          int processed = snapshot.data!["processed"];
          int completed = snapshot.data!["completed"];
          int finished = snapshot.data!["finished"];
          int notProcessed =
              snapshot.data!["count"] - (processed + completed + finished);
          int count = snapshot.data!["count"];

          List<ChartSampleData> data = [
            ChartSampleData(
                x: 'Not Processed ($notProcessed)',
                y: notProcessed,
                text:
                    'Not Processed - ${((notProcessed / count) * 100).round()}%'),
            ChartSampleData(
                x: 'Processed ($processed)',
                y: processed,
                text: 'Processed - ${((processed / count) * 100).round()}%'),
            ChartSampleData(
                x: 'Tailored ($completed)',
                y: completed,
                text: 'Tailored - ${((completed / count) * 100).round()}%'),
            ChartSampleData(
                x: 'Completed ($finished)',
                y: finished,
                text: 'Completed - ${((finished / count) * 100).round()}%'),
          ];

          return Align(
            alignment: Alignment.topLeft,
            child: CustomWrapper(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Analytics",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(
                        height: 20.0,
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      SfCircularChart(
                        // title: ChartTitle(text: 'Analytics'),
                        palette: [
                          Colors.red,
                          Colors.orange,
                          Colors.greenAccent,
                          Colors.green
                        ],
                        legend: Legend(isVisible: true),
                        series: _getDefaultPieSeries(data),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class ChartSampleData {
  final String? x;
  final int? y;
  final String? text;

  ChartSampleData({this.x, this.y, this.text});
}
