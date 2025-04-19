import 'package:easy_scooter/pages/profile_page/components/models/card_transaction.dart';
import 'package:flutter/material.dart';

class TransactionSection extends StatelessWidget {
  final bool isLoading;
  final List<CardTransaction> transactions;
  final List<CardTransaction> paginatedTransactions;
  final int currentPage;
  final int itemsPerPage;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  const TransactionSection({
    Key? key,
    required this.isLoading,
    required this.transactions,
    required this.paginatedTransactions,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onNextPage,
    required this.onPreviousPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : Column(
                        children: [
                          ...paginatedTransactions.map((transaction) =>
                              _buildTransactionItem(transaction)),
                          const SizedBox(height: 16),
                          _buildPaginationControls(),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(CardTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDate(transaction.date),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            '- ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: currentPage > 0 ? onPreviousPage : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Previous'),
        ),
        Text(
          'Page ${currentPage + 1} of ${(transactions.length / itemsPerPage).ceil()}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        OutlinedButton(
          onPressed: currentPage < (transactions.length - 1) ~/ itemsPerPage
              ? onNextPage
              : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Next'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
