import 'package:flutter/material.dart';

class TaxPlannerPage extends StatefulWidget {
  const TaxPlannerPage({super.key});

  @override
  State<TaxPlannerPage> createState() => _TaxPlannerPageState();
}

class _TaxPlannerPageState extends State<TaxPlannerPage> {
  // Controllers
  final ctcCtrl = TextEditingController();
  final hraCtrl = TextEditingController();
  final rentCtrl = TextEditingController();
  final sec80cCtrl = TextEditingController();
  final sec80dCtrl = TextEditingController();

  String regime = 'Old';
  double yearlyTax = 0;
  double monthlyTds = 0;

  /// ---------------- TAX CALCULATION ----------------
  void calculateTax() {
    final ctc = double.tryParse(ctcCtrl.text) ?? 0;
    final hra = double.tryParse(hraCtrl.text) ?? 0;
    final rent = double.tryParse(rentCtrl.text) ?? 0;
    final sec80c = double.tryParse(sec80cCtrl.text) ?? 0;
    final sec80d = double.tryParse(sec80dCtrl.text) ?? 0;

    double taxableIncome = ctc;

    if (regime == 'Old') {
      final hraExemption = (rent - (0.1 * ctc)).clamp(0, hra);
      taxableIncome -= hraExemption;
      taxableIncome -= sec80c.clamp(0, 150000);
      taxableIncome -= sec80d.clamp(0, 25000);
    } else {
      taxableIncome -= 50000; // standard deduction
    }

    yearlyTax = _calculateSlabTax(taxableIncome);
    monthlyTds = yearlyTax / 12;

    setState(() {});
  }

  double _calculateSlabTax(double income) {
    double tax = 0;

    if (income <= 250000) return 0;

    if (income > 250000) {
      tax += (income.clamp(250001, 500000) - 250000) * 0.05;
    }
    if (income > 500000) {
      tax += (income.clamp(500001, 1000000) - 500000) * 0.20;
    }
    if (income > 1000000) {
      tax += (income - 1000000) * 0.30;
    }

    return tax * 1.04; // 4% cess
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Planner'),
        backgroundColor: Color.fromARGB(255, 156, 204, 223),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              title: 'Tax Regime',
              child: DropdownButtonFormField(
                value: regime,
                items: const [
                  DropdownMenuItem(value: 'Old', child: Text('Old Regime')),
                  DropdownMenuItem(value: 'New', child: Text('New Regime')),
                ],
                onChanged: (v) => setState(() => regime = v!),
              ),
            ),

            _card(
              title: 'Salary Details',
              child: _input('Annual CTC', ctcCtrl),
            ),

            if (regime == 'Old') ...[
              _card(
                title: 'HRA',
                child: Column(
                  children: [
                    _input('HRA Received', hraCtrl),
                    _input('Rent Paid (Yearly)', rentCtrl),
                  ],
                ),
              ),
              _card(
                title: 'Deductions',
                child: Column(
                  children: [
                    _input('Section 80C', sec80cCtrl),
                    _input('Section 80D', sec80dCtrl),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 156, 204, 223),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: calculateTax,
                child: const Text('Calculate Tax'),
              ),
            ),

            const SizedBox(height: 20),

            _resultTile('Yearly Tax', '₹${yearlyTax.toStringAsFixed(0)}'),
            _resultTile('Monthly TDS', '₹${monthlyTds.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  /// ---------------- COMPONENTS ----------------
  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _resultTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
