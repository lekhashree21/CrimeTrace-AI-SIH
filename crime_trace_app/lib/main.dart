import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const CrimeTraceApp());

class CrimeTraceApp extends StatelessWidget {
  const CrimeTraceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrimeTrace AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F3864)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hourCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _fraudType = 'UPI';
  String _district = 'Bangalore';
  Map<String, dynamic>? _result;
  bool _loading = false;
  final List<Map<String, dynamic>> _history = [];

  // For Chrome use localhost, for Android emulator use 10.0.2.2
  final String _apiUrl = 'http://localhost:5000/predict';

  Future<void> _predict() async {
    if (_hourCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')));
      return;
    }
    setState(() { _loading = true; _result = null; });
    try {
      final res = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'complaint_hour': int.parse(_hourCtrl.text),
          'fraud_amount': double.parse(_amountCtrl.text),
          'fraud_type': _fraudType,
          'district': _district,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() { _result = data; _history.insert(0, data); });
      }
    } catch (e) {
      setState(() {
        _result = {'error': 'Cannot reach API. Make sure Flask is running!'};
      });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 CrimeTrace AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F3864),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F3864),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(children: [
              Text('Cybercrime Cash Withdrawal Predictor',
                style: TextStyle(color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Predict withdrawal location before it happens',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),

          // Input Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Text('Enter Complaint Details',
                  style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _hourCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Complaint Hour (0-23)',
                    hintText: 'e.g. 21 for 9PM',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Fraud Amount (Rs)',
                    hintText: 'e.g. 50000',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _fraudType,
                  decoration: InputDecoration(
                    labelText: 'Fraud Type',
                    prefixIcon: const Icon(Icons.warning),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['UPI', 'NetBanking', 'CreditCard', 'Debit']
                    .map((t) => DropdownMenuItem(
                      value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _fraudType = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _district,
                  decoration: InputDecoration(
                    labelText: 'District',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Bangalore', 'Mysore', 'Hubli', 'Mangalore']
                    .map((d) => DropdownMenuItem(
                      value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _district = v!),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _predict,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: Text(
                      _loading ? 'Predicting...' : 'PREDICT LOCATION',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3864),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Loading
          if (_loading)
            const CircularProgressIndicator(),

          // Result Card
          if (_result != null) _buildResultCard(_result!),
          const SizedBox(height: 16),

          // History
          if (_history.isNotEmpty) _buildHistory(),
        ]),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> r) {
    if (r.containsKey('error')) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.error, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(r['error'].toString())),
          ]),
        ),
      );
    }

    final isHigh = r['alert'] == 'HIGH RISK';
    final isMedium = r['alert'] == 'MEDIUM RISK';
    final cardColor = isHigh
      ? Colors.red.shade50
      : isMedium
        ? Colors.orange.shade50
        : Colors.green.shade50;
    final iconColor = isHigh
      ? Colors.red
      : isMedium
        ? Colors.orange
        : Colors.green;

    return Card(
      elevation: 6,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Icon(
            isHigh ? Icons.warning_amber : Icons.info_outline,
            size: 60, color: iconColor),
          const SizedBox(height: 8),
          Text(r['alert'].toString(),
            style: TextStyle(fontSize: 24,
              fontWeight: FontWeight.bold, color: iconColor)),
          const Divider(height: 24),
          _row(Icons.location_on, 'Predicted Zone',
            r['predicted_cluster'].toString()),
          _row(Icons.my_location, 'Latitude',
            r['latitude'].toString()),
          _row(Icons.my_location, 'Longitude',
            r['longitude'].toString()),
          _row(Icons.speed, 'Risk Score',
            '${r["risk_score"]}%'),
          _row(Icons.atm, 'ATMs in Zone',
            r['atm_count'].toString()),
          const Divider(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8)),
            child: Text(
              '🚔 ACTION: ${r["action"]}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label,
          style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const Spacer(),
        Text(value,
          style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }

  Widget _buildHistory() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Predictions',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._history.take(5).map((r) => ListTile(
              leading: Icon(
                r['alert'] == 'HIGH RISK'
                  ? Icons.warning : Icons.info,
                color: r['alert'] == 'HIGH RISK'
                  ? Colors.red : Colors.orange),
              title: Text(r['predicted_cluster'].toString()),
              subtitle: Text(r['alert'].toString()),
              trailing: Text('${r["risk_score"]}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }
}
