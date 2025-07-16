import 'package:flutter/material.dart';

class NavObserver extends NavigatorObserver {
  NavObserver._();
  static NavObserver instance = NavObserver._();

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

   static BuildContext? getContext([BuildContext? context]) {
    return navKey.currentContext ?? context;
  }
}
