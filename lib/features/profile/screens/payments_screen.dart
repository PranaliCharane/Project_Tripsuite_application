import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late List<Map<String, dynamic>> savedCards;
  final List<Map<String, String>> payoutPreferences = [
    {'method': 'Bank transfer', 'detail': 'HDFC 0091...', 'status': 'Verified'},
    {'method': 'UPI', 'detail': 'pranali@okhdfcbank', 'status': 'Pending verification'},
  ];
  final List<Map<String, String>> billingAddress = [
    {'label': 'Name', 'value': 'Tim David'},
    {'label': 'Plot/Street', 'value': '123, Koregaon Park'},
    {'label': 'City/State', 'value': 'Pune, Maharashtra 411001'},
    {'label': 'Country', 'value': 'India'},
  ];
  final List<Map<String, String>> paymentHistory = [
    {'date': 'Jan 15', 'description': 'Maldives Escape', 'amount': '₹48,000'},
    {'date': 'Dec 12', 'description': 'Goa Retreat', 'amount': '₹27,500'},
    {'date': 'Nov 03', 'description': 'Bandung Lodge', 'amount': '₹22,300'},
  ];
  final List<String> _cardBrands = ['VISA', 'Mastercard', 'RuPay', 'Amex'];

  @override
  void initState() {
    super.initState();
    savedCards = [
      {
        'brand': 'VISA',
        'number': '**** **** **** 5168',
        'holder': 'Pranali Charane',
        'expiry': '08/32',
        'primary': true
      },
      {
        'brand': 'Mastercard',
        'number': '**** **** **** 2345',
        'holder': 'Pranali Charane',
        'expiry': '04/35',
        'primary': false
      },
    ];
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  Future<void> _showAddPaymentMethod() async {
    final numberController = TextEditingController();
    final holderController = TextEditingController();
    final expiryController = TextEditingController();
    String selectedBrand = _cardBrands.first;
    bool _isFormattingExpiry = false;
    expiryController.addListener(() {
      if (_isFormattingExpiry) return;
      final formatted = _formatExpiry(expiryController.text);
      if (formatted != expiryController.text) {
        _isFormattingExpiry = true;
        expiryController.text = formatted;
        expiryController.selection = TextSelection.collapsed(offset: formatted.length);
        _isFormattingExpiry = false;
      }
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add payment method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Card brand'),
                value: selectedBrand,
                items: _cardBrands
                    .map((brand) => DropdownMenuItem(value: brand, child: Text(brand)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedBrand = value;
                },
              ),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Card number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: holderController,
                decoration: const InputDecoration(labelText: 'Cardholder name'),
              ),
              TextField(
                controller: expiryController,
                decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (numberController.text.isEmpty ||
                        holderController.text.isEmpty ||
                        expiryController.text.isEmpty ||
                        selectedBrand.isEmpty) {
                      return;
                    }
                    final digits = numberController.text.trim();
                    final last4 = digits.length >= 4
                        ? digits.substring(digits.length - 4)
                        : digits;
                    final expiryText = expiryController.text.trim();
                    if (expiryText.length == 5) {
                      setState(() {
                        savedCards.add({
                          'brand': selectedBrand,
                          'number': '**** **** **** $last4',
                          'holder': holderController.text.trim(),
                          'expiry': expiryText,
                          'primary': false,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment method added')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save card'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _formatExpiry(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length <= 2) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }

  void _showReceipts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Receipts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...paymentHistory.map((history) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          history['description']!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () => _downloadReceipt(history),
                          icon: const Icon(Icons.download_rounded),
                          color: AppColors.blue,
                          tooltip: 'Download receipt',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(history['date']!),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount'),
                        Text(history['amount']!),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadReceipt(Map<String, String> history) async {
    final pdfDoc = pw.Document();
    pdfDoc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
               pw.Text('TripSuite Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Description: ${history['description']}'),
              pw.Text('Date: ${history['date']}'),
              pw.Text('Amount: ${history['amount']}'),
              pw.SizedBox(height: 24),
              pw.Text('Thank you for using TripSuite!', style: pw.TextStyle(color: PdfColors.grey700)),
            ],
          ),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${history['description']?.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdfDoc.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Receipt for ${history['description']}',
      subject: 'TripSuite receipt',
    );
  }

  Future<void> _showEditBillingAddress() async {
    final controllers = billingAddress
        .map((line) => TextEditingController(text: line['value']))
        .toList();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit billing address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                controllers.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                        labelText: billingAddress[index]['label']),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        for (var i = 0; i < billingAddress.length; i++) {
          billingAddress[i]['value'] = controllers[i].text.trim();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Billing address updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.lightgreySecond,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _sectionTitle('Saved payment methods'),
          _card(
            child: Column(
              children: [
                for (var card in savedCards) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.lightgrey,
                      child: Text((card['brand'] as String)[0]),
                    ),
                    title: Text('${card['brand']} ${card['number']}'),
                    subtitle: Text('${card['holder']} · Exp ${card['expiry']}'),
                    trailing: card['primary'] == true
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () {},
                            child: const Text('Set primary'),
                          ),
                  ),
                  if (card != savedCards.last) const Divider(),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showAddPaymentMethod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add new payment method'),
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle('Payout preferences'),
          _card(
            child: Column(
              children: [
                for (var payout in payoutPreferences) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(payout['method']!),
                    subtitle: Text(payout['detail']!),
                    trailing: Text(
                      payout['status']!,
                      style: TextStyle(
                        color: payout['status'] == 'Verified' ? AppColors.success : AppColors.accent,
                      ),
                    ),
                  ),
                  if (payout != payoutPreferences.last) const Divider(),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Manage payout preferences'),
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle('Billing address'),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var line in billingAddress)
                  Text(line['value'] ?? '', style: const TextStyle()),
                const SizedBox(height: 12),
        TextButton(
          onPressed: _showEditBillingAddress,
          child: const Text('Edit address'),
        ),
              ],
            ),
          ),

          _sectionTitle('Payment history'),
          _card(
            child: Column(
              children: [
                for (var history in paymentHistory) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(history['description']!),
                    subtitle: Text(history['date']!),
                    trailing: Text(
                      history['amount']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (history != paymentHistory.last) const Divider(),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _showReceipts,
                  child: const Text('View all receipts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
