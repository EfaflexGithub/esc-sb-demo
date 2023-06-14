import 'package:flutter/material.dart';

class NavigationRailIcon extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  NavigationRailIcon({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    late final ColorScheme colors = Theme.of(context).colorScheme;
    late final TextTheme textTheme = Theme.of(context).textTheme;

    return InkResponse(
      onTap: onTap,
      child: Column(
        children: [
          icon,
          const SizedBox(
            height: 4.0,
          ),
          Text(
            text,
            style: textTheme.labelMedium!.copyWith(color: colors.onSurface),
          ),
          const SizedBox(
            height: 13.0,
          )
        ],
      ),
    );
  }
}
