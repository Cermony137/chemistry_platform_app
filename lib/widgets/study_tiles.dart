import 'package:flutter/material.dart';

class SquareTile extends StatefulWidget {
  final String title; final Color color; final double size; final VoidCallback onTap; final String? emoji;
  const SquareTile({super.key, required this.title, required this.color, required this.size, required this.onTap, this.emoji});

  @override
  State<SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState(){ super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.0, upperBound: 0.05); }
  @override
  void dispose(){ _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final scale = 1 + _c.value;
    return MouseRegion(
      onEnter: (_) => _c.forward(),
      onExit: (_) => _c.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) => _c.reverse(),
        onTapCancel: () => _c.reverse(),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0,4))],
              ),
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '${widget.emoji!=null? widget.emoji! + ' ' : ''}${widget.title}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


