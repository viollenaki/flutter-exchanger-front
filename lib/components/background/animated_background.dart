import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();
  final List<FinanceSymbol> symbols = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 33), // ~30 FPS (1000ms / 30)
      vsync: this,
    )..repeat();

    // Уменьшаем количество символов
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black, // Простой черный фон
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: FinanceSymbolsPainter(
                symbols: symbols,
                animation: _controller,
              ),
              child: Container(),
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Уменьшили размытие
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

  static const symbols = ['₽', '\$', '€', '£', '¥', '₣', '₴', '₸', '₮', '₩', '₦', '₲', '₵', '₡', '₢', '₳', '₹', '₺', '₼', '₾', '₿'];
  
  FinanceSymbol(Random random, {double? initialX, double? initialY}) {
    reset(random, true, initialX: initialX, initialY: initialY);
  }

  void reset(Random random, bool initialPosition, {double? initialX, double? initialY}) {
    x = initialX ?? random.nextDouble();
    y = initialY ?? (initialPosition ? random.nextDouble() : -0.1);
    symbol = symbols[random.nextInt(symbols.length)];
    
    final colors = [
      Colors.green.withOpacity(0.3),
      Colors.blue.withOpacity(0.3),
      Colors.white.withOpacity(0.3),
    ];
    
    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 20 + 10; // Уменьшили размер
    speed = random.nextDouble() * 0.001 + 0.002; // Оптимизировали скорость
    opacity = random.nextDouble() * 0.5 + 0.2; // Уменьшили прозрачность
  }

  void updatePosition(double deltaTime) {
    y += speed; // Упростили расчет движения
  }
}

class FinanceSymbolsPainter extends CustomPainter {
  final List<FinanceSymbol> symbols;
  final Animation<double> animation;
  final Random random = Random();

  FinanceSymbolsPainter({
    required this.symbols,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Создаем TextPainter один раз для каждого символа
    final textPainters = <TextPainter>[];
    
    for (var symbol in symbols) {
      symbol.updatePosition(0.033); // 1/30 секунды для 30 FPS
      
      if (symbol.y > 1.1) {
        symbol.reset(random, false);
      }

      // Переиспользуем TextPainter
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