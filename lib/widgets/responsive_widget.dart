import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget desktopLayout;
  
  
  const ResponsiveWidget({super.key, required this.mobileLayout, this.tabletLayout, required this.desktopLayout});

  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width < 840;
  
  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 840;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)){
      return mobileLayout;
    } else if (isTablet(context) && tabletLayout != null) {
      return tabletLayout!;
    } else {
      return desktopLayout;
    }
  }
}