import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:kindah/models/intro_page.dart';
import 'package:kindah/widgets/custom_button.dart';

import '../config.dart';

class UserIntro extends StatefulWidget {
  final String userType;
  const UserIntro({super.key, required this.userType});

  @override
  State<UserIntro> createState() => _UserIntroState();
}

class _UserIntroState extends State<UserIntro> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    List<IntroPage> userScreens = introScreens
        .where(
          (element) => element.userType == widget.userType,
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Config.customBlue.withOpacity(0.4),
        pages: List.generate(userScreens.length, (index) {
          IntroPage page = userScreens[index];

          return PageViewModel(
              image: page.image,
              title: page.title,
              bodyWidget: page.body,
              decoration: const PageDecoration(
                  titleTextStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)));
        }),
        showSkipButton: true,
        skip: TextButton(
          onPressed: () => introKey.currentState?.skipToEnd(),
          child: const Text(
            "SKIP",
            style: TextStyle(color: Colors.white),
          ),
        ),
        next: TransparentButton(
          onPressed: () => introKey.currentState?.next(),
          title: "NEXT",
        ),
        done: TransparentButton(
          onPressed: () => Navigator.pop(context),
          title: "DONE",
        ),
        onDone: () {
          // On Done button pressed
        },
        onSkip: () {
          // On Skip button pressed
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Colors.white, // Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }
}
