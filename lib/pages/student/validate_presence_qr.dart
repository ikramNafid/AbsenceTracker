import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../database/database_helper.dart';

class ValidatePresenceQRPage extends StatefulWidget {
  final int studentId;

  const ValidatePresenceQRPage({
    super.key,
    required this.studentId,
  });

  @override
  State<ValidatePresenceQRPage> createState() =>
      _ValidatePresenceQRPageState();
}

class _ValidatePresenceQRPageState extends State<ValidatePresenceQRPage> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {

    // ✅ CAS WEB (Chrome / Edge)
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Scanner QR"),
        ),
        body: const Center(
          child: Text(
            "Le scan QR n'est disponible que sur Android ou iOS.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    //  CAS MOBILE (Android / iOS)
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner le QR Code"),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) async {
          if (scanned) return;
          scanned = true;

          // récupérer le premier QR détecté
          final barcode = capture.barcodes.first;
          final String? qrValue = barcode.rawValue;

          if (qrValue == null) {
            scanned = false;
            return;
          }

          // le QR contient l'id de la session
          final int sessionId = int.parse(qrValue);

          // enregistrer la présence
          await DatabaseHelper.instance.markStudentPresent(
            widget.studentId,
            sessionId,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Présence validée avec succès "),
            ),
          );

          Navigator.pop(context);
        },
      ),
    );
  }
}
