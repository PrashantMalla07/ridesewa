import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/walt_through_provider.dart';

class WalkthroughStepper extends StatelessWidget {
  final PageController controller;

  WalkthroughStepper({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (int index) {
          return Consumer<WalkthroughProvider>(
            builder: (BuildContext context, WalkthroughProvider walkthrough, Widget? child) {
              return GestureDetector(
                onTap: () {
                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Container(
                    height: 5.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: index <= walkthrough.currentPageValue
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    margin: const EdgeInsets.only(right: 5.0),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
