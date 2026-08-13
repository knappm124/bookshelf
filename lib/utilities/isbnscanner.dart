import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'book.dart';
import 'file_utils.dart';
import 'image_utils.dart';

class IsbnScanner extends StatefulWidget {
  final Collection collection;

  const IsbnScanner({super.key, required this.collection});

  @override
  IsbnScannerState createState() => IsbnScannerState();
}

class IsbnScannerState extends State<IsbnScanner> {
  static const String isbnPrefix = '978';
  final MobileScannerController _cameraController = MobileScannerController(
    formats: [BarcodeFormat.ean13], // ISBN-13 books always use EAN-13 encoding
    autoStart: false,
  );

  bool _isScanning = true;
  bool _isSaving = false;
  String _bookTitle = "Scan a book to see details";
  String _bookAuthor = "";
  String _coverUrl = "";
  Book? _scannedBook;

  @override
  void initState() {
    super.initState();
    unawaited(_cameraController.start());
  }

  static String? extractIsbn(String scannedData) {
    // Check if the scanned data starts with the ISBN prefix
    if (scannedData.startsWith(isbnPrefix)) {
      // Extract the ISBN number from the scanned data
      return scannedData.substring(3); // Remove the '978' prefix
    }
    return null; // Return null if not a valid ISBN
  }

  Future<void> _addScannedBook() async {
    final book = _scannedBook;
    if (book == null || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    widget.collection.addBook(book);
    await saveCollectionToStorage(widget.collection);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(book);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISBN Scanner')),
      body: Column(
        children: [
          // Camera View Window
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _cameraController,
                  onDetect: (capture) {
                    if (!_isScanning) {
                      return;
                    }
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      final String code = barcodes.first.rawValue!;
                      setState(() => _isScanning = false); // Pause scanner loop
                      unawaited(_cameraController.stop());
                      IsbnApi()
                          .fetchdata(code)
                          .then((book) {
                            setState(() {
                              _scannedBook = book;
                              _bookTitle = book.name;
                              _bookAuthor = book.author;
                              _coverUrl = book.img;
                            });
                          })
                          .catchError((error) {
                            setState(() {
                              _scannedBook = null;
                              _bookTitle = "Failed to load book details";
                              _bookAuthor = "";
                              _coverUrl = "";
                            });
                          });
                    }
                  },
                ),
                if (!_isScanning)
                  Container(
                    color: Colors.black54,
                    child: const Text(
                      "Scanner Paused",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // Result Information Window
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_coverUrl.isNotEmpty)
                    Image.network(
                      webSafeImageUrl(_coverUrl),
                      height: 80,
                      errorBuilder: (c, o, s) => const SizedBox(),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _bookTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_bookAuthor.isNotEmpty)
                    Text(
                      _bookAuthor,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  if (!_isScanning) ...[
                    if (_scannedBook != null)
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _addScannedBook,
                        icon: const Icon(Icons.add),
                        label: Text(
                          _isSaving ? "Adding..." : "Add to Bookshelf",
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await _cameraController.start();
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _isScanning = true;
                          _scannedBook = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Scan Another Book"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
