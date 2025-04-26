import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewCardPage extends StatefulWidget {
  const AddNewCardPage({Key? key}) : super(key: key);
  @override
  State<AddNewCardPage> createState() => _AddNewCardPageState();
}

class _AddNewCardPageState extends State<AddNewCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expirationMonthController = TextEditingController();
  final _maturityYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardTypeController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expirationMonthController.dispose();
    _maturityYearController.dispose();
    _cvvController.dispose();
    _cardTypeController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final success =
          await Provider.of<PaymentCardProvider>(context, listen: false)
              .addPaymentCard(
        holderName: _cardholderNameController.text,
        cardNumber: _cardNumberController.text,
        expiryMonth: _expirationMonthController.text,
        expiryYear: _maturityYearController.text,
        cvv: _cvvController.text,
        cardType: _cardTypeController.text,
      );

      final errorMessage =
          Provider.of<PaymentCardProvider>(context, listen: false).error;
      print('Error message: $errorMessage'); // Debugging line

      // Extract content inside square brackets that follows "Error:"
      String extractedError = errorMessage ?? 'Failed to add card';
      if (errorMessage != null) {
        const errorPrefix = "Error: [";
        int startIndex = errorMessage.indexOf(errorPrefix);
        if (startIndex != -1) {
          startIndex += errorPrefix.length - 1; // Position after "Error: ["
          final endIndex = errorMessage.indexOf(']', startIndex);
          if (endIndex != -1) {
            extractedError = errorMessage.substring(startIndex + 1, endIndex);
          }
        }
      }

      setState(() {
        _errorMessage = success ? '' : extractedError;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('card saved')),
        );
        Provider.of<PaymentCardProvider>(context, listen: false)
            .fetchPaymentCards();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: "Add New Card"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Number Input Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Card Number To Add',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                                border: UnderlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter card number';
                                }
                                if (value.length < 13 || value.length > 19) {
                                  return 'Card number must be between 13 and 19 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              // TODO: Implement card scanning functionality
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Scan card',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                // Confirm Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Holder Name
                      TextFormField(
                        controller: _cardholderNameController,
                        decoration: const InputDecoration(
                          labelText: 'The Name Of Card Holder',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cardholder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Card Number (Confirmation)
                      TextFormField(
                        enabled:
                            false, // Disabled as it's already entered above
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Expiration Month
                      TextFormField(
                        controller: _expirationMonthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Expiration Month',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiration month';
                          }
                          final month = int.tryParse(value);
                          if (month == null || month < 1 || month > 12) {
                            return 'Expiration month must be between 1 and 12';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Maturity Year
                      TextFormField(
                        controller: _maturityYearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Maturity Year',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiration year';
                          }
                          final year = int.tryParse(value);
                          if (year == null || year < 25) {
                            return 'Expiration year must be 25 or later';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CVV
                      TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter CVV';
                          }
                          if (value.length != 3 && value.length != 4) {
                            return 'CVV must be 3 or 4 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Card Type
                      TextFormField(
                        controller: _cardTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Type Of Card',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card type';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Confirm Button
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4E08D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm Adding Card',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
