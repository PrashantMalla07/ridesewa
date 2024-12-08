import 'package:flutter/material.dart';

class WalkThroughTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final Image image;

  WalkThroughTemplate({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: image,
            ),
          ),
          Container(
            height: 180.0,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.headlineMedium, // Updated from headline6
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith( // Updated from bodyText2
                          color: Colors.grey[600],
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
