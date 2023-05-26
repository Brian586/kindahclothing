import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import "package:flutter/material.dart";
import 'package:kindah/config.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/widgets/progress_widget.dart';

class OrderProgressIndicator extends StatefulWidget {
  final template.Order order;
  const OrderProgressIndicator({super.key, required this.order});

  @override
  State<OrderProgressIndicator> createState() => _OrderProgressIndicatorState();
}

class _OrderProgressIndicatorState extends State<OrderProgressIndicator> {
  int activeStep = 0;
  String shopAttendant = "";
  String fabricCutter = "";
  String tailor = "";
  String finisher = "";

  @override
  void initState() {
    super.initState();

    getActiveStep();
  }

  void getActiveStep() {
    switch (widget.order.processedStatus) {
      case "not processed":
        setState(() {
          activeStep = 0;
          shopAttendant = widget.order.shopAttendant!["username"] ?? "_";
        });
        break;
      case "processed":
        setState(() {
          activeStep = 1;
          shopAttendant = widget.order.shopAttendant!["username"] ?? "_";
          fabricCutter = widget.order.fabricCutter!["username"] ?? "_";
        });
        break;
      case "completed":
        setState(() {
          activeStep = 2;
          shopAttendant = widget.order.shopAttendant!["username"] ?? "_";
          fabricCutter = widget.order.fabricCutter!["username"] ?? "_";
          tailor = widget.order.tailor!["username"] ?? "_";
        });
        break;
      case "finished":
        setState(() {
          activeStep = 3;
          shopAttendant = widget.order.shopAttendant!["username"] ?? "_";
          fabricCutter = widget.order.fabricCutter!["username"] ?? "_";
          tailor = widget.order.tailor!["username"] ?? "_";
          finisher = widget.order.finisher!["username"] ?? "_";
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyStepper(
      activeStep: activeStep + 1,
      lineLength: 50,
      stepShape: StepShape.rRectangle,
      stepBorderRadius: 15,
      borderThickness: 2,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0),
      stepRadius: 28,
      finishedStepBorderColor: Config.customBlue,
      finishedStepTextColor: Config.customBlue,
      finishedLineColor: Config.customBlue,
      finishedStepBorderType: BorderType.normal,
      finishedStepIconColor: Colors.white,
      finishedStepBackgroundColor: Config.customBlue,
      activeStepIconColor: Config.customBlue,
      unreachedStepBackgroundColor: Colors.transparent,
      unreachedStepBorderColor: Config.customGrey,
      unreachedLineColor: Config.customGrey,
      unreachedStepIconColor: Config.customGrey,
      unreachedStepBorderType: BorderType.dotted,
      unreachedStepTextColor: Config.customGrey,
      showLoadingAnimation: false,
      steps: [
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 0 ? 1 : 0.3,
              child: Icon(
                Icons.storefront_outlined,
                color: activeStep >= 0 ? Colors.white : Config.customGrey,
              ), //Image.asset('assets/1.png'),
            ),
          ),
          customTitle: const Text(
            'Created',
            textAlign: TextAlign.center,
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 1 ? 1 : 0.3,
              child: Icon(
                Icons.cut_outlined,
                color: activeStep >= 1 ? Colors.white : Config.customGrey,
              ),
            ),
          ),
          customTitle: const Text(
            'Fabric Cutting',
            textAlign: TextAlign.center,
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
                opacity: activeStep >= 2 ? 1 : 0.3,
                child: Image.asset(
                  activeStep >= 2
                      ? "assets/images/sewing_machine.png"
                      : "assets/images/sewing_machine_b.png",
                  height: 30.0,
                  width: 30.0,
                )),
          ),
          customTitle: const Text(
            'Tailored',
            textAlign: TextAlign.center,
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 3 ? 1 : 0.3,
              child: Icon(
                Icons.done_rounded,
                color: activeStep >= 3 ? Colors.white : Config.customGrey,
              ),
            ),
          ),
          customTitle: const Text(
            'Finished',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class GeneralOrderProgressIndicator extends StatefulWidget {
  const GeneralOrderProgressIndicator({super.key});

  @override
  State<GeneralOrderProgressIndicator> createState() =>
      _GeneralOrderProgressIndicatorState();
}

class _GeneralOrderProgressIndicatorState
    extends State<GeneralOrderProgressIndicator> {
  int activeStep = 3;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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

          return Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                        "Order Progress",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(
                        height: 20.0,
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      EasyStepper(
                        activeStep: activeStep + 1,
                        lineLength: 50,
                        stepShape: StepShape.rRectangle,
                        stepBorderRadius: 15,
                        borderThickness: 2,
                        padding: const EdgeInsetsDirectional.symmetric(
                            vertical: 10.0),
                        stepRadius: 28,
                        finishedStepBorderColor: Config.customBlue,
                        finishedStepTextColor: Config.customBlue,
                        finishedLineColor: Config.customBlue,
                        finishedStepBorderType: BorderType.normal,
                        finishedStepIconColor: Colors.white,
                        finishedStepBackgroundColor: Config.customBlue,
                        activeStepIconColor: Config.customBlue,
                        unreachedStepBackgroundColor: Colors.transparent,
                        unreachedStepBorderColor: Config.customGrey,
                        unreachedLineColor: Config.customGrey,
                        unreachedStepIconColor: Config.customGrey,
                        unreachedStepBorderType: BorderType.dotted,
                        unreachedStepTextColor: Config.customGrey,
                        showLoadingAnimation: false,
                        steps: [
                          EasyStep(
                            customStep: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Opacity(
                                opacity: activeStep >= 0 ? 1 : 0.3,
                                child: Icon(
                                  Icons.storefront_outlined,
                                  color: activeStep >= 0
                                      ? Colors.white
                                      : Config.customGrey,
                                ), //Image.asset('assets/1.png'),
                              ),
                            ),
                            customTitle: Text(
                              'Created ($count)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          EasyStep(
                            customStep: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Opacity(
                                opacity: activeStep >= 1 ? 1 : 0.3,
                                child: Icon(
                                  Icons.cut_outlined,
                                  color: activeStep >= 1
                                      ? Colors.white
                                      : Config.customGrey,
                                ),
                              ),
                            ),
                            customTitle: Text(
                              'Fabric Cutting ($processed)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          EasyStep(
                            customStep: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Opacity(
                                  opacity: activeStep >= 2 ? 1 : 0.3,
                                  child: Image.asset(
                                    activeStep >= 2
                                        ? "assets/images/sewing_machine.png"
                                        : "assets/images/sewing_machine_b.png",
                                    height: 30.0,
                                    width: 30.0,
                                  )),
                            ),
                            customTitle: Text(
                              'Tailored ($completed)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          EasyStep(
                            customStep: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Opacity(
                                opacity: activeStep >= 3 ? 1 : 0.3,
                                child: Icon(
                                  Icons.done_rounded,
                                  color: activeStep >= 3
                                      ? Colors.white
                                      : Config.customGrey,
                                ),
                              ),
                            ),
                            customTitle: Text(
                              'Finished ($finished)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Oders NOT Processed: $notProcessed",
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
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
