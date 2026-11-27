import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_spend_page.dart';
import 'pocketgang_tool_storage.dart';

/// 💸 Split Bill & Shared Wishlist (Solo = Local, 2+ Members = Global Sync)
class PocketGangSplitWishlistWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangSplitWishlistWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    this.memberCount = 1,
    this.coupleTheme,
  });

  @override
  State<PocketGangSplitWishlistWidget> createState() =>
      _PocketGangSplitWishlistWidgetState();
}

class _PocketGangSplitWishlistWidgetState
    extends State<PocketGangSplitWishlistWidget> {
  static const String _splitsType = 'gang_split_bills';
  static const String _wishType = 'gang_shared_wishlist';

  int _subTab = 0; // 0 = Split Bill, 1 = Wishlist
  List<Map<String, dynamic>> _splits = [];
  List<Map<String, dynamic>> _wishlist = [];
  bool _isLoading = true;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final splits = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: _splitsType,
      memberCount: widget.memberCount,
    );
    final wish = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: _wishType,
      memberCount: widget.memberCount,
    );
    if (!mounted) return;
    setState(() {
      _splits = splits;
      _wishlist = wish;
      _isLoading = false;
    });
  }

  Future<void> _addEntry() async {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (title.isEmpty) return;

    HapticFeedback.mediumImpact();
    _titleCtrl.clear();
    _amountCtrl.clear();

    if (_subTab == 0) {
      final people = widget.memberCount < 2 ? 2 : widget.memberCount;
      setState(() {
        _splits.insert(0, {
          'id': 's_${DateTime.now().millisecondsSinceEpoch}',
          'title': title,
          'amount': amount,
          'people': people,
          'settled': false,
        });
      });
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId,
        activityType: _splitsType,
        title: 'Split Bills',
        userId: widget.currentUserId,
        memberCount: widget.memberCount,
        items: _splits,
      );
    } else {
      setState(() {
        _wishlist.insert(0, {
          'id': 'w_${DateTime.now().millisecondsSinceEpoch}',
          'title': title,
          'price': amount,
          'bought': false,
        });
      });
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId,
        activityType: _wishType,
        title: 'Shared Wishlist',
        userId: widget.currentUserId,
        memberCount: widget.memberCount,
        items: _wishlist,
      );
    }
  }

  Future<void> _toggleItem(int index) async {
    HapticFeedback.selectionClick();
    if (_subTab == 0) {
      final item = Map<String, dynamic>.from(_splits[index]);
      item['settled'] = !(item['settled'] == true);
      setState(() => _splits[index] = item);
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId,
        activityType: _splitsType,
        title: 'Split Bills',
        userId: widget.currentUserId,
        memberCount: widget.memberCount,
        items: _splits,
      );
    } else {
      final item = Map<String, dynamic>.from(_wishlist[index]);
      item['bought'] = !(item['bought'] == true);
      setState(() => _wishlist[index] = item);
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId,
        activityType: _wishType,
        title: 'Shared Wishlist',
        userId: widget.currentUserId,
        memberCount: widget.memberCount,
        items: _wishlist,
      );
    }
  }

  Future<void> _deleteItem(int index) async {
    HapticFeedback.lightImpact();
    if (_subTab == 0) {
      setState(() => _splits.removeAt(index));
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId,
        activityType: _splitsType,
        title: 'Split Bills',
        userId: widget.currentUserId,
        memberCount: widget.memberCount,
        items: _splits,
      );
    } else {
      setState(() => _wishlist.removeAt(index));
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId,
        activityType: _wishType,
        title: 'Shared Wishlist',
        userId: widget.currentUserId,
        memberCount: widget.memberCount,
        items: _wishlist,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bgColor = theme?.bgGradient.first ?? const Color(0xFF0F111A);
    final headerBg = theme?.cardColor ?? const Color(0xFF161924);
    final inputBg = theme?.surfaceAltColor ?? const Color(0xFF1E2232);
    final textColor = theme?.textColor ?? Colors.white;
    final subTextColor = theme?.subTextColor ?? Colors.white54;
    final accentColor = theme?.accent ?? const Color(0xFFF59E0B);
    final onAccentColor = theme?.onAccentTextColor ?? Colors.black;
    final borderColor =
        theme?.borderColor ?? Colors.white.withValues(alpha: 0.08);
    final isShared =
        PocketGangToolStorage.isSharedGroup(widget.groupId, widget.memberCount);

    final activeList = _subTab == 0 ? _splits : _wishlist;

    return Container(
      color: bgColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subTab == 0 ? 'Split Bill' : 'Shared Wishlist',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isShared ? 'Shared Sync' : 'Local Only',
                        style: GoogleFonts.outfit(
                            color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ToggleButtons(
                  isSelected: [_subTab == 0, _subTab == 1],
                  onPressed: (i) => setState(() => _subTab = i),
                  borderRadius: BorderRadius.circular(10),
                  fillColor: accentColor,
                  selectedColor: onAccentColor,
                  color: subTextColor,
                  constraints:
                      const BoxConstraints(minHeight: 32, minWidth: 74),
                  children: const [
                    Text('Split',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Wishlist',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _titleCtrl,
                      style: GoogleFonts.outfit(color: textColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: _subTab == 0 ? 'Bill item...' : 'Wish item...',
                        hintStyle: GoogleFonts.outfit(
                            color: subTextColor, fontSize: 12.5),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(color: textColor, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: '₹',
                        hintStyle: GoogleFonts.outfit(
                            color: subTextColor, fontSize: 12.5),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addEntry(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addEntry,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add, color: onAccentColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : activeList.isEmpty
                    ? Center(
                        child: Text(
                          _subTab == 0
                              ? 'No bills added yet.'
                              : 'No wishlist items yet.',
                          style: GoogleFonts.outfit(
                              color: subTextColor, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: activeList.length,
                        itemBuilder: (context, index) {
                          final item = activeList[index];
                          final isDone = _subTab == 0
                              ? item['settled'] == true
                              : item['bought'] == true;
                          final amt =
                              ((item['amount'] ?? item['price']) as num?)
                                      ?.toDouble() ??
                                  0.0;
                          final people =
                              (item['people'] as num?)?.toInt() ?? 2;
                          final perPerson = people > 0 ? amt / people : amt;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: headerBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: ListTile(
                              onTap: () => _toggleItem(index),
                              leading: Icon(
                                isDone
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isDone ? accentColor : subTextColor,
                              ),
                              title: Text(
                                item['title']?.toString() ?? '',
                                style: GoogleFonts.outfit(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                _subTab == 0
                                    ? 'Total ₹${amt.toStringAsFixed(0)} • ₹${perPerson.toStringAsFixed(0)} / person'
                                    : (amt > 0
                                        ? 'Est. ₹${amt.toStringAsFixed(0)}'
                                        : 'Wishlist item'),
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: subTextColor, size: 18),
                                onPressed: () => _deleteItem(index),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
