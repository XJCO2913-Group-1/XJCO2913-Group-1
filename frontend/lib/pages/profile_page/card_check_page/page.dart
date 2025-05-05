import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/models/payment_card.dart';
import 'package:easy_scooter/pages/profile_page/components/payment_card/current_card_section.dart';
import 'package:easy_scooter/pages/profile_page/components/information_section.dart';
import 'package:easy_scooter/pages/profile_page/models/card_transaction.dart';
import 'package:easy_scooter/pages/profile_page/components/section_title.dart';
import 'package:easy_scooter/pages/profile_page/components/transaction_section.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/services/payment_card_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardCheckPage extends StatefulWidget {
  final int cardId;

  const CardCheckPage({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  State<CardCheckPage> createState() => _CardCheckPageState();
}

class _CardCheckPageState extends State<CardCheckPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefaultCard = false;
  bool _isLoading = true;
  PaymentCard? _card;
  List<CardTransaction> _transactions = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _loadingTransactions = true;

  @override
  void initState() {
    super.initState();
    _loadCardData();
    _loadTransactionData();
  }

  Future<void> _loadCardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final card = await PaymentCardService().getPaymentCardById(widget.cardId);
      setState(() {
        _card = card;
        _isDefaultCard = card.isDefault;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load card data: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadTransactionData() async {
    setState(() {
      _loadingTransactions = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final mockTransactions = List<CardTransaction>.generate(
        25,
        (index) => CardTransaction(
          id: index + 1,
          date: DateTime.now().subtract(Duration(days: index * 3)),
          amount: (index * 5.75).toDouble(),
          currency: '£',
        ),
      );

      setState(() {
        _transactions = mockTransactions;
        _loadingTransactions = false;
      });
    } catch (e) {
      setState(() {
        _loadingTransactions = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load transaction data: ${e.toString()}')),
      );
    }
  }

  List<CardTransaction> get _paginatedTransactions {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage < _transactions.length
        ? startIndex + _itemsPerPage
        : _transactions.length;

    if (startIndex >= _transactions.length) {
      return [];
    }

    return _transactions.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (_currentPage < (_transactions.length - 1) ~/ _itemsPerPage) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _updateDefaultStatus(bool isDefault) async {
    try {
      setState(() {
        _isDefaultCard = isDefault;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default card status updated')),
      );
      Provider.of<PaymentCardProvider>(context, listen: false)
          .fetchPaymentCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update default status: ${e.toString()}')),
      );
    }
  }

  void _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await PaymentCardService().deletePaymentCard(widget.cardId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted successfully')),
        );
        Provider.of<PaymentCardProvider>(context, listen: false)
            .fetchPaymentCards();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete card: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: "Your Payment Card"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Current Card Selection'),
                      CurrentCardSection(
                        card: _card,
                        isDefaultCard: _isDefaultCard,
                        cardId: widget.cardId,
                        onDefaultChanged: _updateDefaultStatus,
                      ),
                      const SizedBox(height: 20),
                      const SectionTitle(title: 'Information'),
                      InformationSection(
                        card: _card,
                        onDeleteCard: _deleteCard,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
