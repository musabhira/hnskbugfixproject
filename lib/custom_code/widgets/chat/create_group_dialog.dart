import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

import 'package:image/image.dart'
    as img; // Ensure this package is in pubspec.yaml

class CreateGroupDialog extends StatefulWidget {
  final VoidCallback onGroupCreated;

  const CreateGroupDialog({Key? key, required this.onGroupCreated})
      : super(key: key);

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  Uint8List? _selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<dynamic> _searchResults = [];
  List<dynamic> _selectedMembers = [];

  bool _isCreating = false;
  bool _isSearching = false;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 95,
      );

      if (image != null) {
        safeSetState(() {
          _isImageUploading = true;
        });

        final originalBytes = await image.readAsBytes();

        final compressedBytes = await _compressImage(
          originalBytes,
          maxWidth: 512,
          maxHeight: 512,
          quality: 85,
        );

        if (compressedBytes != null) {
          safeSetState(() {
            _selectedImageBytes = compressedBytes;
            _isImageUploading = false;
          });

          final originalSize = (originalBytes.length / 1024).round();
          final compressedSize = (compressedBytes.length / 1024).round();
          final compressionRatio =
              ((1 - (compressedBytes.length / originalBytes.length)) * 100)
                  .round();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image compressed: ${originalSize}KB → ${compressedSize}KB ($compressionRatio% reduction)',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          safeSetState(() {
            _isImageUploading = false;
          });
          _showErrorSnackBar('Failed to process image');
        }
      }
    } catch (e) {
      safeSetState(() {
        _isImageUploading = false;
      });
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  Future<Uint8List?> _compressImage(
    Uint8List imageBytes, {
    int maxWidth = 512,
    int maxHeight = 512,
    int quality = 85,
  }) async {
    try {
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      double aspectRatio = originalImage.width / originalImage.height;
      int newWidth = maxWidth;
      int newHeight = maxHeight;

      if (aspectRatio > 1) {
        newHeight = (maxWidth / aspectRatio).round();
      } else {
        newWidth = (maxHeight * aspectRatio).round();
      }

      img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  void _removeImage() {
    safeSetState(() {
      _selectedImageBytes = null;
    });
  }

  Future<String?> _uploadImageToStorage(String groupId) async {
    if (_selectedImageBytes == null) return null;

    try {
      safeSetState(() {
        _isImageUploading = true;
      });

      final supabase = SupaFlow.client;
      final fileName =
          'group_${groupId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // We already have compressed bytes in _selectedImageBytes, but the original code re-compressed?
      // Let's use _selectedImageBytes directly as it was already compressed on selection.
      // Or re-compress if needed. The user code re-compressed. I'll stick to user logic but optimize if already compressed.
      // Actually, _selectedImageBytes is already compressed. Re-compressing is redundant unless we want to ensure format.
      // I'll trust _selectedImageBytes.

      final response = await supabase.storage
          .from('group-profileimagesorginal') // User provided bucket name
          .uploadBinary(fileName, _selectedImageBytes!);

      if (response.isNotEmpty) {
        final publicUrl = supabase.storage
            .from('group-profileimagesorginal')
            .getPublicUrl(fileName);

        return publicUrl;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      _showErrorSnackBar('Failed to upload image: $e');
      return null;
    } finally {
      safeSetState(() {
        _isImageUploading = false;
      });
    }
  }

  Future<void> _searchMembers(String query) async {
    if (query.trim().isEmpty) {
      safeSetState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    safeSetState(() {
      _isSearching = true;
    });

    try {
      final supabase = SupaFlow.client;
      final currentUserId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('profile')
          .select('id, name, shop_name, profile_image_url, city, user_id')
          .or('name.ilike.%$query%,shop_name.ilike.%$query%')
          .neq('user_id', currentUserId)
          .limit(10);

      safeSetState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
        _isSearching = false;
      });
    } catch (e) {
      safeSetState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('Error searching members: $e');
    }
  }

  void _addMember(Map<String, dynamic> member) {
    if (!_selectedMembers.any((m) => m['id'] == member['id'])) {
      safeSetState(() {
        _selectedMembers.add(member);
        _searchController.clear();
        _searchResults = [];
      });
    }
  }

  void _removeMember(String memberId) {
    safeSetState(() {
      _selectedMembers.removeWhere((m) => m['id'] == memberId);
    });
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a group name');
      return;
    }

    safeSetState(() {
      _isCreating = true;
    });

    try {
      final supabase = SupaFlow.client;
      final userId = supabase.auth.currentUser!.id;

      final profileResponse = await supabase
          .from('profile')
          .select('id')
          .eq('user_id', userId)
          .single();

      final currentUserProfileId = profileResponse['id'];

      final groupData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'created_by': userId,
        'is_public': false,
      };

      // Note: User code for inserting group with image data directly??
      // 'group_image_data': _selectedImageBytes
      // Supabase columns usually don't store raw bytes unless bytea.
      // Usually we upload to storage and store URL.
      // I will skip 'group_image_data' column unless the user has it.
      // The user code tried to do both: set bytes in insert, AND upload to storage later.
      // I'll stick to standard: insert group -> upload image -> update group with URL.

      final groupResponse =
          await supabase.from('groups').insert(groupData).select().single();

      final groupId = groupResponse['id'];

      String? imageUrl;
      if (_selectedImageBytes != null) {
        imageUrl = await _uploadImageToStorage(groupId.toString());

        if (imageUrl != null) {
          await supabase
              .from('groups')
              .update({'group_image_url': imageUrl}).eq('id', groupId);
        }
      }

      final membersToAdd = <Map<String, dynamic>>[];

      // Add creator as admin
      membersToAdd.add({
        'group_id': groupId,
        'profile_id': currentUserProfileId,
        'user_id': userId,
        'role': 'admin',
        'is_active': true,
      });

      for (final member in _selectedMembers) {
        membersToAdd.add({
          'group_id': groupId,
          'profile_id': member['id'],
          'user_id': member['user_id'],
          'role': 'member',
          'is_active': true,
        });
      }

      await supabase.from('group_members').insert(membersToAdd);

      widget.onGroupCreated();
      if (mounted) Navigator.of(context).pop();

      _showSuccessSnackBar(
        'Group "${_nameController.text.trim()}" created with ${_selectedMembers.length + 1} members!',
      );
    } catch (e) {
      debugPrint('Error creating group: $e');
      _showErrorSnackBar('Error creating group: $e');
    } finally {
      safeSetState(() {
        _isCreating = false;
      });
    }
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Group Image'),
            if (_selectedImageBytes != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.compress, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Compressed (${(_selectedImageBytes!.length / 1024).round()}KB)',
                      style: const TextStyle(color: Colors.green, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _isImageUploading ? null : _selectImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const ui.Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const ui.Color(0xFFFFD700),
                    width: 1,
                  ),
                ),
                child: _isImageUploading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: ui.Color(0xFFFFD700),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Compressing...',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      )
                    : _selectedImageBytes != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  color: ui.Color(0xFFFFD700), size: 32),
                              SizedBox(height: 8),
                              Text('Add Image',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: ui.Color(0xFFFFD700),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const ui.Color(0xFFFFD700)),
        filled: true,
        fillColor: const ui.Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ui.Color(0xFFFFD700),
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const ui.Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const ui.Color(0xFF404040)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          _searchMembers(value);
        },
        decoration: const InputDecoration(
          hintText: 'Search members by name or shop...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: ui.Color(0xFFFFD700)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSelectedMembers() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedMembers.map((member) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const ui.Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const ui.Color(0xFFFFD700)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const ui.Color(0xFFFFD700),
                    backgroundImage: member['profile_image_url'] != null
                        ? NetworkImage(member['profile_image_url'])
                        : null,
                    child: member['profile_image_url'] == null
                        ? Text(
                            (member['name'] ?? member['email'] ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member['name'] ??
                        member['shop_name'] ??
                        member['email'] ??
                        'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeMember(member['id']),
                    child: const Icon(Icons.close,
                        color: Colors.white70, size: 16),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: const ui.Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const ui.Color(0xFF404040)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final member = _searchResults[index];
          final isSelected =
              _selectedMembers.any((m) => m['id'] == member['id']);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const ui.Color(0xFFFFD700),
              backgroundImage: member['profile_image_url'] != null
                  ? NetworkImage(member['profile_image_url'])
                  : null,
              child: member['profile_image_url'] == null
                  ? Text(
                      (member['name'] ?? member['email'] ?? 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              member['name'] ??
                  member['shop_name'] ??
                  member['email'] ??
                  'Unknown',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: member['city'] != null
                ? Text(member['city'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12))
                : null,
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: ui.Color(0xFFFFD700))
                : const Icon(Icons.add_circle_outline, color: Colors.white54),
            onTap: isSelected ? null : () => _addMember(member),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isWeb ? 500 : screenWidth * 0.9,
          height: screenHeight * 0.8,
          decoration: BoxDecoration(
            color: const ui.Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const ui.Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const ui.Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ui.Color(0xFFFFD700), ui.Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group_add, color: Colors.black, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Create Group',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageUploadSection(),
                      const SizedBox(height: 8),
                      _buildSectionTitle('Group Name *'),
                      const SizedBox(height: 6),
                      _buildTextField(
                          controller: _nameController,
                          hintText: 'Enter group name',
                          icon: Icons.group),
                      const SizedBox(height: 8),
                      _buildSectionTitle('Description'),
                      const SizedBox(height: 6),
                      _buildTextField(
                          controller: _descriptionController,
                          hintText: 'Enter group description (optional)',
                          icon: Icons.description,
                          maxLines: 3),
                      const SizedBox(height: 8),
                      _buildSectionTitle('Add Members'),
                      const SizedBox(height: 6),
                      _buildSearchField(),
                      const SizedBox(height: 8),
                      if (_selectedMembers.isNotEmpty) ...[
                        _buildSectionTitle(
                            'Selected Members (${_selectedMembers.length})'),
                        const SizedBox(height: 6),
                        _buildSelectedMembers(),
                        const SizedBox(height: 8),
                      ],
                      if (_searchResults.isNotEmpty) ...[
                        _buildSectionTitle('Search Results'),
                        const SizedBox(height: 6),
                        _buildSearchResults(),
                      ],
                      if (_isSearching)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: ui.Color(0xFFFFD700)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ui.Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isCreating ? null : _createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const ui.Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2),
                            )
                          : const Text('Create Group',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
