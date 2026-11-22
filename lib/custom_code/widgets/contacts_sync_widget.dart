import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/database/database.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:share_plus/share_plus.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _matchedContacts = [];
  List<Contact> _unmatchedContacts = [];

  static const String _inviteLink =
      'https://play.google.com/store/apps/details?id=com.poketmates.app';

  @override
  void initState() {
    super.initState();
    _checkPermissionSilently();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionSilently() async {
    try {
      final status =
          await FlutterContacts.permissions.check(PermissionType.read);
      final hasPerm = status == PermissionStatus.granted ||
          status == PermissionStatus.limited;
      if (mounted) {
        setState(() {
          _hasPermission = hasPerm;
        });
        if (hasPerm) {
          _fetchAndMatchContacts();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
        });
      }
    }
  }

  Future<void> _requestPermissionWithDisclosure() async {
    try {
      final granted =
          await ContactsNameService.requestContactsWithDisclosure(context);
      if (mounted) {
        setState(() {
          _hasPermission = granted;
        });
        if (granted) {
          _fetchAndMatchContacts();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    }
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  String _getInviteMessage(String contactName) {
    final greeting =
        contactName.trim().isNotEmpty ? 'Hey $contactName!' : 'Hey!';
    return '$greeting I\'m learning and practicing spoken English on Pocket Mates app. Join me and let\'s practice together!\n\nDownload here: $_inviteLink';
  }

  Future<void> _fetchAndMatchContacts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final contacts =
          await FlutterContacts.getAll(properties: {ContactProperty.phone});

      final Map<String, Contact> phoneToContact = {};
      final List<String> allPhones = [];

      for (var contact in contacts) {
        if (contact.phones.isNotEmpty) {
          final phone = _cleanPhoneNumber(contact.phones.first.number);
          if (phone.length >= 7) {
            phoneToContact[phone] = contact;
            allPhones.add(phone);
          }
        }
      }

      if (allPhones.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _contactsFetched = true;
          });
        }
        return;
      }

      final response = await supabase
          .from('profile')
          .select('user_id, name, profile_image_url, phone_no')
          .neq('phone_no', '')
          .not('phone_no', 'is', null);

      final List<Map<String, dynamic>> dbProfiles =
          List<Map<String, dynamic>>.from(response);

      List<Map<String, dynamic>> matchedProfiles = [];

      for (var dbProfile in dbProfiles) {
        final dbPhone = _cleanPhoneNumber(dbProfile['phone_no'].toString());
        if (dbPhone.isEmpty) continue;

        final dbPhoneEnd =
            dbPhone.length > 10 ? dbPhone.substring(dbPhone.length - 10) : dbPhone;

        String? matchedLocalPhone;
        for (var localPhone in allPhones) {
          final localPhoneEnd = localPhone.length > 10
              ? localPhone.substring(localPhone.length - 10)
              : localPhone;
          if (dbPhoneEnd == localPhoneEnd) {
            matchedLocalPhone = localPhone;
            break;
          }
        }

        if (matchedLocalPhone != null) {
          final matchedContact = phoneToContact[matchedLocalPhone];
          final savedName = matchedContact?.displayName ?? dbProfile['name'] ?? 'Friend';
          dbProfile['contact_name'] = savedName;

          // Register in singleton service cache
          final uid = dbProfile['user_id']?.toString() ?? '';
          if (uid.isNotEmpty) {
            ContactsNameService().registerUserId(uid, savedName);
          }

          if (uid != widget.currentUserId) {
            matchedProfiles.add(dbProfile);
          }
          phoneToContact.remove(matchedLocalPhone);
        }
      }

      if (mounted) {
        setState(() {
          _matchedContacts = matchedProfiles;
          _unmatchedContacts = phoneToContact.values.toList();
          _matchedContacts.sort((a, b) => (a['contact_name']?.toString() ?? '')
              .compareTo(b['contact_name']?.toString() ?? ''));
          _unmatchedContacts.sort(
              (a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));

          _isLoading = false;
          _contactsFetched = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showInviteOptions(Contact contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = contact.displayName ?? 'Friend';
    final rawPhone =
        contact.phones.isNotEmpty ? contact.phones.first.number : '';
    final cleanPhone = _cleanPhoneNumber(rawPhone);
    final message = _getInviteMessage(name);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFFFFC00),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite $name',
                          style: GoogleFonts.outfit(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (rawPhone.isNotEmpty)
                          Text(
                            rawPhone,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // WhatsApp option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF25D366),
                    size: 22,
                  ),
                ),
                title: Text(
                  'WhatsApp',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Send direct invitation via WhatsApp',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final digits = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');
                  final waUrl = Uri.parse(
                      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}');
                  if (await canLaunchUrl(waUrl)) {
                    await launchUrl(waUrl,
                        mode: LaunchMode.externalApplication);
                  } else {
                    await Share.share(message);
                  }
                },
              ),
              // SMS option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    color: Color(0xFF38BDF8),
                    size: 22,
                  ),
                ),
                title: Text(
                  'SMS Message',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Send SMS text message to this contact',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final smsUrl = Uri(
                    scheme: 'sms',
                    path: cleanPhone,
                    queryParameters: {'body': message},
                  );
                  if (await canLaunchUrl(smsUrl)) {
                    await launchUrl(smsUrl);
                  } else {
                    await Share.share(message);
                  }
                },
              ),
              // Share Link option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Color(0xFFFFB300),
                    size: 22,
                  ),
                ),
                title: Text(
                  'Share via Other Apps',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Share invite link through Telegram, Instagram, etc.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Share.share(message);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopShareCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite Friends & Practice English',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Build streaks and master spoken English together',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: Text(
                    'Share Invite Link',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () {
                    Share.share(_getInviteMessage('friend'));
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor:
                      isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                tooltip: 'Copy Link',
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: _inviteLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invite link copied to clipboard!',
                        style: GoogleFonts.outfit(fontSize: 13),
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF1E293B),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        style: GoogleFonts.outfit(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search contacts by name or phone...',
          hintStyle: GoogleFonts.outfit(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFFFFFC00),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchedContactTile(Map<String, dynamic> profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = profile['profile_image_url'] as String?;
    final contactName =
        profile['contact_name']?.toString() ?? profile['name']?.toString() ?? 'Friend';
    final accountName = profile['name']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2129) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              backgroundColor: const Color(0xFFFFFC00),
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                      contactName.isNotEmpty
                          ? contactName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E2129) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          contactName,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          accountName.isNotEmpty && accountName != contactName
              ? 'On Pocket Mates • @$accountName'
              : 'On Pocket Mates',
          style: GoogleFonts.outfit(
            color: const Color(0xFF38BDF8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFC00),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WhatsAppGroupChat(
                  groupId: 'p:${profile['user_id']}',
                  groupName: contactName,
                  groupImage: avatarUrl,
                  showBackButton: true,
                ),
              ),
            );
          },
          child: Text(
            'Message',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnmatchedContactTile(Contact contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = contact.displayName ?? 'Friend';
    final phone =
        contact.phones.isNotEmpty ? contact.phones.first.number : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2129) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          phone,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 12,
          ),
        ),
        trailing: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFFFC00),
            side: const BorderSide(color: Color(0xFFFFFC00), width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
          onPressed: () => _showInviteOptions(contact),
          child: Text(
            'Invite',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? const Color(0xFFFFFC00) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_hasPermission) {
      return Padding(
        padding: const EdgeInsets.all(22.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.contacts_rounded,
                  size: 30,
                  color: Color(0xFFFFB300),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Find Your Friends',
                style: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pocket Mates accesses your contacts to check if any of your friends are already practicing English here, and allows you to invite close friends to learn together.\n\nYour contacts are securely matched and are never sold or shared.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: Text(
                  'Sync Contacts',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: _requestPermissionWithDisclosure,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50.0),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
        ),
      );
    }

    if (_contactsFetched) {
      final q = _searchQuery.toLowerCase();
      final filteredMatched = _matchedContacts.where((c) {
        if (q.isEmpty) return true;
        final name = (c['contact_name'] ?? c['name'] ?? '').toString().toLowerCase();
        final phone = (c['phone_no'] ?? '').toString().toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();

      final filteredUnmatched = _unmatchedContacts.where((c) {
        if (q.isEmpty) return true;
        final name = (c.displayName ?? '').toLowerCase();
        final phones = c.phones.map((p) => p.number.toLowerCase()).join(' ');
        return name.contains(q) || phones.contains(q);
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopShareCard(isDark),
          _buildSearchBar(isDark),
          if (filteredMatched.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFFC00),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Friends on Pocket Mates (${filteredMatched.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredMatched.length,
              itemBuilder: (context, index) {
                return _buildMatchedContactTile(filteredMatched[index]);
              },
            ),
          ],
          if (filteredUnmatched.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.contact_phone_rounded,
                    color: Color(0xFF38BDF8),
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Invite from Contacts (${filteredUnmatched.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredUnmatched.length,
              itemBuilder: (context, index) {
                return _buildUnmatchedContactTile(filteredUnmatched[index]);
              },
            ),
          ],
          if (filteredMatched.isEmpty && filteredUnmatched.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  _searchQuery.isNotEmpty
                      ? 'No contacts found matching "$_searchQuery"'
                      : 'No contacts found',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      );
    }

    return const SizedBox();
  }
}
