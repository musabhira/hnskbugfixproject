import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';

class ChessMatchmakingPage extends StatefulWidget {
  const ChessMatchmakingPage({Key? key}) : super(key: key);

  @override
  _ChessMatchmakingPageState createState() => _ChessMatchmakingPageState();
}

class _ChessMatchmakingPageState extends State<ChessMatchmakingPage> {
  bool _isSearching = false;
  List<Map<String, dynamic>> _onlineUsers = [];
  Timer? _searchTimer;
  RealtimeChannel? _gameChannel;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _myUserId = SupaFlow.client.auth.currentUser?.id;
    _fetchOnlineUsers();
    // listen for incoming challenges
    _gameChannel = SupaFlow.client.channel('public:chess_challenges');
    _gameChannel!.onBroadcast(
        event: 'challenge',
        callback: (payload) {
          if (payload['targetId'] == _myUserId) {
            _showChallengeDialog(
                payload['challengerId'], payload['challengerName']);
          }
        });
    _gameChannel!.onBroadcast(
        event: 'accept',
        callback: (payload) {
          if (payload['targetId'] == _myUserId) {
            _startGame(payload['matchId'], true);
          }
        });
    _gameChannel!.subscribe();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _gameChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchOnlineUsers() async {
    if (_myUserId == null) return;
    try {
      final res = await SupaFlow.client
          .from('users')
          .select('id, display_name, photo_url')
          .neq('id', _myUserId!);
      if (mounted) {
        setState(() {
          _onlineUsers = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  void _sendChallenge(String targetId) {
    if (_myUserId == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Challenge sent...')));
    _gameChannel!.sendBroadcastMessage(
      event: 'challenge',
      payload: {
        'challengerId': _myUserId,
        'challengerName': 'Player', // Fetch actual name if available
        'targetId': targetId,
      },
    );
  }

  void _showChallengeDialog(String challengerId, String challengerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const ui.Color(0xFF2C2C2C),
        title: const Text('New Chess Challenge!',
            style: TextStyle(color: Colors.white)),
        content: Text('$challengerName challenged you to a game of Chess.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Decline',
                style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final matchId = '${_myUserId}_$challengerId';
              _gameChannel!.sendBroadcastMessage(
                event: 'accept',
                payload: {
                  'targetId': challengerId,
                  'matchId': matchId,
                },
              );
              _startGame(matchId, false);
            },
            child: const Text('Accept',
                style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  void _startGame(String matchId, bool isWhite) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChessPlayPage(matchId: matchId, isWhite: isWhite),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const ui.Color(0xFF161618),
      appBar: AppBar(
        title: Text('Chess Matchmaking',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  setState(() => _isSearching = !_isSearching);
                  if (_isSearching) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Scanning for active players...')));
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _isSearching
                        ? Colors.redAccent.withValues(alpha: 0.2)
                        : Colors.amberAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _isSearching
                            ? Colors.redAccent
                            : Colors.amberAccent),
                  ),
                  child: Center(
                    child: Text(
                      _isSearching
                          ? 'Stop Scanning'
                          : 'Scan for Random Opponent',
                      style: GoogleFonts.outfit(
                        color: _isSearching
                            ? Colors.redAccent
                            : Colors.amberAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Online Users',
                    style: GoogleFonts.outfit(
                        color: Colors.white54, fontSize: 16)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _onlineUsers.length,
                itemBuilder: (context, index) {
                  final user = _onlineUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['photo_url'] != null
                          ? NetworkImage(user['photo_url'])
                          : null,
                      child: user['photo_url'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user['display_name'] ?? 'Unknown User',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: const Text('Online for Chess',
                        style:
                            TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent),
                      onPressed: () => _sendChallenge(user['id']),
                      child: const Text('Challenge',
                          style: TextStyle(color: Colors.black)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChessPlayPage extends StatefulWidget {
  final String matchId;
  final bool isWhite;

  const ChessPlayPage({Key? key, required this.matchId, required this.isWhite})
      : super(key: key);

  @override
  _ChessPlayPageState createState() => _ChessPlayPageState();
}

class _ChessPlayPageState extends State<ChessPlayPage> {
  final ChessBoardController _controller = ChessBoardController();
  RealtimeChannel? _moveChannel;

  @override
  void initState() {
    super.initState();
    _moveChannel =
        SupaFlow.client.channel('public:chess_moves_${widget.matchId}');
    _moveChannel!.onBroadcast(
        event: 'move',
        callback: (payload) {
          if (payload['fen'] != null &&
              payload['senderId'] != SupaFlow.client.auth.currentUser?.id) {
            _controller.loadFen(payload['fen']);
          }
        });
    _moveChannel!.subscribe();

    _controller.addListener(() {
      if (_controller.isCheckMate() || _controller.isDraw()) return;
      // Broadcast fen on local move changes only (not incoming)
    });
  }

  @override
  void dispose() {
    _moveChannel?.unsubscribe();
    _controller.dispose();
    super.dispose();
  }

  void _onMove() {
    _moveChannel!.sendBroadcastMessage(
      event: 'move',
      payload: {
        'fen': _controller.getFen(),
        'senderId': SupaFlow.client.auth.currentUser?.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const ui.Color(0xFF161618),
      appBar: AppBar(
        title: Text('Playing Chess',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ChessBoard(
          controller: _controller,
          boardColor: BoardColor.brown,
          boardOrientation:
              widget.isWhite ? PlayerColor.white : PlayerColor.black,
          onMove: () {
            _onMove();
          },
        ),
      ),
    );
  }
}
