import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/walt_through_provider.dart';
import 'package:ridesewa/view/introScreen/selecton.dart';
import 'package:ridesewa/widgets/walkthrough_stepper.dart';
import 'package:ridesewa/widgets/walkthrough_templete.dart';

class WalkThrough extends StatelessWidget {
  final PageController _pageViewController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final WalkthroughProvider _walkthroughProvider =
        Provider.of<WalkthroughProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _pageViewController,
                  onPageChanged: (int index) {
                    _walkthroughProvider.onPageChange(index);
                  },
                  children: <Widget>[
                    WalkThroughTemplate(
                      title: "Welcome to Ridesewa",
                      subtitle:
                          "Discover a smarter way to travel. RideSewa connects you with drivers and passengers quickly and safely. Let's get started!",
                      image: Image.asset("assets/walkthrough1.png"),
                    ),
                    WalkThroughTemplate(
                      title: "Makes each ride easier and comfortable",
                      subtitle:
                          "I know this is crazy, but I tried something fresh, I hope you love it.",
                      image: Image.asset("assets/walkthrough2.png"),
                    ),
                    WalkThroughTemplate(
                      title: "Choose Your Ride.",
                      subtitle:
                          "Are you the one driving or the one riding? Pick your role and let’s get moving!",
                      image: Image.asset("assets/walkthrough3.png"),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(24.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: WalkthroughStepper(controller: _pageViewController),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_pageViewController.page != null && _pageViewController.page! >= 2) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => SelectionScreen(), // Replace with your UnAuth screen
                            ),
                          );
                          return;
                        }
                        _pageViewController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      child: ClipOval(
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Icon(
                              Icons.trending_flat,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
