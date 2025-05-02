import 'dart:typed_data';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';

Future<Uint8List> getBarcodeImage(
  String barcodeVal, {
  double width = 300.0,
}) async {
  // Create an image
  final height = width * 1 / 2.5;
  final image = Image(width: width.toInt(), height: height.toInt());

  // Fill it with a solid color (white)
  fill(image, color: ColorRgb8(255, 255, 255));

  // Draw the barcode
  drawBarcode(image, Barcode.ean13(), barcodeVal, font: arial24);

  // Encode to PNG and return as Uint8List
  return Uint8List.fromList(encodePng(image));
}
