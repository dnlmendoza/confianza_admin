class BarcodeEntry {
  final String id;
  final String name;
  final String barcode;
  final String price;
  final DateTime createdAt;
  final bool hasOriginalCode;
  bool selectedForPrint;

  BarcodeEntry({
    required this.id,
    required this.name,
    required this.barcode,
    this.price = "0.00",
    required this.createdAt,
    this.hasOriginalCode = false,
    this.selectedForPrint = false,
  });
}
