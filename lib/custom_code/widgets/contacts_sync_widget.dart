import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/database/database.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsSyncWidget extends StatefulWidget {
  final String currentUserId;

  const ContactsSyncWidget({
    super.key,
    required this.currentUserId,
  });

  @override
  State<ContactsSyncWidget> createState() => _ContactsSyncWidgetState();
}

class _ContactsSyncWidgetState extends State<ContactsSyncWidget> {
  final supabase = SupaFlow.client;
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _contactsFetched = false;

  List<Map<String, dynamic>> _matchedContacts = [];
  List<Contact> _unmatchedContacts = [];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final status = await FlutterContacts.permissions.request(PermissionType.read);
      final hasPerm = status == PermissionStatus.granted || status == PermissionStatus.limited;
      setState(() {
        _hasPermission = hasPerm;
      });
      if (hasPerm) {
        _fetchAndMatchContacts();
      }
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  Future<void> _fetchAndMatchContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contacts = await FlutterContacts.getAll(properties: {ContactProperty.phone});
      
      final Map<String, Contact> phoneToContact = {};
      final List<String> allPhones = [];

      for (var contact in contacts) {
        if (contact.phones.isNotEmpty) {
          // Just take the first phone number for simplicity
          final phone = _cleanPhoneNumber(contact.phones.first.number);
          if (phone.length >= 7) {
            // Keep original phone to maybe try exact match or right-side match
            // Supabase querying with ILIKE or textSearch might be tricky for partials
            // We will just do exact matches on cleaned strings.
            phoneToContact[phone] = contact;
            allPhones.add(phone);
          }
        }
      }

      if (allPhones.isEmpty) {
        setState(() {
          _isLoading = false;
          _contactsFetched = true;
        });
        return;
      }

      // Fetch from Supabase
      // Assuming phone_no is stored with country code, we might need a smart match.
      // But for now, let's fetch all users that have phone_no set and check locally.
      // Doing a huge IN query might fail if there are thousands of contacts.
      // Let's query in batches of 100.
      
      List<Map<String, dynamic>> matchedProfiles = [];
      
      // (Optional) Batch queries can be implemented here if DB grows large
      
      // Actually, a better approach is to fetch all profiles with phone numbers from DB
      // Or send the list of phones to an RPC.
      // Since we don't have an RPC for this, we will fetch profiles that have phone_no not null.
      // This is not scalable if the DB is huge, but it works for MVP.
      final response = await supabase
          .from('profile')
          .select('user_id, name, profile_image_url, phone_no')
          .neq('phone_no', '')
          .not('phone_no', 'is', null);

      final List<Map<String, dynamic>> dbProfiles = List<Map<String, dynamic>>.from(response);

      for (var dbProfile in dbProfiles) {
        final dbPhone = _cleanPhoneNumber(dbProfile['phone_no'].toString());
        if (dbPhone.isEmpty) continue;

        // Try to find a match in local contacts
        // Match if last 10 digits match
        final dbPhoneEnd = dbPhone.length > 10 ? dbPhone.substring(dbPhone.length - 10) : dbPhone;
        
        String? matchedLocalPhone;
        for (var localPhone in allPhones) {
          final localPhoneEnd = localPhone.length > 10 ? localPhone.substring(localPhone.length - 10) : localPhone;
          if (dbPhoneEnd == localPhoneEnd) {
            matchedLocalPhone = localPhone;
            break;
          }
        }

        if (matchedLocalPhone != null) {
          // Matched!
          // Add contact name to profile data
          dbProfile['contact_name'] = phoneToContact[matchedLocalPhone]!.displayName;
          
          // Don't show current user
          if (dbProfile['user_id'] != widget.currentUserId) {
            matchedProfiles.add(dbProfile);
          }
          phoneToContact.remove(matchedLocalPhone);
        }
      }

      setState(() {
        _matchedContacts = matchedProfiles;
        _unmatchedContacts = phoneToContact.values.toList();
        // sort by display name
        _matchedContacts.sort((a, b) => (a['contact_name']?.toString() ?? '').compareTo(b['contact_name']?.toString() ?? ''));
        _unmatchedContacts.sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));
        
        _isLoading = false;
        _contactsFetched = true;
      });

    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _inviteContact(Contact contact) async {
    final phone = _cleanPhoneNumber(contact.phones.first.number);
    final message = "Join me on Pocketmates! Let's connect: https://pocketmates.app";
    final url = Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback
      final whatsappUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      }
    }
  }

  Widget _buildMatchedContactTile(Map<String, dynamic> profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = profile['profile_image_url'] as String?;
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        backgroundColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
        child: avatarUrl == null || avatarUrl.isEmpty
            ? Text(
                profile['name'].toString().isNotEmpty ? profile['name'].toString()[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(profile['contact_name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text('Pocketmates: ${profile['name']}', style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () {
          // Open direct chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WhatsAppGroupChat(
                groupId: 'p:${profile['user_id']}',
                groupName: profile['name'],
                groupImage: avatarUrl,
              ),
            ),
          );
        },
        child: Text('Message', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildUnmatchedContactTile(Contact contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        child: Text(
          (contact.displayName?.isNotEmpty ?? false) ? contact.displayName![0].toUpperCase() : '?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(contact.displayName ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : '', style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
          side: BorderSide(color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () => _inviteContact(contact),
        child: Text('Invite', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!_hasPermission) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.contacts, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Find Your Friends',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Sync your contacts to find people you know on Pocketmates.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
              ),
              onPressed: _checkPermission,
              child: const Text('Sync Contacts'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00))),
      );
    }

    if (_contactsFetched) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_matchedContacts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Contacts on Pocketmates',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _matchedContacts.length,
              itemBuilder: (context, index) {
                return _buildMatchedContactTile(_matchedContacts[index]);
              },
            ),
          ],
          
          if (_unmatchedContacts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Invite to Pocketmates',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _unmatchedContacts.length > 20 ? 20 : _unmatchedContacts.length, // Limit to 20 for performance in a SliverList
              itemBuilder: (context, index) {
                return _buildUnmatchedContactTile(_unmatchedContacts[index]);
              },
            ),
            if (_unmatchedContacts.length > 20)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Optionally push a full screen page to show all contacts
                    },
                    child: Text('View More Contacts', style: GoogleFonts.outfit(color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00))),
                  ),
                ),
              ),
          ],
        ],
      );
    }

    return const SizedBox();
  }
}
