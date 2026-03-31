import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  _PasswordGeneratorPageState createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  double _length = 16;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSymbols = true;
  String _password = "";

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String lower = "abcdefghijklmnopqrstuvwxyz";
    const String numbers = "0123456789";
    const String symbols = r"!@#$%^&*()_+-=[]{}|;:,.<>?";

    String charset = "";
    if (_useUppercase) charset += upper;
    if (_useLowercase) charset += lower;
    if (_useNumbers) charset += numbers;
    if (_useSymbols) charset += symbols;

    if (charset.isEmpty) {
      setState(() => _password = "Select at least one option");
      return;
    }

    final Random random = Random();
    String newPassword = List.generate(_length.toInt(), (index) {
      return charset[random.nextInt(charset.length)];
    }).join();

    setState(() => _password = newPassword);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Password copied to clipboard!'),
          duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text('Password Pro',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generated Password',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _password,
                      style: GoogleFonts.firaCode(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blueAccent),
                    onPressed: _copyToClipboard,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.greenAccent),
                    onPressed: _generatePassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Customize',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 12),
            _buildSliderOption('Password Length', _length, (val) {
              setState(() => _length = val);
              _generatePassword();
            }),
            const SizedBox(height: 16),
            _buildSwitchOption('Uppercase (A-Z)', _useUppercase, (val) {
              setState(() => _useUppercase = val);
              _generatePassword();
            }),
            _buildSwitchOption('Lowercase (a-z)', _useLowercase, (val) {
              setState(() => _useLowercase = val);
              _generatePassword();
            }),
            _buildSwitchOption('Numbers (0-9)', _useNumbers, (val) {
              setState(() => _useNumbers = val);
              _generatePassword();
            }),
            _buildSwitchOption('Symbols (#@\$)', _useSymbols, (val) {
              setState(() => _useSymbols = val);
              _generatePassword();
            }),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _generatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Generate New',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderOption(
      String label, double value, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              Text('${value.toInt()}',
                  style: const TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: 4,
            max: 64,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(
      String label, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blueAccent,
      ),
    );
  }
}
