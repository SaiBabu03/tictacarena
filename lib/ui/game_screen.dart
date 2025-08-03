import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showCelebrationOverlay() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned(
            left: 0,
            top: 200,
            child: Lottie.network(
              'https://assets4.lottiefiles.com/packages/lf20_u4yrau.json',
              width: 280,
              height: 280,
              repeat: false,
            ),
          ),
          Positioned(
            right: 0,
            top: 200,
            child: Lottie.network(
              'https://assets4.lottiefiles.com/packages/lf20_u4yrau.json',
              width: 280,
              height: 280,
              repeat: false,
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 8,
            toolbarHeight: 70,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(Icons.videogame_asset_rounded, color: Colors.tealAccent, size: 28),
            ),
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tic Tac Arena",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Two-Player Battle",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.black,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
                opacity: 0.06,
              ),
            ),
            child: BlocListener<GameBloc, GameState>(
              listenWhen: (previous, current) =>
              previous.winner != current.winner || previous.isDraw != current.isDraw,
              listener: (context, state) {
                if (state.winner != null || state.isDraw) {
                  if (!state.isDraw) {
                    _confettiController.play();
                    _showCelebrationOverlay();
                  }
                  _showResultDialog(context, state);
                }
              },
              child: BlocBuilder<GameBloc, GameState>(
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      double gridSize = screenWidth * 0.8;
                      if (gridSize > 500) gridSize = 500;

                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGameStatus(state, screenWidth),
                              const SizedBox(height: 30),
                              _buildGrid(context, state, gridSize),
                              const SizedBox(height: 40),
                              _buildRestartButton(context, screenWidth),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.1,
          numberOfParticles: 30,
          maxBlastForce: 25,
          minBlastForce: 8,
          gravity: 0.3,
          shouldLoop: false,
        ),
      ],
    );
  }

  Widget _buildGameStatus(GameState state, double screenWidth) {
    final isXTurn = state.winner == null && !state.isDraw && state.currentPlayer == 'X';
    final isOTurn = state.winner == null && !state.isDraw && state.currentPlayer == 'O';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _playerCard('X', isXTurn, screenWidth),
          const Text('VS', style: TextStyle(color: Colors.white70, fontSize: 18)),
          _playerCard('O', isOTurn, screenWidth),
        ],
      ),
    );
  }

  Widget _playerCard(String player, bool isActive, double screenWidth) {
    double fontSize = screenWidth < 400 ? 14 : 16;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.tealAccent.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.tealAccent : Colors.grey.shade700,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(player == 'X' ? '❌' : '🟡', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            'Player $player',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, GameState state, double gridSize) {
    return Container(
      height: gridSize,
      width: gridSize,
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (_, index) {
          final isWinningCell = state.winningCombo.contains(index);
          final cellValue = state.board[index];

          return GestureDetector(
            onTap: () => context.read<GameBloc>().add(TapCell(index)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isWinningCell
                    ? Colors.tealAccent.withOpacity(0.3)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (cellValue != '')
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: cellValue == '' ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    cellValue,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: cellValue == 'X' ? Colors.cyanAccent : Colors.amberAccent,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestartButton(BuildContext context, double screenWidth) {
    final isSmall = screenWidth < 360;
    return GestureDetector(
      onTap: () {
        context.read<GameBloc>().add(RestartGame());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 20 : 32,
          vertical: isSmall ? 10 : 14,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Restart",
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 16 : 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, GameState state) {
    final title = state.isDraw
        ? "It's a Draw!"
        : "🎉 Player ${state.winner} Wins!";
    final emoji = state.isDraw
        ? "😐"
        : state.winner == 'X'
        ? "❌"
        : "🟡";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1F1F1F),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<GameBloc>().add(RestartGame());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.1),
                    foregroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Play Again"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
