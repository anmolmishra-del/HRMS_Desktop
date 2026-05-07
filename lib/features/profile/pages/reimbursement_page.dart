import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReimbursementPage extends StatelessWidget {
  const ReimbursementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F3F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Reimbursement",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.arrow_back, color: Colors.black87),
        actions: const [
          Icon(Icons.calendar_today_outlined, color: Colors.black87),
          SizedBox(width: 16),
          Icon(Icons.add, color: Colors.black87),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Month Text
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Apr 2022", style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 10),

            /// Claim Amount Card
            _buildClaimCard(),

            const SizedBox(height: 20),

            /// Reimbursement List
            _buildReimbursementCard(
              title: "Fuel Reimbursement",
              date: "Tue, 5 Apr 22 - Tue, 5 Apr 22",
              amount: "₹ 2,999",
              status: "LIMITED",
              statusColor: Colors.orange,
              actionText: "WITHDRAW",
            ),

            _buildReimbursementCard(
              title: "Travel Reimbursement",
              date: "Sat, 2 Apr 22 - Mon, 4 Apr 22",
              amount: "₹ 5,300",
              status: "APPROVED",
              statusColor: Colors.green,
              actionText: null,
            ),

            _buildReimbursementCard(
              title: "Food Reimbursement",
              date: "Fri, 1 Apr 22 - Fri, 1 Apr 22",
              amount: "₹ 2,999",
              status: "REJECTED",
              statusColor: Colors.red,
              actionText: "RESUBMIT",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.grey.withOpacity(0.15),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("Claim Amount", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          const Text(
            "₹ 30000",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SummaryItem(title: "Pending", amount: "₹ 2,900"),
              _SummaryItem(title: "Rejected", amount: "₹ 5,998"),
              _SummaryItem(title: "Expenses", amount: "₹ 38,898"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReimbursementCard({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    String? actionText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.grey.withOpacity(0.12),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 5),

          /// Date
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),

              if (actionText != null)
                Text(
                  actionText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          /// Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String amount;

  const _SummaryItem({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
