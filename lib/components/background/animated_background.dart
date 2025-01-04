import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final Random random = Random();
  final List<FinanceSymbol> symbols = [];
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final deltaTime = elapsed - _lastElapsed;
      if (deltaTime.inMilliseconds >= 41) { // Approximately 24 FPS
        setState(() {
          for (var symbol in symbols) {
            symbol.updatePosition(deltaTime.inMilliseconds / 1000.0);
          }
        });
        _lastElapsed = elapsed;
      }
    })..start();

    for (int i = 0; i < 20; i++) {
      symbols.add(FinanceSymbol(
        random,
        initialX: random.nextDouble(),
        initialY: random.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.grey.shade900,
              ],
            ),
          ),
        ),
        CustomPaint(
          painter: FinanceSymbolsPainter(
            symbols: symbols,
          ),
          child: Container(),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: widget.child,
        ),
      ],
    );
  }
}

class FinanceSymbol {
  late double x;
  late double y;
  late String symbol;
  late Color color;
  late double size;
  late double speed;
  late double opacity;
  late double directionX; // New property for X direction
  late double directionY; // New property for Y direction

  static const symbols = ['₽', '\$', '€', '£', '¥', '₣', '₴', '₸', '₮', '₩', '₦', '₲', '₵', '₡', '₢', '₳', '₹', '₺', '₼', '₾', '₿'];
  
  FinanceSymbol(Random random, {double? initialX, double? initialY}) {
    reset(random, true, initialX: initialX, initialY: initialY);
  }

  void reset(Random random, bool initialPosition, {double? initialX, double? initialY}) {
    x = initialX ?? random.nextDouble();
    y = initialY ?? (initialPosition ? random.nextDouble() : random.nextDouble());
    symbol = symbols[random.nextInt(symbols.length)];
    
    final colors = [
      Colors.green.withOpacity(0.3),
      Colors.blue.withOpacity(0.3),
      Colors.white.withOpacity(0.3),
    ];
    
    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 20 + 10;
    speed = random.nextDouble() * 0.0005 + 0.0005; 
    opacity = random.nextDouble() * 0.5 + 0.2;
    
    // Random direction between -1 and 1
    directionX = (random.nextDouble() * 2 - 1);
    directionY = (random.nextDouble() * 2 - 1);
  }

  void updatePosition(double deltaTime) {
    x += directionX * speed;
    y += directionY * speed;
    
    // Wrap around screen edges
    if (x > 1.1) x = -0.1;
    if (x < -0.1) x = 1.1;
    if (y > 1.1) y = -0.1;
    if (y < -0.1) y = 1.1;
  }
}

class FinanceSymbolsPainter extends CustomPainter {
  final List<FinanceSymbol> symbols;
  final Random random = Random();

  FinanceSymbolsPainter({
    required this.symbols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainters = <TextPainter>[];

    for (var symbol in symbols) {
      if (symbol.y > 1.1) {
        symbol.reset(random, false);
      }

      if (textPainters.length < symbols.length) {
        textPainters.add(TextPainter(
          text: TextSpan(
            text: symbol.symbol,
            style: TextStyle(
              color: symbol.color.withOpacity(symbol.opacity),
              fontSize: symbol.size,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout());
      }

      final painter = textPainters[symbols.indexOf(symbol)];
      painter.paint(
        canvas,
        Offset(
          symbol.x * size.width,
          symbol.y * size.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(FinanceSymbolsPainter oldDelegate) => true;
}