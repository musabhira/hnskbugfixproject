import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BulkSenderPage extends StatefulWidget {
  const BulkSenderPage({Key? key}) : super(key: key);

  @override
  State<BulkSenderPage> createState() => _BulkSenderPageState();
}

class _BulkSenderPageState extends State<BulkSenderPage>
    with WidgetsBindingObserver {
  final TextEditingController _numbersController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<String> _numbersList = [];
  int _currentIndex = -1;
  bool _isAutoSending = false;
  bool _showProgress = false;
  bool _useApiMode = false;
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _numbersController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isAutoSending) {
      // Add a small delay to ensure UI is ready before triggering next URL
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _isAutoSending) {
          _processNext();
        }
      });
    }
  }

  Future<void> _pickContacts() async {
    // Check and request permission using permission_handler for reliability
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (!mounted) return;

      if (contacts.isEmpty) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          const material.SnackBar(content: Text('No contacts found')),
        );
        return;
      }

      // Filter contacts that have phone numbers
      final contactsWithPhone =
          contacts.where((c) => c.phones.isNotEmpty).toList();

      final List<Contact>? selected = await material.showDialog<List<Contact>>(
        context: context,
        builder: (context) => MultiContactPickerDialog(
          contacts: contactsWithPhone,
        ),
      );

      if (selected != null && selected.isNotEmpty) {
        final List<String> extractedNumbers = [];
        for (var contact in selected) {
          if (contact.phones.isNotEmpty) {
            // Take the first phone number or let user choose?
            // For bulk, usually we take the primary/first one.
            extractedNumbers.add(contact.phones.first.number);
          }
        }

        final String newNumbersText = extractedNumbers.join(', ');
        setState(() {
          if (_numbersController.text.trim().isEmpty) {
            _numbersController.text = newNumbersText;
          } else {
            _numbersController.text += ', ' + newNumbersText;
          }
        });

        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('Import Successful'),
            content:
                Text('${extractedNumbers.length} contacts added to queue.'),
            severity: InfoBarSeverity.success,
          );
        });
      }
    } else {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: Text('Contact permission is required to import numbers.'),
          backgroundColor: material.Colors.redAccent,
        ),
      );
    }
  }

  void _parseNumbers() {
    final text = _numbersController.text;
    if (text.isEmpty) return;

    final split = text.split(RegExp(r'[,\s\n]+'));
    setState(() {
      _numbersList = split
          .map((s) => s.trim().replaceAll(RegExp(r'[^\d+]'), ''))
          .where((s) => s.length >= 10)
          .toList();
      _showProgress = _numbersList.isNotEmpty;
      _currentIndex = -1;
      _isAutoSending = false;
    });
  }

  Future<void> _sendToNumber(String number) async {
    final message = _messageController.text;
    var processedNumber = number;
    if (!processedNumber.startsWith('+')) {
      if (processedNumber.length == 10) {
        processedNumber = '+91$processedNumber';
      }
    }

    final url =
        "https://wa.me/${processedNumber.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        material.debugPrint("Could not launch $url");
      }
    } catch (e) {
      material.debugPrint("Error launching WhatsApp: $e");
    }
  }

  void _startAutoSend() {
    if (_numbersList.isEmpty) return;
    setState(() {
      _isAutoSending = true;
      _currentIndex = 0;
    });
    if (_useApiMode) {
      _sendViaApi(_numbersList[_currentIndex]);
    } else {
      _sendToNumber(_numbersList[_currentIndex]);
    }
  }

  Future<void> _sendViaApi(String number) async {
    if (_apiUrlController.text.isEmpty || _apiTokenController.text.isEmpty) {
      displayInfoBar(context, builder: (context, close) {
        return const InfoBar(
          title: Text('API Error'),
          content: Text('Please enter your API Link and Token in settings.'),
          severity: InfoBarSeverity.error,
        );
      });
      setState(() => _isAutoSending = false);
      return;
    }

    final message = _messageController.text;
    final url = Uri.parse(_apiUrlController.text);

    try {
      // Assuming UltraMsg format, can be adjusted for other providers
      final response = await http.post(url, body: {
        'token': _apiTokenController.text,
        'to': number,
        'body': message,
      });

      if (response.statusCode == 200) {
        // Automatically move to next after 1 second delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && _isAutoSending) {
            _processNext();
          }
        });
      } else {
        throw Exception('Failed to send: ${response.body}');
      }
    } catch (e) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text('API Failure'),
          content: Text(e.toString()),
          severity: InfoBarSeverity.error,
        );
      });
      setState(() => _isAutoSending = false);
    }
  }

  void _processNext() {
    if (_currentIndex < _numbersList.length - 1) {
      setState(() {
        _currentIndex++;
      });
      // Automatically trigger the next one
      _sendToNumber(_numbersList[_currentIndex]);
    } else {
      setState(() {
        _isAutoSending = false;
        _currentIndex = -1;
      });
      _showSuccessInfo();
    }
  }

  void _showSuccessInfo() {
    displayInfoBar(context, builder: (context, close) {
      return const InfoBar(
        title: Text('Success'),
        content: Text('All messages have been processed!'),
        severity: InfoBarSeverity.success,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: material.AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Bulk WhatsApp Sender',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: material.IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: material.SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Step 1: Paste Numbers',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: material.Colors.yellow)),
                material.TextButton.icon(
                  onPressed: _pickContacts,
                  icon: const Icon(FluentIcons.contact_list,
                      size: 16, color: material.Colors.yellow),
                  label: Text('Import Contacts',
                      style: GoogleFonts.inter(
                          color: material.Colors.yellow, fontSize: 13)),
                  style: material.TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor:
                        material.Colors.yellow.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildNumbersInput(),
            const SizedBox(height: 24),
            Text('Step 2: Compose Message',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: material.Colors.yellow)),
            const SizedBox(height: 8),
            _buildMessageInput(),
            const SizedBox(height: 32),
            if (!_showProgress) _buildActionButtons(),
            if (_showProgress) _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: material.Colors.yellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: material.Colors.yellow.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(FluentIcons.info, color: material.Colors.yellow),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Paste a list of numbers separated by commas or new lines. This tool will help you send messages via WhatsApp loop.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: material.Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbersInput() {
    return material.TextField(
      controller: _numbersController,
      maxLines: 6,
      style: material.TextStyle(color: material.Colors.white),
      decoration: material.InputDecoration(
        hintText: '+919876543210, +918887776665...',
        hintStyle: material.TextStyle(color: material.Colors.grey[600]),
        filled: true,
        fillColor: material.Colors.white.withValues(alpha: 0.05),
        border: material.OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: material.BorderSide.none),
      ),
    );
  }

  Widget _buildMessageInput() {
    return material.TextField(
      controller: _messageController,
      maxLines: 4,
      style: material.TextStyle(color: material.Colors.white),
      decoration: material.InputDecoration(
        hintText: 'Hello! This is a bulk message from Pocket Mates.',
        hintStyle: material.TextStyle(color: material.Colors.grey[600]),
        filled: true,
        fillColor: material.Colors.white.withValues(alpha: 0.05),
        border: material.OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: material.BorderSide.none),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _parseNumbers,
        style: ButtonStyle(
          backgroundColor: ButtonState.all(material.Colors.yellow),
          padding: ButtonState.all(const EdgeInsets.symmetric(vertical: 16)),
        ),
        child: Text('Generate Sending Queue',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: material.Colors.black)),
      ),
    );
  }

  Widget _buildProgressSection() {
    final double progress =
        _numbersList.isEmpty ? 0 : (_currentIndex + 1) / _numbersList.length;
    final int remaining = _numbersList.length - (_currentIndex + 1);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: material.Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: material.Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Queue: ${_numbersList.length} Numbers',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  if (_currentIndex >= 0)
                    Text('${_currentIndex + 1} / ${_numbersList.length}',
                        style:
                            GoogleFonts.inter(color: material.Colors.yellow)),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBar(value: progress * 100),
              const SizedBox(height: 24),
              if (!_isAutoSending)
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        child: const Text('Reset'),
                        onPressed: () => setState(() => _showProgress = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _startAutoSend,
                        child: const Text('Start Sending'),
                      ),
                    ),
                  ],
                ),
              if (_isAutoSending)
                Column(
                  children: [
                    Text(
                      'Currently processing: ${_numbersList[_currentIndex]}',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: material.Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            _sendToNumber(_numbersList[_currentIndex]),
                        child: Text(_currentIndex == _numbersList.length - 1
                            ? 'Send Last'
                            : 'Send Next ($remaining left)'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        material.TextButton(
          onPressed: () => setState(() => _showProgress = false),
          child: const Text('Back to Edit',
              style: material.TextStyle(color: material.Colors.grey)),
        ),
      ],
    );
  }
}

class MultiContactPickerDialog extends StatefulWidget {
  final List<Contact> contacts;

  const MultiContactPickerDialog({Key? key, required this.contacts})
      : super(key: key);

  @override
  State<MultiContactPickerDialog> createState() =>
      _MultiContactPickerDialogState();
}

class _MultiContactPickerDialogState extends State<MultiContactPickerDialog> {
  final List<Contact> _selected = [];
  late List<Contact> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts
            .where((c) =>
                c.displayName.toLowerCase().contains(query.toLowerCase()) ||
                c.phones.any((p) => p.number.contains(query)))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return material.Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Contacts',
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: material.Colors.white)),
                material.IconButton(
                  icon: const Icon(FluentIcons.chrome_close, size: 12),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            material.TextField(
              onChanged: _filterContacts,
              style: const material.TextStyle(color: material.Colors.white),
              decoration: material.InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: material.TextStyle(color: material.Colors.grey[600]),
                prefixIcon: const Icon(FluentIcons.search,
                    color: material.Colors.grey, size: 16),
                filled: true,
                fillColor: material.Colors.white.withValues(alpha: 0.05),
                border: material.OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: material.BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                material.TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selected.length == widget.contacts.length) {
                        _selected.clear();
                      } else {
                        _selected.clear();
                        _selected.addAll(widget.contacts);
                      }
                    });
                  },
                  child: Text(
                      _selected.length == widget.contacts.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: const material.TextStyle(
                          color: material.Colors.yellow, fontSize: 12)),
                ),
                const Spacer(),
                Text('${_selected.length} selected',
                    style: GoogleFonts.inter(
                        color: material.Colors.grey[400], fontSize: 12)),
              ],
            ),
            const material.Divider(color: material.Colors.white10),
            Expanded(
              child: material.ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final isSelected = _selected.contains(contact);
                  return material.ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(contact);
                        } else {
                          _selected.add(contact);
                        }
                      });
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? material.Colors.yellow
                            : material.Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? material.Colors.black
                                : material.Colors.white,
                          ),
                        ),
                      ),
                    ),
                    title: material.Text(contact.displayName,
                        style: GoogleFonts.inter(
                            color: material.Colors.white,
                            fontWeight: FontWeight.w500)),
                    subtitle: material.Text(contact.phones.first.number,
                        style: GoogleFonts.inter(
                            color: material.Colors.grey[500], fontSize: 12)),
                    trailing: Checkbox(
                      checked: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(contact);
                          } else {
                            _selected.add(contact);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, _selected),
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(
                      _selected.isEmpty ? Colors.grey : material.Colors.yellow),
                ),
                child: Text('Add to Queue (${_selected.length})',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: _selected.isEmpty
                            ? material.Colors.white
                            : material.Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
