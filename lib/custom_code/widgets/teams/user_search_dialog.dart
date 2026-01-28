import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'dart:async';

class UserSearchDialog extends StatefulWidget {
  final Function(List<UserResult>) onUsersSelected;
  final bool multipleSelection;

  const UserSearchDialog({
    Key? key,
    required this.onUsersSelected,
    this.multipleSelection = true,
  }) : super(key: key);

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TeamsService _service = TeamsService();
  List<UserResult> _searchResults = [];
  List<UserResult> _selectedUsers = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }

  void _search(String query) async {
    if (query.length < 2) return;
    setState(() => _isLoading = true);
    try {
      final results = await _service.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _toggleUser(UserResult user) {
    setState(() {
      if (widget.multipleSelection) {
        if (_selectedUsers.any((u) => u.userId == user.userId)) {
          _selectedUsers.removeWhere((u) => u.userId == user.userId);
        } else {
          _selectedUsers.add(user);
        }
      } else {
        _selectedUsers = [user]; // Single select
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title:
          Text('Search Users', style: GoogleFonts.outfit(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Type name to search...',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.yellow),
                  onPressed: () => _search(_searchController.text),
                ),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow)),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 16),
            if (_selectedUsers.isNotEmpty)
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _selectedUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(user.name,
                            style: const TextStyle(color: Colors.black)),
                        backgroundColor: Colors.yellow,
                        deleteIcon: const Icon(Icons.close,
                            size: 16, color: Colors.black),
                        onDeleted: () => _toggleUser(user),
                      ),
                    );
                  },
                ),
              ),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.yellow))
                : SizedBox(
                    height: 200, // Limit height
                    child: _searchResults.isEmpty &&
                            _searchController.text.length >= 2
                        ? const Center(
                            child: Text("No users found",
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              final isSelected = _selectedUsers
                                  .any((u) => u.userId == user.userId);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!)
                                      : null,
                                  backgroundColor: Colors.grey[800],
                                  child: user.profileImageUrl == null
                                      ? Text(user.name[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white))
                                      : null,
                                ),
                                title: Text(user.name,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                subtitle: user.email != null
                                    ? Text(user.email!,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12))
                                    : null,
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.yellow)
                                    : const Icon(Icons.circle_outlined,
                                        color: Colors.grey),
                                onTap: () => _toggleUser(user),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUsersSelected(_selectedUsers);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
          ),
          child: Text('Select (${_selectedUsers.length})'),
        ),
      ],
    );
  }
}
