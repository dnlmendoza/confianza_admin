import 'package:flutter/foundation.dart';

class LoteItem {
  double costoUnitario;
  LoteItem({this.costoUnitario = 36.25});
}

void main() {
  double? val;
  var l = LoteItem(costoUnitario: val ?? 0.0);
  debugPrint(l.costoUnitario.toString());
}
