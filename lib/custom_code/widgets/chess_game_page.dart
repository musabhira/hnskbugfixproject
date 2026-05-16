import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'ai_prompt_service.dart';

class ChessMatchmakingPage extends StatefulWidget {
  const ChessMatchmakingPage({super.key});

  @override
  State<ChessMatchmakingPage> createState() => _ChessMatchmakingPageState();
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
          if (payload['targetId'] == _myUserId && mounted) {
            _showChallengeDialog(
                payload['challengerId'], payload['challengerName']);
          }
        });
    _gameChannel!.onBroadcast(
        event: 'accept',
        callback: (payload) {
          if (payload['targetId'] == _myUserId && mounted) {
            _startGame(payload['matchId'], true,
                targetUserId: payload['challengerId']);
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
      // Use 'profile' table for better name availability
      final res = await SupaFlow.client
          .from('profile')
          .select('user_id, name, profile_image_url')
          .neq('user_id', _myUserId!);
      if (mounted) {
        setState(() {
          _onlineUsers = (res as List)
              .map((e) => {
                    'id': e['user_id'],
                    'display_name': e['name'] ?? 'Unknown User',
                    'photo_url': e['profile_image_url'],
                  })
              .toList();
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
                  'challengerId': _myUserId,
                  'matchId': matchId,
                },
              );
              _startGame(matchId, false, targetUserId: challengerId);
            },
            child: const Text('Accept',
                style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  void _startGame(String matchId, bool isWhite, {String? targetUserId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChessPlayPage(
            matchId: matchId,
            isWhite: isWhite,
            targetUserId: targetUserId,
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChessPlayPage(
                          matchId: 'ai_match',
                          isWhite: true,
                          isAi: true,
                        ),
                      ));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purpleAccent),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.smart_toy_rounded,
                            color: Colors.purpleAccent),
                        const SizedBox(width: 10),
                        Text(
                          'Play with AI Bot',
                          style: GoogleFonts.outfit(
                            color: Colors.purpleAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
  final bool isAi;
  final String? targetUserId;

  const ChessPlayPage({
    super.key,
    required this.matchId,
    required this.isWhite,
    this.isAi = false,
    this.targetUserId,
  });

  @override
  State<ChessPlayPage> createState() => _ChessPlayPageState();
}

class _ChessPlayPageState extends State<ChessPlayPage> {
  final ChessBoardController _controller = ChessBoardController();
  RealtimeChannel? _moveChannel;
  bool _isAiThinking = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isAi) {
      _moveChannel =
          SupaFlow.client.channel('public:chess_moves_${widget.matchId}');
      _moveChannel!.onBroadcast(
          event: 'move',
          callback: (payload) {
            if (payload['fen'] != null &&
                payload['senderId'] != SupaFlow.client.auth.currentUser?.id &&
                mounted) {
              _controller.loadFen(payload['fen']);
              setState(() {});
            }
          });
      _moveChannel!.subscribe();
    }

    _controller.addListener(() {
      if (_controller.isCheckMate() || _controller.isDraw()) {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    String status = "Game Over";
    if (_controller.isCheckMate()) {
      status = "Checkmate!";
    } else if (_controller.isDraw()) {
      status = "Draw!";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const ui.Color(0xFF2C2C2C),
        title: Text(status, style: const TextStyle(color: Colors.white)),
        content: const Text("The game has ended.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.resetBoard();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _moveChannel?.unsubscribe();
    _controller.dispose();
    super.dispose();
  }

  void _onMove() {
    final fen = _controller.getFen();
    final parts = fen.split(' ');
    final turn = parts[1]; // 'w' or 'b'

    // In online mode, we must enforce turns
    if (!widget.isAi && widget.targetUserId != null) {
      final isWhiteTurn = turn == 'w';

      // If it flipped to the opposite color's turn, it means WE just moved.
      // But we should check if the move we just made was legal for our color.
      // Actually, onMove is called AFTER the move is made on the board.
      // If we are White, the turn should now be 'b'.
      final expectedTurnAfterMove = widget.isWhite ? 'b' : 'w';

      if (turn == expectedTurnAfterMove) {
        _moveChannel!.sendBroadcastMessage(
          event: 'move',
          payload: {
            'fen': fen,
            'senderId': SupaFlow.client.auth.currentUser?.id,
          },
        );
      } else {
        // This shouldn't happen if enableUserMoves is working, but safety first
        debugPrint('Not your turn!');
      }
    } else if (widget.isAi) {
      // In AI mode, if it's AI's turn, trigger it
      final isAiTurn =
          (widget.isWhite && turn == 'b') || (!widget.isWhite && turn == 'w');
      if (isAiTurn && !_isAiThinking) {
        _triggerAiMove();
      }
    }

    // In local mode (targetUserId == null && !isAi), we don't need to do anything,
    // both sides just move on the same machine.

    if (mounted) setState(() {});
  }

  Future<void> _triggerAiMove() async {
    if (_controller.isCheckMate() || _controller.isDraw()) return;

    setState(() => _isAiThinking = true);

    try {
      final fen = _controller.getFen();
      final history = _controller.game.history;
      final lastMoves = (history is List && history.isNotEmpty)
          ? (history.length > 10 
              ? history.sublist(history.length - 10).join(', ') 
              : history.join(', '))
          : "";
      
      final prompt = '''
      You are a Grandmaster level chess engine.
      Current Position (FEN): $fen
      Last few moves: $lastMoves
      
      Task: Analyze the position and provide the absolute best move.
      Requirements:
      1. Return the move ONLY in UCI format (e.g., "e2e4", "g1f3", "e7e8q" for promotion).
      2. Return ONLY the move string. No explanations, no commentary, no additional text.
      3. If a pawn is moving to the last rank, remember to include the promotion piece (q, r, b, or n).
      
      UCI Move:''';

      final aiService = AIService();
      final response = await aiService.generateText(
        prompt: prompt,
      );

      if (response.isSuccess && response.data != null) {
        String moveStr = response.data!.trim().toLowerCase();
        
        // Clean the response - sometimes AI includes quotes or "UCI Move: " prefix
        if (moveStr.contains(':')) {
          moveStr = moveStr.split(':').last.trim();
        }
        moveStr = moveStr.replaceAll(RegExp(r'[^a-h1-8qrbn]'), '');

        debugPrint('AI Suggestion: $moveStr');

        if (moveStr.length >= 4) {
          final from = moveStr.substring(0, 2);
          final to = moveStr.substring(2, 4);
          String? promotion;
          if (moveStr.length > 4) {
            promotion = moveStr.substring(4, 5);
          }
          
          try {
            _controller.makeMove(from: from, to: to);
          } catch (e) {
            debugPrint('Invalid AI move attempted: $moveStr - Error: $e');
            _fallbackRandomMove();
          }
        } else {
          _fallbackRandomMove();
        }
      } else {
        _fallbackRandomMove();
      }
    } catch (e) {
      debugPrint('AI Move Error: $e');
      _fallbackRandomMove();
    }

    if (mounted) {
      setState(() => _isAiThinking = false);
    }
  }

  void _fallbackRandomMove() {
    final moves = _controller.game.moves();
    if (moves.isNotEmpty) {
      moves.shuffle();
      final randomMove = moves.first;
      _controller.makeMove(from: randomMove.from, to: randomMove.to);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const ui.Color(0xFF161618),
      appBar: AppBar(
        title: Text(widget.isAi ? 'Chess vs AI' : 'Playing Chess',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isAiThinking)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getStatusMessage(),
            style: GoogleFonts.outfit(
              color: _isAiThinking ? Colors.purpleAccent : Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ChessBoard(
              controller: _controller,
              boardColor: BoardColor.brown,
              boardOrientation:
                  widget.isWhite ? PlayerColor.white : PlayerColor.black,
              enableUserMoves: _canMove(),
              onMove: () {
                _onMove();
              },
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameButton(Icons.refresh, 'Reset', () {
                  _controller.resetBoard();
                }),
                _buildGameButton(Icons.undo, 'Undo', () {
                  _controller.undoMove();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage() {
    if (_controller.isCheckMate()) return 'Checkmate!';
    if (_controller.isDraw()) return 'Draw!';
    if (_isAiThinking) return 'AI is thinking...';

    final turn = _controller.getFen().split(' ')[1];
    final isWhiteTurn = turn == 'w';

    if (widget.isAi) {
      return (isWhiteTurn == widget.isWhite) ? 'Your Turn' : 'AI Turn';
    } else if (widget.targetUserId != null) {
      return (isWhiteTurn == widget.isWhite) ? 'Your Turn' : "Opponent's Turn";
    } else {
      return isWhiteTurn ? "White's Turn" : "Black's Turn";
    }
  }

  bool _canMove() {
    if (_isAiThinking) return false;
    if (_controller.isCheckMate() || _controller.isDraw()) return false;

    final turn = _controller.getFen().split(' ')[1];
    final isWhiteTurn = turn == 'w';

    if (widget.isAi) {
      return isWhiteTurn == widget.isWhite;
    } else if (widget.targetUserId != null) {
      return isWhiteTurn == widget.isWhite;
    }

    return true; // Local practice mode
  }

  Widget _buildGameButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 28),
        ),
        Text(label,
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
