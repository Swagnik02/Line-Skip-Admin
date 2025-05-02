import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'dart:developer' show log;

Future<String> scanBarcode(BuildContext context) async {
  String? barcode = await SimpleBarcodeScanner.scanBarcode(
    context,
    isShowFlashIcon: true,
    cameraFace: CameraFace.back,
    scanType: ScanType.barcode,
  );

  log('Scanned barcode: $barcode', name: 'Barcode Scanner');

  return barcode ?? '';
}
