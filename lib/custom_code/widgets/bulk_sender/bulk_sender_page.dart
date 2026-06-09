import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;

class BulkSenderPage extends StatefulWidget {
  const BulkSenderPage({super.key});

  @override
  State<BulkSenderPage> createState() => _BulkSenderPageState();
}

class _BulkSenderPageState extends State<BulkSenderPage>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _numbersController = TextEditingController();

  // API Mode Controllers
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiTokenController = TextEditingController();
  bool _useApiMode = false;

  List<String> _numbersList = [];
  bool _isAutoSending = false;
  int _currentIndex = -1;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _numbersController.dispose();
    _apiUrlController.dispose();
    _apiTokenController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _isAutoSending &&
        !_useApiMode &&
        _currentIndex >= 0) {
      // Small delay to ensure app is ready
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _processNext();
        }
      });
    }
  }

  Future<void> _pickContacts() async {
    if (await FlutterContacts.permissions.request(PermissionType.read) == PermissionStatus.granted) {
      final contacts = await FlutterContacts.getAll(
          properties: {ContactProperty.name, ContactProperty.phone});
      if (mounted) {
        material
            .showDialog<List<Contact>>(
          context: context,
          builder: (context) => MultiContactPickerDialog(contacts: contacts),
        )
            .then((selected) {
          if (selected != null && selected.isNotEmpty) {
            setState(() {
              final newNumbers = selected
                  .map((c) => c.phones.isNotEmpty ? c.phones.first.number : '')
                  .where((n) => n.isNotEmpty)
                  .join('\n');

              if (_numbersController.text.isEmpty) {
                _numbersController.text = newNumbers;
              } else {
                _numbersController.text += '\n$newNumbers';
              }
            });
          }
        });
      }
    } else {
      _showError('Permission denied');
    }
  }

  void _showError(String msg) {
    material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(
        content: Text(msg),
        backgroundColor: material.Colors.red,
      ),
    );
  }

  void _showSuccessInfo() {
    material.ScaffoldMessenger.of(context).showSnackBar(
      const material.SnackBar(
        content: Text('All messages sent successfully!'),
        backgroundColor: material.Colors.green,
        behavior: material.SnackBarBehavior.floating,
      ),
    );
  }

  void _startAutoSend() {
    final text = _numbersController.text.trim();
    if (text.isEmpty) {
      _showError('Please enter numbers');
      return;
    }

    _numbersList = text
        .split('\n')
        .map((e) => e.replaceAll(RegExp(r'[^\d+]'), ''))
        .where((e) => e.length > 5)
        .toList();

    if (_numbersList.isEmpty) {
      _showError('No valid numbers found');
      return;
    }

    setState(() {
      _currentIndex = 0;
      _isAutoSending = true;
      _showProgress = true;
    });

    if (_useApiMode) {
      _sendViaApi(_numbersList[_currentIndex]);
    } else {
      _sendToNumber(_numbersList[_currentIndex]);
    }
  }

  Future<void> _sendViaApi(String number) async {
    if (_apiUrlController.text.isEmpty || _apiTokenController.text.isEmpty) {
      _showError('API URL and Token are required for API Mode');
      setState(() {
        _isAutoSending = false;
        _showProgress = false;
      });
      return;
    }

    final message = _messageController.text;
    final url = Uri.parse(_apiUrlController.text);

    try {
      final response = await http.post(url, body: {
        'token': _apiTokenController.text,
        'to': number,
        'body': message,
      });

      if (response.statusCode == 200) {
        // Automatically move to next after 1.5 second delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _isAutoSending) {
            _processNext();
          }
        });
      } else {
        throw Exception('Failed to send: ${response.body}');
      }
    } catch (e) {
      _showError('API Error: $e');
      setState(() {
        _isAutoSending = false;
        _showProgress = false;
      });
    }
  }

  void _sendToNumber(String number) async {
    final message = Uri.encodeComponent(_messageController.text);
    final whatsappUrl = "whatsapp://send?phone=$number&text=$message";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not launch WhatsApp');
    }
  }

  void _processNext() {
    if (_currentIndex < _numbersList.length - 1) {
      setState(() {
        _currentIndex++;
      });

      if (_useApiMode) {
        _sendViaApi(_numbersList[_currentIndex]);
      } else {
        // For manual mode, wait for user to return (lifecycle handles this)
        _sendToNumber(_numbersList[_currentIndex]);
      }
    } else {
      setState(() {
        _isAutoSending = false;
        _currentIndex = -1;
      });
      _showSuccessInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showProgress) {
      return _buildProgressView();
    }

    return material.Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: material.AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Bulk Sender Pro',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: material.Colors.white)),
        leading: material.IconButton(
          icon: const Icon(material.Icons.arrow_back, size: 16),
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
            _buildModeToggle(),
            if (_useApiMode) _buildApiSettings(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recipient Numbers',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: material.Colors.grey[400])),
                material.IconButton(
                  icon: const Icon(material.Icons.contact_page,
                      color: material.Colors.yellow, size: 20),
                  onPressed: _pickContacts,
                ),
              ],
            ),
            const SizedBox(height: 8),
            material.TextField(
              controller: _numbersController,
              maxLines: 5,
              style: const material.TextStyle(color: material.Colors.white),
              decoration: material.InputDecoration(
                hintText: 'Enter numbers (one per line)...',
                hintStyle: material.TextStyle(color: material.Colors.grey[600]),
                filled: true,
                fillColor: material.Colors.white.withValues(alpha: 0.05),
                border: material.OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: material.BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Text('Message Content',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: material.Colors.grey[400])),
            const SizedBox(height: 8),
            material.TextField(
              controller: _messageController,
              maxLines: 8,
              style: const material.TextStyle(color: material.Colors.white),
              decoration: material.InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: material.TextStyle(color: material.Colors.grey[600]),
                filled: true,
                fillColor: material.Colors.white.withValues(alpha: 0.05),
                border: material.OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: material.BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _startAutoSend,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(material.Colors.yellow),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
                ),
                child: Text('Start Bulk Sending',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: material.Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: material.Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: material.Border.all(
            color: material.Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(material.Icons.info_outline, color: material.Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Automate your outreach. Add numbers, set your message, and let the tool do the rest.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: material.Colors.blue[100]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: material.Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Switch(
            value: _useApiMode,
            onChanged: (v) => setState(() => _useApiMode = v),
            activeColor: material.Colors.yellow,
          ),
          const SizedBox(width: 12),
          Text(
            _useApiMode
                ? 'API Mode (Automated Background)'
                : 'Manual Mode (via WhatsApp App)',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: material.Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildApiSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('API Configuration (WhatsApp Gateway)',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: material.Colors.yellow,
                fontSize: 13)),
        const SizedBox(height: 8),
        material.TextField(
          controller: _apiUrlController,
          style: const material.TextStyle(color: material.Colors.white, fontSize: 13),
          decoration: material.InputDecoration(
            hintText: 'Instance URL (e.g., https://api.ultramsg.com/...)',
            filled: true,
            fillColor: material.Colors.white.withValues(alpha: 0.05),
            border: material.OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        material.TextField(
          controller: _apiTokenController,
          style: const material.TextStyle(color: material.Colors.white, fontSize: 13),
          decoration: material.InputDecoration(
            hintText: 'API Token',
            filled: true,
            fillColor: material.Colors.white.withValues(alpha: 0.05),
            border: material.OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressView() {
    final progress = (_currentIndex + 1) / _numbersList.length;
    final remaining = _numbersList.length - (_currentIndex + 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
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
              LinearProgressIndicator(value: progress, color: material.Colors.yellow, backgroundColor: material.Colors.grey[800]),
              const SizedBox(height: 24),
              if (!_isAutoSending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showProgress = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: material.Colors.white,
                          side: const BorderSide(color: material.Colors.white38),
                        ),
                        child: const Text('Reset'),
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

  const MultiContactPickerDialog({super.key, required this.contacts});

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
                (c.displayName ?? '').toLowerCase().contains(query.toLowerCase()) ||
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
                  icon: const Icon(material.Icons.close, size: 12),
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
                prefixIcon: const Icon(material.Icons.search,
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
                          (contact.displayName ?? '').isNotEmpty
                              ? (contact.displayName ?? '')[0].toUpperCase()
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
                    title: material.Text(contact.displayName ?? 'Unknown',
                        style: GoogleFonts.inter(
                            color: material.Colors.white,
                            fontWeight: FontWeight.w500)),
                    subtitle: material.Text(
                        contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : 'No number',
                        style: GoogleFonts.inter(
                            color: material.Colors.grey[500], fontSize: 12)),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: material.Colors.yellow,
                      checkColor: material.Colors.black,
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
                  backgroundColor: WidgetStateProperty.all(
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
