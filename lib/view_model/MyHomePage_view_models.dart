import 'package:flutter/cupertino.dart';

class VisibleModel extends ChangeNotifier {
  bool _visibleControl = true;

  bool get isVisibleControl => _visibleControl;

  set isVisibleControl(bool value) {
    _visibleControl = value;
    notifyListeners();
  }

  void visibleChanged() {
    isVisibleControl = !isVisibleControl;
  }
}
